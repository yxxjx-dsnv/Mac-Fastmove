import CoreGraphics
import Foundation

enum CapsNavigationAction: Equatable {
    case emitSingleCapsTap
    case toggleCapsLock
    case emitMappedKey(keyCode: CGKeyCode, isDown: Bool, flags: CGEventFlags)
}

final class CapsNavigationEngine {
    private let mapping: [CGKeyCode: CGKeyCode] = [
        13: 126, // w -> up
        0: 123,  // a -> left
        1: 125,  // s -> down
        2: 124   // d -> right
    ]

    private(set) var pendingSingleTapDeadline: TimeInterval?
    private var capsIsDown = false
    private var capsUsedAsLayer = false
    private var secondTapArmed = false
    private var pendingSingleTap = false
    private var activeMappedKeyCodes: [CGKeyCode: CGKeyCode] = [:]

    var doubleTapInterval: TimeInterval
    var isEnabled: Bool = true

    init(doubleTapInterval: TimeInterval = AppConfig.defaultDoubleTapInterval) {
        self.doubleTapInterval = doubleTapInterval
    }

    func handleCapsEvent(isDown: Bool, at time: TimeInterval) -> [CapsNavigationAction] {
        if isDown {
            if pendingSingleTap, let deadline = pendingSingleTapDeadline, time <= deadline {
                pendingSingleTap = false
                pendingSingleTapDeadline = nil
                secondTapArmed = true
            } else {
                pendingSingleTap = false
                pendingSingleTapDeadline = nil
                secondTapArmed = false
            }

            capsIsDown = true
            capsUsedAsLayer = false
            return []
        }

        capsIsDown = false

        if secondTapArmed, !capsUsedAsLayer {
            secondTapArmed = false
            return [.toggleCapsLock]
        }

        secondTapArmed = false

        if capsUsedAsLayer {
            capsUsedAsLayer = false
            return []
        }

        pendingSingleTap = true
        pendingSingleTapDeadline = time + doubleTapInterval
        return []
    }

    func handleKeyEvent(keyCode: CGKeyCode, isDown: Bool, flags: CGEventFlags, at time: TimeInterval) -> [CapsNavigationAction] {
        var actions = [CapsNavigationAction]()

        if isDown, pendingSingleTap, !capsIsDown {
            actions.append(contentsOf: flushPendingSingleTap(at: time, force: true))
        }

        guard isEnabled else { return actions }

        if let mappedKeyCode = activeMappedKeyCodes[keyCode] {
            if !isDown {
                activeMappedKeyCodes.removeValue(forKey: keyCode)
            }
            actions.append(.emitMappedKey(keyCode: mappedKeyCode, isDown: isDown, flags: sanitizedFlags(from: flags)))
            return actions
        }

        guard capsIsDown, let mappedKeyCode = mapping[keyCode] else {
            return actions
        }

        capsUsedAsLayer = true

        if isDown {
            activeMappedKeyCodes[keyCode] = mappedKeyCode
        }

        actions.append(.emitMappedKey(keyCode: mappedKeyCode, isDown: isDown, flags: sanitizedFlags(from: flags)))
        return actions
    }

    func flushPendingSingleTap(at time: TimeInterval, force: Bool = false) -> [CapsNavigationAction] {
        guard pendingSingleTap else { return [] }
        guard force || (pendingSingleTapDeadline.map { time >= $0 } ?? false) else {
            return []
        }

        pendingSingleTap = false
        pendingSingleTapDeadline = nil
        return [.emitSingleCapsTap]
    }

    private func sanitizedFlags(from flags: CGEventFlags) -> CGEventFlags {
        flags.intersection([.maskShift, .maskControl, .maskAlternate, .maskCommand, .maskNumericPad])
    }
}
