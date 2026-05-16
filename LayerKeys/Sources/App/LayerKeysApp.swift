import SwiftUI

@main
struct LayerKeysApp: App {
    @StateObject private var model = AppModel()

    var body: some Scene {
        MenuBarExtra(AppConfig.appName, systemImage: model.menuBarSymbolName) {
            StatusMenuView()
                .environmentObject(model)
        }
        .menuBarExtraStyle(.window)

        Window(AppConfig.appName, id: "dashboard") {
            RootDashboardView()
                .environmentObject(model)
                .frame(minWidth: 900, minHeight: 620)
        }
        .defaultSize(width: 940, height: 680)
    }
}
