import SwiftUI
import Charts

struct ComparisonView: View {
    @Environment(AppState.self) private var appState
    @Binding var showSettings: Bool
    @State private var selectedCategory: AssetCategory = .internationalEquities
    @State private var mode: ComparisonMode = .history
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
                            performanceOverview(for: selectedSeries)
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
        DashboardSection("Asset-Klassen Vergleich", subtitle: "Historische Entwicklung und Prognose bis 2050") {
            Picker("Zeitraum", selection: $mode) {
                ForEach(ComparisonMode.allCases) { item in
                    Text(item.label).tag(item)
                }
            }
            .pickerStyle(.segmented)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(series.map(\.category), id: \.self) { category in
                        Button {
                            selectedCategory = category
                        } label: {
                            HStack(spacing: 6) {
                                Image(systemName: category.icon)
                                Text(category.title)
                            }
                            .font(.subheadline.weight(.semibold))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 10)
                            .background(
                                selectedCategory == category ? Theme.accent.opacity(0.12) : Theme.surface.opacity(0.6),
                                in: RoundedRectangle(cornerRadius: 14, style: .continuous)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 14, style: .continuous)
                                    .strokeBorder(selectedCategory == category ? Theme.accent.opacity(0.4) : Theme.border.opacity(0.4), lineWidth: 1)
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.bottom, 4)
            }

            Text(selectedSeries.category.subtitle)
                .font(.caption)
                .foregroundStyle(.secondary)

            AssetComparisonChart(series: selectedSeries, mode: mode)
        }
    }

    @ViewBuilder
    private func performanceOverview(for series: AssetComparisonSeries) -> some View {
        DashboardSection("Performance Übersicht", subtitle: "Historisch, Prognose und Benner-Phase") {
            VStack(spacing: 12) {
                HStack(spacing: 12) {
                    ComparisonStatCard(title: "Historische Rendite", value: cagr(for: series))
                    ComparisonStatCard(title: "Prognose 2050", value: projectionDelta(for: series))
                }
                ComparisonStatCard(title: "Nächste Benner-Phase", value: nextPhaseLabel())
            }
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
}

private struct AssetComparisonChart: View {
    let series: AssetComparisonSeries
    let mode: ComparisonMode

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
            if mode == .history {
                ForEach(series.history) { point in
                    LineMark(
                        x: .value("Jahr", point.year),
                        y: .value("Index", point.value)
                    )
                    .interpolationMethod(.catmullRom)
                    .foregroundStyle(color)
                }
            } else {
                ForEach(series.projection) { point in
                    LineMark(
                        x: .value("Jahr", point.year),
                        y: .value("Index", point.value)
                    )
                    .interpolationMethod(.catmullRom)
                    .foregroundStyle(color)
                }
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
        let values = mode == .history ? series.history : series.projection
        let allValues = values.map(\.value)
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

private enum ComparisonMode: String, CaseIterable, Identifiable {
    case history
    case forecast

    var id: String { rawValue }

    var label: String {
        switch self {
        case .history: return "Historisch"
        case .forecast: return "Prognose 2025–2050"
        }
    }
}
