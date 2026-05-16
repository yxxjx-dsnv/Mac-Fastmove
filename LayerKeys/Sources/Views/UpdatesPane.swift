import SwiftUI

struct UpdatesPane: View {
    @EnvironmentObject private var model: AppModel

    var body: some View {
        Form {
            Section("Sparkle") {
                Text(model.sparkleConfigured ? "Sparkle is configured." : "Sparkle placeholders are still configured for local development.")
                    .foregroundStyle(model.sparkleConfigured ? .green : .secondary)

                Button("Check for Updates") {
                    model.checkForUpdates()
                }
                .disabled(!model.sparkleConfigured)
            }

            Section("Distribution") {
                Text("The repository includes DMG, notarization, and appcast helper scripts for direct web distribution.")
                    .foregroundStyle(.secondary)
                Button("Open Repository") {
                    model.openRepository()
                }
            }
        }
        .formStyle(.grouped)
        .padding(24)
    }
}
