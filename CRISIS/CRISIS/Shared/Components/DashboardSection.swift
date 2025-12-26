import SwiftUI

struct DashboardSection<Content: View>: View {
    let title: String
    let subtitle: String
    @ViewBuilder var content: () -> Content

    init(_ title: String, subtitle: String = "", @ViewBuilder content: @escaping () -> Content) {
        self.title = title
        self.subtitle = subtitle
        self.content = content
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.title3).bold()
                if subtitle.isEmpty == false {
                    Text(subtitle)
                        .font(.footnote)
                        .foregroundStyle(Theme.textSecondary)
                }
            }
            content()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct WhyEdelmetalleSection: View {
    @Environment(LanguageSettings.self) private var languageSettings

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(Localization.text("why_metals_title", language: languageSettings.selectedLanguage))
                .font(.headline)
            VStack(alignment: .leading, spacing: 10) {
                bullet(text: Localization.text("why_metals_bullet_1", language: languageSettings.selectedLanguage))
                bullet(text: Localization.text("why_metals_bullet_2", language: languageSettings.selectedLanguage))
                bullet(text: Localization.text("why_metals_bullet_3", language: languageSettings.selectedLanguage))
                bullet(text: Localization.text("why_metals_bullet_4", language: languageSettings.selectedLanguage))
                bullet(text: Localization.text("why_metals_bullet_5", language: languageSettings.selectedLanguage))
            }
        }
        .padding()
        .background(
            Theme.accentInfo.opacity(0.24),
            in: RoundedRectangle(cornerRadius: 20, style: .continuous)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .strokeBorder(Theme.accent.opacity(0.12), lineWidth: 1)
        )
    }

    private func bullet(text: String) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(Theme.accent)
            Text(text)
                .font(.subheadline)
        }
    }
}
