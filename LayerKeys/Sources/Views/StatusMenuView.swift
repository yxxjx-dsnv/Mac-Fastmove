import SwiftUI

struct StatusMenuView: View {
    @Environment(\.openWindow) private var openWindow
    @EnvironmentObject private var model: AppModel

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(AppConfig.appName)
                .font(.headline)

            Text(model.engineMessage)
                .font(.callout)
                .foregroundStyle(.secondary)

            Divider()

            Button("Open \(AppConfig.appName)") {
                model.openDashboard(openWindow)
            }

            Button(model.settings.capsNavigationEnabled ? "Disable Caps Navigation" : "Enable Caps Navigation") {
                model.toggleCapsNavigation(!model.settings.capsNavigationEnabled)
            }

            Button("Refresh Status") {
                model.refreshRuntimeState()
            }

            Divider()

            Button("Quit \(AppConfig.appName)") {
                NSApplication.shared.terminate(nil)
            }
        }
        .padding(14)
        .frame(width: 280)
    }
}
