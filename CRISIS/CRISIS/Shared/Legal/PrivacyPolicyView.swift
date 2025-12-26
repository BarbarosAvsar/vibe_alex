import SwiftUI

struct PrivacyPolicyView: View {
    @Environment(LanguageSettings.self) private var languageSettings

    private var sections: [PrivacySection] {
        let language = languageSettings.selectedLanguage
        return [
            .init(
                title: Localization.text("privacy_section_controller_title", language: language),
                content: Localization.text("privacy_section_controller_body", language: language)
            ),
            .init(
                title: Localization.text("privacy_section_collection_title", language: language),
                content: Localization.text("privacy_section_collection_body", language: language)
            ),
            .init(
                title: Localization.text("privacy_section_contact_title", language: language),
                content: Localization.text("privacy_section_contact_body", language: language)
            ),
            .init(
                title: Localization.text("privacy_section_notifications_title", language: language),
                content: Localization.text("privacy_section_notifications_body", language: language)
            ),
            .init(
                title: Localization.text("privacy_section_tracking_title", language: language),
                content: Localization.text("privacy_section_tracking_body", language: language)
            ),
            .init(
                title: Localization.text("privacy_section_rights_title", language: language),
                content: Localization.text("privacy_section_rights_body", language: language)
            )
        ]
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    Text(Localization.text("privacy_policy_intro", language: languageSettings.selectedLanguage))
                        .font(.callout)
                        .foregroundStyle(Theme.textSecondary)
                        .multilineTextAlignment(.leading)

                    ForEach(sections) { section in
                        VStack(alignment: .leading, spacing: 8) {
                            Text(section.title)
                                .font(.headline)
                            Text(section.content)
                                .font(.subheadline)
                                .foregroundStyle(Theme.textMuted)
                        }
                        .cardStyle()
                    }
                }
                .padding()
            }
            .navigationTitle(Localization.text("privacy_policy_title", language: languageSettings.selectedLanguage))
            .toolbar {
                ToolbarItem(placement: AdaptiveToolbarPlacement.trailing) {
                    Link(Localization.text("privacy_policy_website", language: languageSettings.selectedLanguage), destination: URL(string: "https://vermoegenskompass.de/datenschutz")!)
                }
            }
        }
    }
}

private struct PrivacySection: Identifiable {
    let id = UUID()
    let title: String
    let content: String
}
