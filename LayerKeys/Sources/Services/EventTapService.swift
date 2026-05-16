import CoreGraphics
import Foundation

final class EventTapService {
    var onStatusChanged: ((EngineAvailability, String) -> Void)?
    var onActionObserved: ((String) -> Void)?

    private let engine: CapsNavigationEngine
    private let capsLockController: CapsLockStateController?
    private var eventTap: CFMachPort?
    private var runLoopSource: CFRunLoopSource?
    private var pendingTapWorkItem: DispatchWorkItem?
    private var capsPhysicalIsDown = false
    private(set) var availability: EngineAvailability = .disabled

    init(engine: CapsNavigationEngine, capsLockController: CapsLockStateController?) {
        self.engine = engine
        self.capsLockController = capsLockController
    }

    deinit {
        stop()
    }

    func start() {
        guard eventTap == nil else {
            availability = .running
            notifyStatus("Keyboard hook is already active.")
            return
        }

        let mask = (1 << CGEventType.keyDown.rawValue)
            | (1 << CGEventType.keyUp.rawValue)
            | (1 << CGEventType.flagsChanged.rawValue)
            | (1 << CGEventType.tapDisabledByTimeout.rawValue)
            | (1 << CGEventType.tapDisabledByUserInput.rawValue)

        let callback: CGEventTapCallBack = { _, type, event, userInfo in
            guard let userInfo else {
                return Unmanaged.passUnretained(event)
            }

            let service = Unmanaged<EventTapService>.fromOpaque(userInfo).takeUnretainedValue()
            return service.handleEvent(type: type, event: event)
        }

        let tap = CGEvent.tapCreate(
            tap: .cghidEventTap,
            place: .headInsertEventTap,
            options: .defaultTap,
            eventsOfInterest: CGEventMask(mask),
            callback: callback,
            userInfo: UnsafeMutableRawPointer(Unmanaged.passUnretained(self).toOpaque())
        )

        guard let tap else {
            availability = .blockedByPermissions
            notifyStatus("Could not create the keyboard event tap. Check Accessibility and Input Monitoring permissions.")
            return
        }

        eventTap = tap
        let source = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, tap, 0)
        runLoopSource = source
        CFRunLoopAddSource(CFRunLoopGetMain(), source, .commonModes)
        CGEvent.tapEnable(tap: tap, enable: true)

        availability = .running
        notifyStatus("Keyboard hook is active.")
    }

    func stop() {
        pendingTapWorkItem?.cancel()
        pendingTapWorkItem = nil

        if let source = runLoopSource {
            CFRunLoopRemoveSource(CFRunLoopGetMain(), source, .commonModes)
        }

        if let tap = eventTap {
            CFMachPortInvalidate(tap)
        }

        runLoopSource = nil
        eventTap = nil
        availability = .disabled
        notifyStatus("Keyboard hook is inactive.")
    }

    func setEnabled(_ enabled: Bool) {
        engine.isEnabled = enabled
        notifyStatus(enabled ? "Caps Navigation preset enabled." : "Caps Navigation preset disabled.")
    }

    func updateDoubleTapInterval(_ value: TimeInterval) {
        engine.doubleTapInterval = value
        syncPendingWorkItem(currentTime: ProcessInfo.processInfo.systemUptime)
    }

    private func handleEvent(type: CGEventType, event: CGEvent) -> Unmanaged<CGEvent>? {
        if event.getIntegerValueField(.eventSourceUserData) == Int64(AppConfig.syntheticEventUserData) {
            return Unmanaged.passUnretained(event)
        }

        if type == .tapDisabledByTimeout || type == .tapDisabledByUserInput {
            if let eventTap {
                CGEvent.tapEnable(tap: eventTap, enable: true)
            }
            notifyStatus("Keyboard hook resumed after macOS temporarily disabled it.")
            return Unmanaged.passUnretained(event)
        }

        let currentTime = ProcessInfo.processInfo.systemUptime
        execute(actions: engine.flushPendingSingleTap(at: currentTime))

        let keyCode = CGKeyCode(event.getIntegerValueField(.keyboardEventKeycode))

        if type == .flagsChanged, keyCode == 57 {
            capsPhysicalIsDown.toggle()
            let actions = engine.handleCapsEvent(isDown: capsPhysicalIsDown, at: currentTime)
            execute(actions: actions)
            syncPendingWorkItem(currentTime: currentTime)
            return nil
        }

        if type == .flagsChanged {
            execute(actions: engine.flushPendingSingleTap(at: currentTime, force: true))
            syncPendingWorkItem(currentTime: currentTime)
            return Unmanaged.passUnretained(event)
        }

        guard type == .keyDown || type == .keyUp else {
            return Unmanaged.passUnretained(event)
        }

        let actions = engine.handleKeyEvent(
            keyCode: keyCode,
            isDown: type == .keyDown,
            flags: event.flags,
            at: currentTime
        )

        execute(actions: actions)
        syncPendingWorkItem(currentTime: currentTime)

        if actions.contains(where: { if case .emitMappedKey = $0 { return true } else { return false } }) {
            return nil
        }

        return Unmanaged.passUnretained(event)
    }

    private func syncPendingWorkItem(currentTime: TimeInterval) {
        pendingTapWorkItem?.cancel()
        pendingTapWorkItem = nil

        guard let deadline = engine.pendingSingleTapDeadline else {
            return
        }

        let delay = max(0, deadline - currentTime)
        let workItem = DispatchWorkItem { [weak self] in
            guard let self else { return }
            let actions = self.engine.flushPendingSingleTap(at: ProcessInfo.processInfo.systemUptime, force: true)
            self.execute(actions: actions)
            self.syncPendingWorkItem(currentTime: ProcessInfo.processInfo.systemUptime)
        }

        pendingTapWorkItem = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: workItem)
    }

    private func execute(actions: [CapsNavigationAction]) {
        for action in actions {
            switch action {
            case .emitSingleCapsTap:
                postCapsTap()
                onActionObserved?("Single tap Caps Lock passed through to macOS.")
            case .toggleCapsLock:
                capsLockController?.toggleCapsLock()
                onActionObserved?("Double tap toggled Caps Lock state.")
            case let .emitMappedKey(keyCode, isDown, flags):
                postKeyEvent(keyCode: keyCode, isDown: isDown, flags: flags)
                onActionObserved?("Mapped key event: \(keyCode) \(isDown ? "down" : "up").")
            }
        }
    }

    private func postCapsTap() {
        postKeyEvent(keyCode: 57, isDown: true, flags: [])
        postKeyEvent(keyCode: 57, isDown: false, flags: [])
    }

    private func postKeyEvent(keyCode: CGKeyCode, isDown: Bool, flags: CGEventFlags) {
        guard let event = CGEvent(keyboardEventSource: nil, virtualKey: keyCode, keyDown: isDown) else {
            return
        }

        event.flags = flags
        event.setIntegerValueField(.eventSourceUserData, value: Int64(AppConfig.syntheticEventUserData))
        event.post(tap: .cghidEventTap)
    }

    private func notifyStatus(_ message: String) {
        onStatusChanged?(availability, message)
    }
}
