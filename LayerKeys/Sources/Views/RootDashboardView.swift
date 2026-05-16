import SwiftUI

private enum DashboardSection: String, CaseIterable, Identifiable {
    case overview
    case permissions
    case presets
    case licensing
    case updates
    case diagnostics

    var id: String { rawValue }

    var title: String {
        switch self {
        case .overview: return "Overview"
        case .permissions: return "Permissions"
        case .presets: return "Presets"
        case .licensing: return "Licensing"
        case .updates: return "Updates"
        case .diagnostics: return "Diagnostics"
        }
    }

    var systemImage: String {
        switch self {
        case .overview: return "sparkles"
        case .permissions: return "hand.raised"
        case .presets: return "keyboard"
        case .licensing: return "ticket"
        case .updates: return "arrow.triangle.2.circlepath"
        case .diagnostics: return "waveform.path.ecg"
        }
    }
}

struct RootDashboardView: View {
    @EnvironmentObject private var model: AppModel
    @State private var selection: DashboardSection? = .overview

    var body: some View {
        NavigationSplitView {
            List(DashboardSection.allCases, selection: $selection) { section in
                Label(section.title, systemImage: section.systemImage)
                    .tag(section)
            }
            .navigationSplitViewColumnWidth(min: 200, ideal: 220)
        } detail: {
            switch selection ?? .overview {
            case .overview:
                OverviewPane()
            case .permissions:
                PermissionsPane()
            case .presets:
                PresetsPane()
            case .licensing:
                LicensingPane()
            case .updates:
                UpdatesPane()
            case .diagnostics:
                InputTestPane()
            }
        }
        .onAppear {
            model.refreshRuntimeState()
        }
    }
}
