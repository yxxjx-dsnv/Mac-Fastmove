import SwiftUI

struct PresetsPane: View {
    @EnvironmentObject private var model: AppModel

    var body: some View {
        Form {
            Section("Caps Navigation") {
                Toggle(
                    "Enable Caps Navigation",
                    isOn: Binding(
                        get: { model.settings.capsNavigationEnabled },
                        set: { model.toggleCapsNavigation($0) }
                    )
                )

                VStack(alignment: .leading, spacing: 8) {
                    Text("Double Tap Window")
                    Slider(
                        value: Binding(
                            get: { model.settings.doubleTapInterval },
                            set: { model.updateDoubleTapInterval($0) }
                        ),
                        in: 0.18...0.45,
                        step: 0.01
                    )
                    Text("\(model.settings.doubleTapInterval, format: .number.precision(.fractionLength(2))) seconds")
                        .foregroundStyle(.secondary)
                }

                Text("Behavior: single tap passes through to macOS, quick double tap toggles real Caps Lock, hold Caps and use W/A/S/D as arrows.")
                    .font(.callout)
                    .foregroundStyle(.secondary)
            }

            Section("Scope") {
                Text("Caps Navigation currently applies system-wide to keep the v1 experience predictable and fast.")
                    .foregroundStyle(.secondary)
                Text("Connected keyboards are still shown in Diagnostics for troubleshooting, but per-device routing is not part of this release.")
                    .font(.callout)
                    .foregroundStyle(.secondary)
            }
        }
        .formStyle(.grouped)
        .padding(24)
    }
}
