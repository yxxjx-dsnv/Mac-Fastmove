import SwiftUI

struct LicensingPane: View {
    @EnvironmentObject private var model: AppModel
    @State private var errorMessage: String?

    var body: some View {
        Form {
            Section("Trial") {
                Text(model.trialDescription)
                    .font(.headline)
                Text("The local trial starts on first successful launch and lasts 7 calendar days.")
                    .foregroundStyle(.secondary)
            }

            Section("Purchase") {
                Text("\(AppConfig.appName) is designed for a low-friction one-time purchase flow with lightweight local activation.")
                    .foregroundStyle(.secondary)
                Button("Open Gumroad Purchase Page") {
                    model.openPurchasePage()
                }
            }

            Section("Activate or Restore") {
                TextField("Paste Gumroad purchase token", text: $model.licenseEntry)
                    .textFieldStyle(.roundedBorder)

                if let errorMessage {
                    Text(errorMessage)
                        .foregroundStyle(.red)
                }

                HStack {
                    Button("Activate") {
                        errorMessage = model.activateLicense()
                    }
                    Button("Clear Local License") {
                        model.clearLicense()
                    }
                    .disabled(model.licenseState == nil)
                }
            }
        }
        .formStyle(.grouped)
        .padding(24)
    }
}
