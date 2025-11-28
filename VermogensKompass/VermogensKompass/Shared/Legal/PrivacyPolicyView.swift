import SwiftUI

struct PrivacyPolicyView: View {
    private let sections: [PrivacySection] = [
        .init(
            title: "Verantwortliche Stelle",
            content: "VermögensKompass (Vibecode GmbH) verarbeitet ausschließlich die Daten, die Sie aktiv teilen."
        ),
        .init(
            title: "Datenerhebung im Überblick",
            content: """
            • Markt- und Krisendaten stammen aus offen zugänglichen APIs (World Bank, USGS, NOAA, GoldPrice.org) und werden nur lokal ausgewertet.
            • Wir speichern keine personenbezogenen Daten auf unseren Servern.
            """
        ),
        .init(
            title: "Kontaktaufnahme",
            content: "Tippen Sie auf „Beratung anfragen“, öffnet sich die Apple Mail App mit einer vorformulierten Nachricht. Der Versand erfolgt über Ihr E-Mail-Konto; wir speichern dabei keine Kopie."
        ),
        .init(
            title: "Benachrichtigungen",
            content: "Krisen-Benachrichtigungen werden ausschließlich auf Ihrem Gerät verarbeitet. Sie können die Berechtigung jederzeit in den iOS-Einstellungen widerrufen."
        ),
        .init(
            title: "Analytics & Tracking",
            content: "Kein Tracking, keine Drittanbieter-SDKs. Die App funktioniert vollständig offline mit den zuletzt synchronisierten Daten."
        ),
        .init(
            title: "Ihre Rechte",
            content: "Sie können Auskunft, Berichtigung oder Löschung Ihrer Kontaktaufnahme verlangen, indem Sie uns unter datenschutz@vermoegenskompass.de kontaktieren."
        )
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    Text("Wir verarbeiten Ihre Daten ausschließlich auf dem Gerät oder über Apple Mail. Es gibt keine versteckten Tracker oder Cloud-Profile.")
                        .font(.callout)
                        .foregroundStyle(Theme.textSecondary)
                        .multilineTextAlignment(.leading)

                    ForEach(sections) { section in
                        VStack(alignment: .leading, spacing: 8) {
                            Text(section.title)
                                .font(.headline)
                            Text(section.content)
                                .font(.subheadline)
                                .foregroundStyle(Theme.textMuted)
                        }
                        .cardStyle()
                    }
                }
                .padding()
            }
            .navigationTitle("Datenschutzerklärung")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Link("Website", destination: URL(string: "https://vermoegenskompass.de/datenschutz")!)
                }
            }
        }
    }
}

private struct PrivacySection: Identifiable {
    let id = UUID()
    let title: String
    let content: String
}
