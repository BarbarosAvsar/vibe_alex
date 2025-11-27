import SwiftUI

struct PrimaryCTAButton: View {
    let title: String
    let subtitle: String
    let icon: String
    let action: () -> Void

    init(title: String = "Beratung anfragen", subtitle: String = "Sichern Sie Ihr Vermögen mit Edelmetallen", icon: String = "paperplane.fill", action: @escaping () -> Void) {
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
                    Text(title)
                        .font(.headline)
                        .foregroundStyle(Theme.textOnAccent)
                Text(subtitle)
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
            LinearGradient(colors: [
                Theme.accentStrong,
                Theme.accentStrong.opacity(0.92)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing),
            in: RoundedRectangle(cornerRadius: 20, style: .continuous)
        )
        .accessibilityHint("Öffnet das Beratungsformular")
    }
    .buttonStyle(.plain)
    }
}
