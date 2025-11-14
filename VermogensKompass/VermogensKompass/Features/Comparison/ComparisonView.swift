import SwiftUI
import Charts

struct ComparisonView: View {
    @Environment(AppState.self) private var appState
    private let insightEngine = MacroChartInsightEngine()

    var body: some View {
        NavigationStack {
            ScrollView {
                AsyncStateView(state: appState.dashboardState) {
                    Task { await appState.refreshDashboard(force: true) }
                } content: { snapshot in
                    VStack(spacing: 24) {
                        DashboardSection("Makro-Vergleich", subtitle: "World Bank Zeitreihen") {
                            let annotation = insightEngine.makeAnnotation(from: snapshot.macroSeries)
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
                                if let annotation {
                                    RuleMark(x: .value("Jahr", annotation.focusYear))
                                        .lineStyle(StrokeStyle(lineWidth: 1, dash: [4, 4]))
                                        .foregroundStyle(Theme.accent)
                                        .annotation(position: .topLeading) {
                                            MacroChartAnnotationView(annotation: annotation)
                                        }
                                }
                            }
                            .frame(height: 220)
                            .chartXAxisLabel("Jahr")
                            .chartYAxisLabel("%")
                            .chartLegend(.visible)
                            .cardStyle()

                            if let annotation {
                                MacroChartInsightCard(annotation: annotation)
                            }
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

private struct MacroChartAnnotationView: View {
    let annotation: MacroChartAnnotation

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: annotation.symbol)
                .foregroundStyle(annotation.delta >= 0 ? .green : .red)
            Text(annotation.message)
                .font(.caption)
                .foregroundStyle(.primary)
                .lineLimit(3)
        }
        .padding(8)
        .background(Color(.systemBackground).opacity(0.9), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
        .shadow(radius: 4, x: 0, y: 2)
    }
}

private struct MacroChartInsightCard: View {
    let annotation: MacroChartAnnotation

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Apple Intelligence Vorschau")
                .font(.caption)
                .foregroundStyle(.secondary)
            HStack(alignment: .top, spacing: 12) {
                Image(systemName: annotation.symbol)
                    .font(.title2.weight(.semibold))
                    .foregroundStyle(annotation.delta >= 0 ? .green : .red)
                VStack(alignment: .leading, spacing: 4) {
                    Text(annotation.indicator.title)
                        .font(.headline)
                    Text(annotation.message)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .cardStyle()
    }
}
