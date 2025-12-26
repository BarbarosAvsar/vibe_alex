import SwiftUI

struct VisionContentView: View {
    @State private var showConsultationSheet = false
    @Environment(LanguageSettings.self) private var languageSettings

    var body: some View {
        NavigationStack {
            PlatformDashboardView {
                showConsultationSheet = true
            }
            .navigationTitle(Localization.text("app_name", language: languageSettings.selectedLanguage))
            .toolbar {
                ToolbarItem(placement: AdaptiveToolbarPlacement.trailing) {
                    Button(Localization.text("tab_consultation", language: languageSettings.selectedLanguage)) {
                        showConsultationSheet = true
                    }
                }
            }
        }
        .sheet(isPresented: $showConsultationSheet) {
            ConsultationPanelView()
                .frame(minWidth: 500, minHeight: 500)
        }
    }
}
