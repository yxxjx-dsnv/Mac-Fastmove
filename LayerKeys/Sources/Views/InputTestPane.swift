import SwiftUI

struct InputTestPane: View {
    @EnvironmentObject private var model: AppModel
    @State private var probeText = ""

    var body: some View {
        Form {
            Section("Engine") {
                Text(model.engineMessage)
                    .font(.headline)
                Text(lastActionLabel)
                    .foregroundStyle(.secondary)
            }

            Section("Input Probe") {
                TextField("Type here while testing your preset", text: $probeText, axis: .vertical)
                    .textFieldStyle(.roundedBorder)
                Text("Use this field while pressing Caps Lock, W, A, S, and D to confirm that the preset is active.")
                    .foregroundStyle(.secondary)
            }
        }
        .formStyle(.grouped)
        .padding(24)
    }

    private var lastActionLabel: String {
        "Last observed action: \(model.lastObservedAction)"
    }
}
