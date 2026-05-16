import Foundation

struct AppSettings: Codable, Equatable {
    var capsNavigationEnabled = true
    var doubleTapInterval = AppConfig.defaultDoubleTapInterval
    var selectedKeyboardIDs: Set<String> = []
    var automaticUpdateChecks = true
}
