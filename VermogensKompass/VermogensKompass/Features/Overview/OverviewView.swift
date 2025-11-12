import SwiftUI

struct OverviewView: View {
    @Environment(AppState.self) private var appState
    @Binding var showMailSheet: Bool

    var body: some View {
        NavigationStack {
            ScrollView {
                AsyncStateView(state: appState.dashboardState) {
                    Task { await appState.refreshDashboard(force: true) }
                } content: { snapshot in
                    VStack(spacing: 24) {
                        heroSection(snapshot)
                        macroSection(snapshot)
                        PrimaryCTAButton(action: { showMailSheet = true })
                    }
                    .padding()
                }
            }
            .navigationTitle("Übersicht")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    if let lastUpdated = appState.lastUpdated {
                        Text(lastUpdated, style: .time)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .refreshable {
                await appState.refreshDashboard(force: true)
            }
        }
    }

    @ViewBuilder
    private func heroSection(_ snapshot: DashboardSnapshot) -> some View {
        DashboardSection("Marktpuls", subtitle: "Live-Daten von GoldPrice.org") {
            VStack(alignment: .leading, spacing: 12) {
                ForEach(snapshot.metals) { asset in
                    MetalCard(asset: asset)
                }
            }
        }
    }

    @ViewBuilder
    private func macroSection(_ snapshot: DashboardSnapshot) -> some View {
        DashboardSection("Makro-Lage", subtitle: "Weltbank-Indikatoren für Deutschland") {
            LazyVGrid(columns: [.init(.flexible()), .init(.flexible())], spacing: 16) {
                ForEach(snapshot.macroOverview.indicators) { indicator in
                    MetricCard(indicator: indicator)
                }
            }
        }
    }
}
