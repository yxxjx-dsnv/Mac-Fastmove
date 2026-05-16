import Foundation

#if canImport(Sparkle)
import Sparkle
#endif

@MainActor
final class UpdaterService {
    #if canImport(Sparkle)
    private let updaterController: SPUStandardUpdaterController?
    #endif

    init() {
        #if canImport(Sparkle)
        if AppConfig.sparkleConfigured {
            updaterController = SPUStandardUpdaterController(startingUpdater: true, updaterDelegate: nil, userDriverDelegate: nil)
        } else {
            updaterController = nil
        }
        #endif
    }

    var isConfigured: Bool {
        #if canImport(Sparkle)
        updaterController != nil
        #else
        false
        #endif
    }

    func checkForUpdates() {
        #if canImport(Sparkle)
        updaterController?.checkForUpdates(nil)
        #endif
    }
}
