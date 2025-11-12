import SwiftUI

struct MetalsView: View {
    @Environment(AppState.self) private var appState
    @Binding var showMailSheet: Bool

    var body: some View {
        NavigationStack {
            ScrollView {
                AsyncStateView(state: appState.dashboardState) {
                    Task { await appState.refreshDashboard(force: true) }
                } content: { snapshot in
                    VStack(spacing: 24) {
                        ForEach(snapshot.metals) { asset in
                            MetalCard(asset: asset)
                        }

                        DashboardSection("Warum physische Edelmetalle?", subtitle: "Regelbasiert aus den aktuellen Daten") {
                            VStack(alignment: .leading, spacing: 12) {
                                bullet(icon: "checkmark.circle.fill", text: "Inflationsschutz: \(snapshot.macroOverview.indicators.first(where: { $0.id == .inflation })?.formattedValue ?? "–")")
                                bullet(icon: "checkmark.circle.fill", text: "Konjunkturdiversifikation über reale Werte")
                                bullet(icon: "checkmark.circle.fill", text: "Unabhängig vom Finanzsystem dank physischer Lagerung")
                            }
                            .cardStyle()
                        }

                        PrimaryCTAButton(action: { showMailSheet = true })
                    }
                    .padding()
                }
            }
            .navigationTitle("Edelmetalle")
            .refreshable {
                await appState.refreshDashboard(force: true)
            }
        }
    }

    private func bullet(icon: String, text: String) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: icon)
                .foregroundStyle(Theme.accent)
            Text(text)
                .font(.subheadline)
        }
    }
}
