import SwiftUI

@MainActor
struct PrimaryCTAButton: View {
    @Environment(LanguageSettings.self) private var languageSettings
    let title: String?
    let subtitle: String?
    let icon: String
    let action: () -> Void

    init(title: String? = nil, subtitle: String? = nil, icon: String = "paperplane.fill", action: @escaping () -> Void) {
        self.title = title
        self.subtitle = subtitle
        self.icon = icon
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            HStack(alignment: .center, spacing: 12) {
                Image(systemName: icon)
                    .font(.title3.weight(.bold))
                    .padding(10)
                    .background(
                        Theme.surface.opacity(0.9),
                        in: RoundedRectangle(cornerRadius: 12, style: .continuous)
                    )

                VStack(alignment: .leading, spacing: 2) {
                    Text(resolvedTitle)
                        .font(.headline)
                        .foregroundStyle(Theme.textOnAccent)
                    Text(resolvedSubtitle)
                        .font(.subheadline)
                        .foregroundStyle(Theme.textOnAccent.opacity(0.8))
                }
                Spacer()
                Image(systemName: "arrow.right")
                    .font(.headline)
                    .foregroundStyle(Theme.textOnAccent.opacity(0.8))
            }
            .padding()
            .background(
                LinearGradient(
                    colors: [
                        Theme.accentStrong,
                        Theme.accentStrong.opacity(0.92)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                in: RoundedRectangle(cornerRadius: 20, style: .continuous)
            )
            .accessibilityHint(Localization.text("cta_subtitle", language: languageSettings.selectedLanguage))
        }
        .buttonStyle(.plain)
    }

    private var resolvedTitle: String {
        title ?? Localization.text("cta_title", language: languageSettings.selectedLanguage)
    }

    private var resolvedSubtitle: String {
        subtitle ?? Localization.text("cta_subtitle", language: languageSettings.selectedLanguage)
    }
}
