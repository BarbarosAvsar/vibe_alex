import SwiftUI

struct MacContentView: View {
    @State private var selection: MacSection? = .dashboard
    @State private var showConsultationSheet = false

    var body: some View {
        NavigationSplitView {
            List(MacSection.allCases, selection: $selection) { section in
                Label(section.title, systemImage: section.systemImage)
                    .tag(section)
            }
            .navigationTitle("CRISIS")
        } detail: {
            switch selection ?? .dashboard {
            case .dashboard:
                PlatformDashboardView {
                    showConsultationSheet = true
                }
            case .consultation:
                ConsultationPanelView()
            }
        }
        .sheet(isPresented: $showConsultationSheet) {
            ConsultationPanelView()
                .frame(minWidth: 420, minHeight: 420)
        }
    }
}

private enum MacSection: String, CaseIterable, Identifiable {
    case dashboard
    case consultation

    var id: String { rawValue }

    var title: String {
        switch self {
        case .dashboard: return "Uebersicht"
        case .consultation: return "Beratung"
        }
    }

    var systemImage: String {
        switch self {
        case .dashboard: return "house.fill"
        case .consultation: return "person.text.rectangle"
        }
    }
}
