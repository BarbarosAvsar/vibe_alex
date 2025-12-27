import SwiftUI

@MainActor
struct SyncStatusBanner: View {
    let notice: SyncNotice
    @Environment(LanguageSettings.self) private var languageSettings

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "wifi.slash")
                .foregroundStyle(Theme.accentStrong)
                .imageScale(.large)
                .padding(8)
                .background(
                    Theme.accentStrong.opacity(0.12),
                    in: RoundedRectangle(cornerRadius: 14, style: .continuous)
                )

            VStack(alignment: .leading, spacing: 4) {
                Text(Localization.text("offline_banner_title", language: languageSettings.selectedLanguage))
                    .font(.headline)
                if let lastSync = notice.lastSuccessfulSync {
                    Text(Localization.format(
                        "sync_last_successful",
                        language: languageSettings.selectedLanguage,
                        formattedDate(lastSync)
                    ))
                        .font(.caption)
                        .foregroundStyle(Theme.textSecondary)
                } else {
                    Text(Localization.text("sync_never_successful", language: languageSettings.selectedLanguage))
                        .font(.caption)
                        .foregroundStyle(Theme.textSecondary)
                }
                Text(notice.errorDescription)
                    .font(.caption)
                    .foregroundStyle(Theme.textMuted)
            }
            Spacer()
        }
        .padding(14)
        .background(
            Theme.surface,
            in: RoundedRectangle(cornerRadius: 20, style: .continuous)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .strokeBorder(Theme.border.opacity(0.6), lineWidth: 1)
        )
    }

    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = languageSettings.selectedLanguage.locale
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}
