import SwiftUI

struct OverviewPane: View {
    @EnvironmentObject private var model: AppModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text(AppConfig.appName)
                    .font(.largeTitle.bold())

                Text("A compact keyboard power-user utility for direct distribution on macOS.")
                    .foregroundStyle(.secondary)

                GroupBox("Current Status") {
                    VStack(alignment: .leading, spacing: 12) {
                        statusRow("Engine", value: engineLabel)
                        statusRow("Trial / License", value: model.trialDescription)
                        statusRow("Permissions", value: permissionsLabel)
                        statusRow("Connected Keyboards", value: "\(model.keyboards.count)")
                    }
                }

                GroupBox("Default Preset") {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Caps Navigation")
                            .font(.headline)
                        Text("Single tap Caps Lock passes through to macOS, quick double tap toggles real Caps Lock, and holding Caps Lock turns W/A/S/D into arrow keys.")
                            .foregroundStyle(.secondary)
                    }
                }

                GroupBox("Beta Notes") {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("This build uses a global CGEventTap pipeline.")
                        Text("Per-device keyboard selection is discovered and stored, but true per-device routing will require a lower-level engine than CGEventTap.")
                    }
                    .font(.callout)
                    .foregroundStyle(.secondary)
                }
            }
            .padding(24)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var engineLabel: String {
        switch model.engineAvailability {
        case .running:
            return "Running"
        case .disabled:
            return "Disabled"
        case .blockedByPermissions:
            return "Blocked by permissions"
        case .blockedByTrial:
            return "Blocked by expired trial"
        }
    }

    private var permissionsLabel: String {
        "Accessibility: \(model.permissionState.accessibility.rawValue), Input Monitoring: \(model.permissionState.inputMonitoring.rawValue)"
    }

    private func statusRow(_ title: String, value: String) -> some View {
        HStack(alignment: .firstTextBaseline) {
            Text(title)
                .fontWeight(.semibold)
                .frame(width: 140, alignment: .leading)
            Text(value)
                .foregroundStyle(.secondary)
        }
    }
}
