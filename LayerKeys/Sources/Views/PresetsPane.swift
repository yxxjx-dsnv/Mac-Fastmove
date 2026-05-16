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

            Section("Preferred Keyboards") {
                if model.keyboards.isEmpty {
                    Text("No keyboards detected.")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(model.keyboards) { keyboard in
                        Toggle(
                            keyboard.shortDescription,
                            isOn: Binding(
                                get: { model.settings.selectedKeyboardIDs.contains(keyboard.id) },
                                set: { _ in model.toggleKeyboardSelection(keyboard.id) }
                            )
                        )
                    }
                }

                Text("Current beta note: selected devices are discovered and persisted, but the CGEventTap remapping pipeline still applies globally.")
                    .font(.callout)
                    .foregroundStyle(.secondary)
            }
        }
        .formStyle(.grouped)
        .padding(24)
    }
}
