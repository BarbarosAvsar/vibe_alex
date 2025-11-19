import SwiftUI

struct OverviewView: View {
    @Environment(AppState.self) private var appState
    @Binding var showSettings: Bool
    let onRequestConsultation: () -> Void

    var body: some View {
        NavigationStack {
            ScrollView {
                AsyncStateView(state: appState.dashboardState) {
                    Task { await appState.refreshDashboard(force: true) }
                } content: { snapshot in
                    VStack(spacing: 24) {
                        bennerHighlightSection(appState.bennerCycleEntries)
                        bennerCycleSection(appState.bennerCycleEntries)
                        heroSection(snapshot)
                        macroSection(snapshot)
                        PrimaryCTAButton(action: onRequestConsultation)
                    }
                    .padding()
                }
            }
            .navigationTitle("Übersicht")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    ToolbarStatusControl(lastUpdated: appState.lastUpdated) {
                        showSettings = true
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

    @ViewBuilder
    private func bennerCycleSection(_ entries: [BennerCycleEntry]) -> some View {
        DashboardSection("Benner Cycle", subtitle: "Samuel Benner Prognose bis 2150") {
            BennerCycleView(entries: entries)
        }
    }

    @ViewBuilder
    private func bennerHighlightSection(_ entries: [BennerCycleEntry]) -> some View {
        if let entry = nextBennerEntry(from: entries) {
            DashboardSection("Nächste Prognose", subtitle: "Fokusjahr des Benner-Zyklus") {
                BennerNextForecastCard(entry: entry)
            }
        }
    }

    private func nextBennerEntry(from entries: [BennerCycleEntry]) -> BennerCycleEntry? {
        let currentYear = Calendar.current.component(.year, from: Date())
        return entries.first(where: { $0.year >= currentYear }) ?? entries.last
    }
}

private struct BennerNextForecastCard: View {
    let entry: BennerCycleEntry

    private var badgeText: String {
        switch entry.phase {
        case .panic: return "Panik"
        case .goodTimes: return "Aufschwung"
        case .hardTimes: return "Kaufphase"
        }
    }

    private var badgeColor: Color {
        switch entry.phase {
        case .panic: return Theme.accentStrong
        case .goodTimes: return Theme.accent
        case .hardTimes: return Theme.border
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Jahr \(entry.year)")
                    .font(.title3.weight(.semibold))
                Spacer()
                Text(badgeText)
                    .font(.caption.weight(.semibold))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(badgeColor.opacity(0.15), in: Capsule())
                    .overlay(
                        Capsule()
                            .stroke(badgeColor.opacity(0.4), lineWidth: 1)
                    )
            }
            Text(entry.summary)
                .font(.headline)
            Text(entry.phase.guidance)
                .font(.subheadline)
                .foregroundStyle(Theme.textSecondary)
            ProgressView(value: entry.progress)
                .tint(badgeColor)
            Text("Basierend auf Samuel Benner Forecast bis 2150.")
                .font(.caption)
                .foregroundStyle(Theme.textMuted)
        }
        .cardStyle()
    }
}
