import SwiftUI

struct ConsultationPanelView: View {
    @Environment(\.openURL) private var openURL
    @Environment(LanguageSettings.self) private var languageSettings

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text(Localization.text("tab_consultation", language: languageSettings.selectedLanguage))
                    .font(.title2.bold())
                Text(Localization.text("consultation_panel_subtitle", language: languageSettings.selectedLanguage))
                    .font(.subheadline)
                    .foregroundStyle(Theme.textSecondary)

                PrimaryCTAButton(action: openContactForm)
                    .frame(maxWidth: 320)
            }
            .padding()
        }
        .background(Theme.background)
    }

    private func openContactForm() {
        guard let url = URL(string: "https://vermoegenskompass.de") else { return }
        openURL(url)
    }
}
