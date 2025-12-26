import SwiftUI

struct MetricCard: View {
    let indicator: MacroIndicator
    @Environment(LanguageSettings.self) private var languageSettings

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(indicator.localizedTitle(language: languageSettings.selectedLanguage))
                    .font(.subheadline)
                    .bold()
                Spacer()
                Text(indicator.source.rawValue)
                    .font(.caption)
                    .foregroundStyle(Theme.textSecondary)
            }
            Text(indicator.localizedFormattedValue(language: languageSettings.selectedLanguage))
                .font(.largeTitle.weight(.semibold))
            Spacer(minLength: 0)
            Text(indicator.localizedDeltaDescription(language: languageSettings.selectedLanguage))
                .font(.caption)
                .foregroundStyle(Theme.textSecondary)
            Text(indicator.localizedDescription(language: languageSettings.selectedLanguage))
                .font(.caption)
                .foregroundStyle(Theme.textMuted)
        }
        .frame(maxWidth: .infinity, minHeight: 170, alignment: .topLeading)
        .cardStyle()
    }
}
