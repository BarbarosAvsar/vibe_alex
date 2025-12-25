import SwiftUI

struct ConsultationPanelView: View {
    @Environment(\.openURL) private var openURL

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Beratung")
                    .font(.title2.bold())
                Text("Fuer eine individuelle Beratung nutzen Sie bitte das Kontaktformular auf der Website.")
                    .font(.subheadline)
                    .foregroundStyle(Theme.textSecondary)

                PrimaryCTAButton(action: openContactForm)
                    .frame(maxWidth: 320)
            }
            .padding()
        }
        .background(Theme.background)
    }

    private func openContactForm() {
        guard let url = URL(string: "https://vermoegenskompass.de") else { return }
        openURL(url)
    }
}
