import SwiftUI
import Charts

struct ComparisonView: View {
    @Environment(AppState.self) private var appState

    var body: some View {
        NavigationStack {
            ScrollView {
                AsyncStateView(state: appState.dashboardState) {
                    Task { await appState.refreshDashboard(force: true) }
                } content: { snapshot in
                    VStack(spacing: 24) {
                        DashboardSection("Makro-Vergleich", subtitle: "World Bank Zeitreihen") {
                            Chart {
                                ForEach(snapshot.macroSeries) { series in
                                    ForEach(series.points) { point in
                                        LineMark(
                                            x: .value("Jahr", point.year),
                                            y: .value(series.kind.title, point.value)
                                        )
                                        .interpolationMethod(.catmullRom)
                                        .foregroundStyle(by: .value("Indikator", series.kind.title))
                                    }
                                }
                            }
                            .frame(height: 220)
                            .chartXAxisLabel("Jahr")
                            .chartYAxisLabel("%")
                            .cardStyle()
                        }

                        DashboardSection("Interpretation", subtitle: "Automatisierte Auswertung") {
                            VStack(alignment: .leading, spacing: 16) {
                                ForEach(snapshot.macroOverview.indicators) { indicator in
                                    HStack(alignment: .top, spacing: 12) {
                                        Image(systemName: icon(for: indicator.id))
                                            .foregroundStyle(Theme.accent)
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(indicator.title)
                                                .font(.headline)
                                            Text(indicator.deltaDescription)
                                                .font(.subheadline)
                                                .foregroundStyle(.secondary)
                                            Text(indicator.description)
                                                .font(.caption)
                                                .foregroundStyle(.secondary)
                                        }
                                    }
                                }
                            }
                            .cardStyle()
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Vergleich")
            .refreshable {
                await appState.refreshDashboard(force: true)
            }
        }
    }

    private func icon(for kind: MacroIndicatorKind) -> String {
        switch kind {
        case .inflation: return "flame.fill"
        case .growth: return "chart.line.uptrend.xyaxis"
        case .defense: return "shield.fill"
        }
    }
}
