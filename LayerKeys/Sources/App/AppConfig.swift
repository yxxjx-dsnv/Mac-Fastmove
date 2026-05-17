import Foundation

enum AppConfig {
    static let appName = "Mac Fastmove"
    static let suiteIdentifier = "io.github.macfastmove.app"
    static let trialLengthDays = 7
    static let defaultDoubleTapInterval = 0.28
    static let syntheticEventUserData = 0x4C41594552 // "LAYER"

    static var repositoryURL: URL {
        url(forInfoKey: "MacFastmoveRepositoryURL") ?? URL(string: "https://github.com/example/mac-fastmove")!
    }

    static var sparkleFeedURL: URL? {
        guard let url = url(forInfoKey: "SUFeedURL"), url.host != "example.com" else {
            return nil
        }
        return url
    }

    static var sparklePublicKey: String? {
        guard let raw = Bundle.main.object(forInfoDictionaryKey: "SUPublicEDKey") as? String else {
            return nil
        }
        let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty || trimmed == "CHANGE_ME" ? nil : trimmed
    }

    static var sparkleConfigured: Bool {
        sparkleFeedURL != nil && sparklePublicKey != nil
    }

    private static func url(forInfoKey key: String) -> URL? {
        guard let raw = Bundle.main.object(forInfoDictionaryKey: key) as? String else {
            return nil
        }
        return URL(string: raw)
    }
}
