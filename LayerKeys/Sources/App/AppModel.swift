import Foundation
import AppKit
import SwiftUI

@MainActor
final class AppModel: ObservableObject {
    @Published var settings: AppSettings
    @Published var permissionState: PermissionState
    @Published var trialState: TrialState
    @Published var licenseState: LicenseState?
    @Published var keyboards: [KeyboardDevice] = []
    @Published var engineAvailability: EngineAvailability = .disabled
    @Published var engineMessage = "Starting up…"
    @Published var lastObservedAction = "No input yet."
    @Published var licenseEntry = ""

    private let store: CodableStore
    private let keychain: KeychainService
    private let trialService: TrialService
    private let licenseService: LicenseService
    private let permissionService: PermissionService
    private let keyboardMonitor: KeyboardDeviceMonitor
    private let updateService: UpdaterService
    private let capsLockController: CapsLockStateController?
    private let engine: CapsNavigationEngine
    private let eventTapService: EventTapService

    init() {
        let store = CodableStore()
        let keychain = KeychainService()
        let trialService = TrialService(keychain: keychain, store: store)
        let licenseService = LicenseService(keychain: keychain, store: store)
        let permissionService = PermissionService()
        let keyboardMonitor = KeyboardDeviceMonitor()
        let updateService = UpdaterService()
        let capsLockController = CapsLockStateController()
        let loadedSettings = store.load(AppSettings.self, fileName: "settings.json") ?? AppSettings()
        let engine = CapsNavigationEngine(doubleTapInterval: loadedSettings.doubleTapInterval)
        let eventTapService = EventTapService(engine: engine, capsLockController: capsLockController)

        self.store = store
        self.keychain = keychain
        self.trialService = trialService
        self.licenseService = licenseService
        self.permissionService = permissionService
        self.keyboardMonitor = keyboardMonitor
        self.updateService = updateService
        self.capsLockController = capsLockController
        self.engine = engine
        self.eventTapService = eventTapService
        settings = loadedSettings
        trialState = trialService.currentState()
        licenseState = licenseService.currentState()
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

        refreshRuntimeState()
    }

    var isUnlocked: Bool {
        licenseState != nil || !trialState.isExpired()
    }

    var trialDescription: String {
        if let licenseState {
            return "Unlocked with \(licenseState.maskedToken)"
        }
        let remaining = trialState.remainingDays()
        return remaining == 0 ? "Trial expired" : "\(remaining) day(s) remaining"
    }

    var menuBarSymbolName: String {
        switch engineAvailability {
        case .running:
            return isUnlocked ? "keyboard.fill" : "keyboard.badge.ellipsis"
        case .blockedByPermissions:
            return "keyboard.badge.ellipsis"
        case .blockedByTrial:
            return "exclamationmark.triangle.fill"
        case .disabled:
            return "keyboard"
        }
    }

    var sparkleConfigured: Bool {
        updateService.isConfigured
    }

    func refreshRuntimeState() {
        permissionState = permissionService.currentState()
        trialState = trialService.currentState()
        licenseState = licenseService.currentState()
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

    func toggleKeyboardSelection(_ keyboardID: String) {
        if settings.selectedKeyboardIDs.contains(keyboardID) {
            settings.selectedKeyboardIDs.remove(keyboardID)
        } else {
            settings.selectedKeyboardIDs.insert(keyboardID)
        }
        persistSettings()
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

    func openPurchasePage() {
        NSWorkspace.shared.open(AppConfig.purchaseURL)
    }

    func openRepository() {
        NSWorkspace.shared.open(AppConfig.repositoryURL)
    }

    func activateLicense() -> String? {
        do {
            licenseState = try licenseService.activate(token: licenseEntry)
            licenseEntry = ""
            evaluateEventTap()
            return nil
        } catch {
            return error.localizedDescription
        }
    }

    func clearLicense() {
        licenseService.clear()
        licenseState = nil
        evaluateEventTap()
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

        guard isUnlocked else {
            eventTapService.stop()
            engineAvailability = .blockedByTrial
            engineMessage = "Trial expired. Activate a purchase token to continue."
            return
        }

        eventTapService.start()
    }

    private func persistSettings() {
        try? store.save(settings, fileName: "settings.json")
    }
}
