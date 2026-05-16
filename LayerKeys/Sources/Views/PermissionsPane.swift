import SwiftUI

struct PermissionsPane: View {
    @EnvironmentObject private var model: AppModel

    var body: some View {
        Form {
            Section("Accessibility") {
                permissionRow(
                    title: "Required to intercept and rewrite keyboard events.",
                    state: model.permissionState.accessibility
                )
                HStack {
                    Button("Request Accessibility") {
                        model.requestAccessibility()
                    }
                    Button("Open Accessibility Settings") {
                        model.openAccessibilitySettings()
                    }
                }
            }

            Section("Input Monitoring") {
                permissionRow(
                    title: "Required to observe HID keyboard events and enumerate selected devices.",
                    state: model.permissionState.inputMonitoring
                )
                HStack {
                    Button("Request Input Monitoring") {
                        model.requestInputMonitoring()
                    }
                    Button("Open Input Monitoring Settings") {
                        model.openInputMonitoringSettings()
                    }
                }
            }

            Section {
                Button("Refresh Permission State") {
                    model.refreshRuntimeState()
                }
            }
        }
        .formStyle(.grouped)
        .padding(24)
    }

    private func permissionRow(title: String, state: AccessState) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
            Text(state.rawValue.capitalized)
                .font(.callout.weight(.semibold))
                .foregroundStyle(color(for: state))
        }
    }

    private func color(for state: AccessState) -> Color {
        switch state {
        case .granted:
            return .green
        case .denied:
            return .red
        case .unknown:
            return .orange
        }
    }
}
