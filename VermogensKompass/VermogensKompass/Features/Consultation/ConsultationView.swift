import SwiftUI

struct ConsultationView: View {
    @Environment(AppState.self) private var appState
    @Binding var showPrivacyPolicy: Bool
    @State private var showConsultationForm = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    PrimaryCTAButton(action: { showConsultationForm = true })

                    Button {
                        showPrivacyPolicy = true
                    } label: {
                        Label("Datenschutzerklärung", systemImage: "lock.shield")
                            .font(.headline)
                            .foregroundStyle(Theme.textPrimary)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(
                                Theme.surface,
                                in: RoundedRectangle(cornerRadius: 18, style: .continuous)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 18, style: .continuous)
                                    .strokeBorder(Theme.border.opacity(0.5), lineWidth: 1)
                            )
                    }
                    .buttonStyle(.plain)

                    DashboardSection("Beratung", subtitle: "Konform zur App Store Review Guideline 5.1") {
                        VStack(alignment: .leading, spacing: 12) {
                            bullet(title: "Datenschutz", text: "Keine Daten werden ohne Einwilligung gespeichert; E-Mail startet in der Mail App.")
                            bullet(title: "Transparenz", text: "Alle Wirtschaftsdaten stammen aus frei zugänglichen APIs (GoldPrice.org, Weltbank, NOAA, USGS, World Bank Governance/Finance).")
                            bullet(title: "Barrierefreiheit", text: "Buttons sind sprachlich eindeutig, skalieren mit Dynamic Type und VoiceOver-Titeln.")
                        }
                        .cardStyle()
                    }

                    AsyncStateView(state: appState.dashboardState) {
                        Task { await appState.refreshDashboard(force: true) }
                    } content: { snapshot in
                        DashboardSection("Krisenvorbereitung", subtitle: "Letzte Ereignisse") {
                            ForEach(snapshot.crises) { event in
                                HStack {
                                    VStack(alignment: .leading) {
                                        Text(event.region)
                                            .font(.headline)
                                        Text(event.title)
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }
                                    Spacer()
                                    Text(event.severityBadge)
                                        .font(.caption2)
                                        .padding(6)
                                        .background(Theme.background, in: Capsule())
                                }
                                .padding(.vertical, 6)
                            }
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Beratung")
            .refreshable {
                await appState.refreshDashboard(force: true)
            }
            .navigationDestination(isPresented: $showConsultationForm) {
                ConsultationFormView()
            }
        }
    }

    private func bullet(title: String, text: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.headline)
            Text(text)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }
}
