import Foundation

enum LicenseValidationError: LocalizedError {
    case invalidFormat

    var errorDescription: String? {
        switch self {
        case .invalidFormat:
            return "Enter a valid Gumroad purchase token or license string."
        }
    }
}

final class LicenseService {
    private let keychain: KeychainService
    private let store: CodableStore
    private let keychainService = AppConfig.suiteIdentifier
    private let keychainAccount = "license.token"
    private let fileName = "license-state.json"

    init(keychain: KeychainService, store: CodableStore) {
        self.keychain = keychain
        self.store = store
    }

    func currentState() -> LicenseState? {
        if let persisted = store.load(LicenseState.self, fileName: fileName) {
            return persisted
        }

        if let token = keychain.loadString(service: keychainService, account: keychainAccount) {
            let state = LicenseState(purchaseToken: token, activatedAt: .now)
            persist(state)
            return state
        }

        return nil
    }

    func activate(token rawToken: String) throws -> LicenseState {
        let token = rawToken.trimmingCharacters(in: .whitespacesAndNewlines)
        guard Self.isPlausiblePurchaseToken(token) else {
            throw LicenseValidationError.invalidFormat
        }

        let state = LicenseState(purchaseToken: token, activatedAt: .now)
        persist(state)
        return state
    }

    func clear() {
        keychain.delete(service: keychainService, account: keychainAccount)
        store.remove(fileName: fileName)
    }

    static func isPlausiblePurchaseToken(_ token: String) -> Bool {
        guard token.count >= 8 else { return false }
        let regex = try? NSRegularExpression(pattern: "^[A-Za-z0-9_\\-]+$")
        let range = NSRange(token.startIndex..<token.endIndex, in: token)
        return regex?.firstMatch(in: token, range: range) != nil
    }

    private func persist(_ state: LicenseState) {
        try? keychain.saveString(state.purchaseToken, service: keychainService, account: keychainAccount)
        try? store.save(state, fileName: fileName)
    }
}
