import SwiftUI

struct SyncStatusBanner: View {
    let notice: SyncNotice

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
                Text("Offline-Daten")
                    .font(.headline)
                if let lastSync = notice.lastSuccessfulSync {
                    Text("Letzte Synchronisierung: \(lastSync.formatted(date: .abbreviated, time: .shortened))")
                        .font(.caption)
                        .foregroundStyle(Theme.textSecondary)
                } else {
                    Text("Noch keine erfolgreiche Synchronisierung")
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
}
