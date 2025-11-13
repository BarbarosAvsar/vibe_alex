import SwiftUI

struct SyncStatusBanner: View {
    let notice: SyncNotice

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "wifi.slash")
                .foregroundStyle(.yellow)
                .imageScale(.large)
                .padding(8)
                .background(Color.yellow.opacity(0.15), in: RoundedRectangle(cornerRadius: 14, style: .continuous))

            VStack(alignment: .leading, spacing: 4) {
                Text("Offline-Daten")
                    .font(.headline)
                if let lastSync = notice.lastSuccessfulSync {
                    Text("Letzte Synchronisierung: \(lastSync.formatted(date: .abbreviated, time: .shortened))")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                } else {
                    Text("Noch keine erfolgreiche Synchronisierung")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Text(notice.errorDescription)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
        }
        .padding(14)
        .background(
            Color.black.opacity(0.35),
            in: RoundedRectangle(cornerRadius: 20, style: .continuous)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .strokeBorder(Color.white.opacity(0.1), lineWidth: 1)
        )
    }
}
