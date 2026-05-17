import Foundation
import AppKit
import SwiftUI

@MainActor
final class AppModel: ObservableObject {
    @Published var settings: AppSettings
    @Published var permissionState: PermissionState
    @Published var keyboards: [KeyboardDevice] = []
    @Published var engineAvailability: EngineAvailability = .disabled
    @Published var engineMessage = "Starting up…"
    @Published var lastObservedAction = "No input yet."

    private let store: CodableStore
    private let permissionService: PermissionService
    private let keyboardMonitor: KeyboardDeviceMonitor
    private let updateService: UpdaterService
    private let capsLockController: CapsLockStateController?
    private let engine: CapsNavigationEngine
    private let eventTapService: EventTapService

    init(skipRuntimeStateBootstrap: Bool = false) {
        let store = CodableStore()
        let permissionService = PermissionService()
        let keyboardMonitor = KeyboardDeviceMonitor()
        let updateService = UpdaterService()
        let capsLockController = CapsLockStateController()
        let loadedSettings = store.load(AppSettings.self, fileName: "settings.json") ?? AppSettings()
        let engine = CapsNavigationEngine(doubleTapInterval: loadedSettings.doubleTapInterval)
        let eventTapService = EventTapService(engine: engine, capsLockController: capsLockController)

        self.store = store
        self.permissionService = permissionService
        self.keyboardMonitor = keyboardMonitor
        self.updateService = updateService
        self.capsLockController = capsLockController
        self.engine = engine
        self.eventTapService = eventTapService
        settings = loadedSettings
        permissionState = permissionService.currentState()

        eventTapService.onStatusChanged = { [weak self] availability, message in
            Task { @MainActor in
                self?.engineAvailability = availability
                self?.engineMessage = message
            }
        }

        eventTapService.onActionObserved = { [weak self] action in
            Task { @MainActor in
                self?.lastObservedAction = action
            }
        }

        if !skipRuntimeStateBootstrap {
            refreshRuntimeState()
        }
    }

    var presetStatusDescription: String {
        settings.capsNavigationEnabled ? "Enabled" : "Disabled"
    }

    var menuBarSymbolName: String {
        switch engineAvailability {
        case .running:
            return "keyboard.fill"
        case .blockedByPermissions:
            return "keyboard.badge.ellipsis"
        case .disabled:
            return "keyboard"
        }
    }

    var sparkleConfigured: Bool {
        updateService.isConfigured
    }

    func refreshRuntimeState() {
        permissionState = permissionService.currentState()
        keyboards = keyboardMonitor.refresh()
        eventTapService.setEnabled(settings.capsNavigationEnabled)
        eventTapService.updateDoubleTapInterval(settings.doubleTapInterval)
        evaluateEventTap()
    }

    func toggleCapsNavigation(_ enabled: Bool) {
        settings.capsNavigationEnabled = enabled
        persistSettings()
        refreshRuntimeState()
    }

    func updateDoubleTapInterval(_ value: Double) {
        settings.doubleTapInterval = value
        persistSettings()
        eventTapService.updateDoubleTapInterval(value)
    }

    func requestAccessibility() {
        permissionService.requestAccessibility()
        refreshRuntimeState()
    }

    func requestInputMonitoring() {
        permissionService.requestInputMonitoring()
        refreshRuntimeState()
    }

    func openAccessibilitySettings() {
        permissionService.openAccessibilitySettings()
    }

    func openInputMonitoringSettings() {
        permissionService.openInputMonitoringSettings()
    }

    func openRepository() {
        NSWorkspace.shared.open(AppConfig.repositoryURL)
    }

    func checkForUpdates() {
        updateService.checkForUpdates()
    }

    func openDashboard(_ openWindow: OpenWindowAction) {
        NSApp.activate(ignoringOtherApps: true)
        openWindow(id: "dashboard")
    }

    private func evaluateEventTap() {
        if !settings.capsNavigationEnabled {
            eventTapService.stop()
            engineAvailability = .disabled
            engineMessage = "Caps Navigation preset disabled."
            return
        }

        guard permissionState.canRunKeyboardHooks else {
            eventTapService.stop()
            engineAvailability = .blockedByPermissions
            engineMessage = "Grant Accessibility and Input Monitoring to enable keyboard hooks."
            return
        }

        eventTapService.start()
    }

    private func persistSettings() {
        try? store.save(settings, fileName: "settings.json")
    }
}
