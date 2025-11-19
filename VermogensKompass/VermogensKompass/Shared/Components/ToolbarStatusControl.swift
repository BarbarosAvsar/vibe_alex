import SwiftUI

struct ToolbarStatusControl: View {
    let lastUpdated: Date?
    let openSettings: () -> Void

    var body: some View {
        HStack(spacing: 10) {
            if let lastUpdated {
                Text(lastUpdated, style: .time)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            } else {
                Text("–")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Button(action: openSettings) {
                Image(systemName: "gearshape.fill")
                    .imageScale(.small)
                    .padding(6)
                    .background(
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .fill(Theme.surface.opacity(0.2))
                    )
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Einstellungen öffnen")
        }
    }
}
