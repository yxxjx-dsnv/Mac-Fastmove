import Foundation

struct LicenseState: Codable, Equatable {
    var purchaseToken: String
    var activatedAt: Date

    var maskedToken: String {
        guard purchaseToken.count > 8 else { return purchaseToken }
        let prefix = purchaseToken.prefix(4)
        let suffix = purchaseToken.suffix(4)
        return "\(prefix)••••\(suffix)"
    }
}
