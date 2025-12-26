import SwiftUI

struct MacContentView: View {
    @State private var selection: MacSection? = .dashboard
    @State private var showConsultationSheet = false
    @Environment(LanguageSettings.self) private var languageSettings

    var body: some View {
        NavigationSplitView {
            List(MacSection.allCases, selection: $selection) { section in
                Label(section.title(language: languageSettings.selectedLanguage), systemImage: section.systemImage)
                    .tag(section)
            }
            .navigationTitle(Localization.text("app_name", language: languageSettings.selectedLanguage))
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

    func title(language: AppLanguage) -> String {
        switch self {
        case .dashboard:
            return Localization.text("tab_overview", language: language)
        case .consultation:
            return Localization.text("tab_consultation", language: language)
        }
    }

    var systemImage: String {
        switch self {
        case .dashboard: return "house.fill"
        case .consultation: return "person.text.rectangle"
        }
    }
}
