import Foundation

enum AccessState: String, Codable {
    case granted
    case denied
    case unknown
}

struct PermissionState: Codable, Equatable {
    var accessibility: AccessState
    var inputMonitoring: AccessState

    var canRunKeyboardHooks: Bool {
        accessibility == .granted && inputMonitoring == .granted
    }
}
