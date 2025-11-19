import SwiftUI
import Charts

struct ComparisonView: View {
    @Environment(AppState.self) private var appState
    @Binding var showSettings: Bool
    @State private var selectedCategory: AssetCategory = .internationalEquities
    private let comparisonEngine = AssetComparisonEngine()

    var body: some View {
        NavigationStack {
            ScrollView {
                AsyncStateView(state: appState.dashboardState) {
                    Task { await appState.refreshDashboard(force: true) }
                } content: { snapshot in
                    let series = comparisonEngine.makeSeries(from: snapshot, bennerEntries: appState.bennerCycleEntries)
                    VStack(spacing: 24) {
                        if let selectedSeries = selectedSeries(in: series) {
                            assetComparisonSection(series, selectedSeries: selectedSeries)
                            appleAISection(for: selectedSeries)
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Vergleich")
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

    private func selectedSeries(in series: [AssetComparisonSeries]) -> AssetComparisonSeries? {
        series.first(where: { $0.category == selectedCategory }) ?? series.first
    }

    @ViewBuilder
    private func assetComparisonSection(_ series: [AssetComparisonSeries], selectedSeries: AssetComparisonSeries) -> some View {
        DashboardSection("Asset-Vergleich", subtitle: "Internationale Aktien, Immobilienmärkte und Edelmetalle") {
            Picker("Asset-Kategorie", selection: $selectedCategory) {
                ForEach(series.map(\.category), id: \.self) { category in
                    Text(category.title).tag(category)
                }
            }
            .pickerStyle(.segmented)

            Text(selectedSeries.category.subtitle)
                .font(.caption)
                .foregroundStyle(.secondary)

            AssetComparisonChart(series: selectedSeries)

            HStack(spacing: 12) {
                ComparisonStatCard(title: "CAGR", value: cagr(for: selectedSeries))
                ComparisonStatCard(title: "Prognose 2150", value: projectionDelta(for: selectedSeries))
                ComparisonStatCard(title: "Benner-Phase", value: nextPhaseLabel())
            }
        }
    }

    @ViewBuilder
    private func appleAISection(for series: AssetComparisonSeries) -> some View {
        DashboardSection("Apple Intelligence Auswertung", subtitle: "Automatisierte Interpretation der Benner-Prognosen") {
            AssetAISummaryView(summary: aiSummary(for: series))
        }
    }

    private func cagr(for series: AssetComparisonSeries) -> String {
        guard let first = series.history.first, let last = series.history.last, first.year != last.year else {
            return "–"
        }
        let years = Double(last.year - first.year)
        let growth = pow(max(last.value, 0.1) / max(first.value, 0.1), 1 / years) - 1
        return growth.formatted(.percent.precision(.fractionLength(1)))
    }

    private func projectionDelta(for series: AssetComparisonSeries) -> String {
        guard let lastHistory = series.history.last,
              let lastProjection = series.projection.last else { return "–" }
        let delta = (lastProjection.value - lastHistory.value) / max(lastHistory.value, 0.1)
        return delta.formatted(.percent.precision(.fractionLength(1)))
    }

    private func nextPhaseLabel() -> String {
        let currentYear = Calendar.current.component(.year, from: Date())
        guard let nextEntry = appState.bennerCycleEntries.first(where: { $0.year >= currentYear }) else {
            return "–"
        }
        return "\(nextEntry.phase.title) \(nextEntry.year)"
    }

    private func aiSummary(for series: AssetComparisonSeries) -> AssetAISummary {
        let nextEntry = nextBennerEntry()
        let tone: String
        switch nextEntry?.phase {
        case .panic:
            tone = "Defensiver Modus empfohlen – Panikphase im Benner-Zyklus."
        case .goodTimes:
            tone = "Gewinne sichern: Good Times stehen laut Forecast bevor."
        case .hardTimes:
            tone = "Aufbauphase – Hard Times begünstigen selektive Käufe."
        case .none:
            tone = "Langfristige Orientierung behalten."
        }

        let projectionText: String
        if let lastProjection = series.projection.last {
            projectionText = "Die Benner-Prognose reicht bis \(lastProjection.year) und sieht einen Indexwert von \(lastProjection.value.formatted(.number.precision(.fractionLength(1)))) vor."
        } else {
            projectionText = "Keine Prognosedaten verfügbar."
        }

        let riskText: String
        if let minProjection = series.projection.min(by: { $0.value < $1.value }) {
            riskText = "Tiefpunkt laut Modell: Jahr \(minProjection.year) mit Index \(minProjection.value.formatted(.number.precision(.fractionLength(1))))"
        } else {
            riskText = "Benner-Modell signalisiert stabile Entwicklung."
        }

        return AssetAISummary(
            headline: "Apple Intelligence Insight",
            tone: tone,
            projection: projectionText,
            risk: riskText
        )
    }

    private func nextBennerEntry() -> BennerCycleEntry? {
        let currentYear = Calendar.current.component(.year, from: Date())
        return appState.bennerCycleEntries.first(where: { $0.year >= currentYear })
    }
}

private struct AssetComparisonChart: View {
    let series: AssetComparisonSeries

    private var color: Color {
        switch series.category {
        case .internationalEquities: return Theme.accent
        case .realEstate: return Theme.border
        case .preciousMetals: return Theme.accentStrong
        }
    }

    var body: some View {
        let currentYear = Calendar.current.component(.year, from: Date())
        Chart {
            ForEach(series.history) { point in
                LineMark(
                    x: .value("Jahr", point.year),
                    y: .value("Index", point.value)
                )
                .interpolationMethod(.catmullRom)
                .foregroundStyle(color)
            }
            ForEach(series.projection) { point in
                LineMark(
                    x: .value("Jahr", point.year),
                    y: .value("Index", point.value)
                )
                .lineStyle(StrokeStyle(lineWidth: 2, dash: [6, 3]))
                .foregroundStyle(color.opacity(0.8))
            }
            RuleMark(x: .value("Heute", currentYear))
                .lineStyle(StrokeStyle(lineWidth: 1, dash: [4, 4]))
                .annotation(position: .topTrailing) {
                    Text("Heute")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
        }
        .frame(height: 260)
        .chartXAxisLabel("Jahr")
        .chartYAxisLabel("Index (Basis=100)")
        .chartYScale(domain: chartDomain)
        .cardStyle()
    }

    private var chartDomain: ClosedRange<Double> {
        let allValues = (series.history + series.projection).map(\.value)
        var minValue = (allValues.min() ?? 0) - 5
        var maxValue = (allValues.max() ?? 0) + 5
        if maxValue - minValue < 5 {
            minValue -= 2
            maxValue += 2
        }
        return minValue...maxValue
    }
}

private struct ComparisonStatCard: View {
    let title: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title.uppercased())
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.title3.weight(.semibold))
            Text("Benner-Modell")
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(
            Theme.surface.opacity(0.5),
            in: RoundedRectangle(cornerRadius: 16, style: .continuous)
        )
    }
}

private struct AssetAISummary {
    let headline: String
    let tone: String
    let projection: String
    let risk: String
}

private struct AssetAISummaryView: View {
    let summary: AssetAISummary

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(summary.headline)
                .font(.headline)
            Label(summary.tone, systemImage: "sparkles")
                .font(.subheadline)
            Divider()
            Label(summary.projection, systemImage: "chart.line.uptrend.xyaxis")
                .font(.footnote)
                .foregroundStyle(.secondary)
            Label(summary.risk, systemImage: "exclamationmark.triangle")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(
            Theme.surface.opacity(0.45),
            in: RoundedRectangle(cornerRadius: 20, style: .continuous)
        )
    }
}
