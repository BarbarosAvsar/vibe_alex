import SwiftUI

struct ToolbarStatusControl: View {
    let openSettings: () -> Void

    var body: some View {
        Button(action: openSettings) {
            Image(systemName: "gearshape.fill")
                .imageScale(.small)
                .padding(8)
                .background(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(Theme.surface)
                        .overlay(
                            LinearGradient(
                                colors: [
                                    Theme.accent.opacity(0.25),
                                    Theme.accentInfo.opacity(0.18)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .strokeBorder(Theme.border.opacity(0.8), lineWidth: 1)
                        )
                )
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Einstellungen öffnen")
    }
}
