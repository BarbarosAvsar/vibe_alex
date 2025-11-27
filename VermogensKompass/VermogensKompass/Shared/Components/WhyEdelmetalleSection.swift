import SwiftUI

struct WhyEdelmetalleSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Warum Edelmetalle und Struktur")
                .font(.headline)
            VStack(alignment: .leading, spacing: 10) {
                bullet(text: "Physischer Wert, unabhängig von Währungen")
                bullet(text: "Schutz vor Inflation und Kaufkraftverlust")
                bullet(text: "Stabilität in Kriegen und Wirtschaftskrisen")
                bullet(text: "Strukturierter Vermögensschutz durch planbare Allokation")
                bullet(text: "Sichere Lagerung im Zollfreilager außerhalb des Bankensystems")
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

#Preview {
    WhyEdelmetalleSection()
        .padding()
}
