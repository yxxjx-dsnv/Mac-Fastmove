import Foundation

final class TrialService {
    private let keychain: KeychainService
    private let store: CodableStore
    private let keychainService = AppConfig.suiteIdentifier
    private let keychainAccount = "trial.startedAt"
    private let fileName = "trial-state.json"

    init(keychain: KeychainService, store: CodableStore) {
        self.keychain = keychain
        self.store = store
    }

    func currentState(referenceDate: Date = .now) -> TrialState {
        if let existing = loadState() {
            return existing
        }

        let state = TrialState(startedAt: referenceDate)
        persist(state)
        return state
    }

    private func loadState() -> TrialState? {
        if let keychainValue = keychain.loadString(service: keychainService, account: keychainAccount),
           let date = ISO8601DateFormatter().date(from: keychainValue) {
            return TrialState(startedAt: date)
        }

        return store.load(TrialState.self, fileName: fileName)
    }

    private func persist(_ state: TrialState) {
        let iso = ISO8601DateFormatter().string(from: state.startedAt)
        try? keychain.saveString(iso, service: keychainService, account: keychainAccount)
        try? store.save(state, fileName: fileName)
    }
}
