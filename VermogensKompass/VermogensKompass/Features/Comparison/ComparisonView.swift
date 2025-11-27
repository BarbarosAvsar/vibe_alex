import SwiftUI
import Charts

struct ComparisonView: View {
    @Environment(AppState.self) private var appState
    @Environment(CurrencySettings.self) private var currencySettings
    @Binding var showSettings: Bool
    private let comparisonEngine = AssetComparisonEngine()
    @State private var mode: ComparisonMode = .history
    @State private var activeAssets: Set<ComparisonAsset> = [.equityDE, .equityUSA, .gold]

    var body: some View {
        NavigationStack {
            ScrollView {
                AsyncStateView(state: appState.dashboardState) {
                    Task { await appState.refreshDashboard(force: true) }
                } content: { snapshot in
                    let series = comparisonEngine.makeAssets(from: snapshot, forecasts: appState.bennerCycleEntries)
                    VStack(spacing: 24) {
                        assetSelection(series)
                        comparisonChart(series)
                        performanceOverview(series)
                    }
                    .padding()
                }
            }
            .navigationTitle("Vergleich")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    LogoMark()
                }
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
    private func assetSelection(_ series: [ComparisonAssetSeries]) -> some View {
        DashboardSection("Asset-Klassen Vergleich", subtitle: "Historisch & Prognose 2025–2050") {
            Picker("Zeitraum", selection: $mode) {
                ForEach(ComparisonMode.allCases) { item in
                    Text(item.label).tag(item)
                }
            }
            .pickerStyle(.segmented)

            ForEach(AssetGroup.allCases, id: \.self) { group in
                VStack(alignment: .leading, spacing: 8) {
                    Text(group.rawValue)
                        .font(.subheadline.weight(.semibold))
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            ForEach(series.filter { $0.asset.group == group }) { item in
                                let isActive = activeAssets.contains(item.asset)
                                Button {
                                    if isActive {
                                        activeAssets.remove(item.asset)
                                    } else {
                                        activeAssets.insert(item.asset)
                                    }
                                } label: {
                                    HStack(spacing: 6) {
                                        Image(systemName: item.asset.icon)
                                        Text(item.asset.name)
                                    }
                                    .font(.subheadline.weight(.semibold))
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 10)
                                    .background(
                                        isActive ? Theme.accent.opacity(0.12) : Theme.surface.opacity(0.6),
                                        in: RoundedRectangle(cornerRadius: 14, style: .continuous)
                                    )
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                                            .strokeBorder(isActive ? Theme.accent.opacity(0.4) : Theme.border.opacity(0.4), lineWidth: 1)
                                    )
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func comparisonChart(_ series: [ComparisonAssetSeries]) -> some View {
        let selected = series.filter { activeAssets.contains($0.asset) }
        DashboardSection("Wertentwicklung", subtitle: "Tippen Sie auf den Chart um Details zu sehen") {
            AssetComparisonChart(series: selected, mode: mode, currency: currencySettings.selectedCurrency.code)
        }
    }

    @ViewBuilder
    private func performanceOverview(_ series: [ComparisonAssetSeries]) -> some View {
        let selected = series.filter { activeAssets.contains($0.asset) }
        DashboardSection("Performance Übersicht", subtitle: "Historisch und Prognose") {
            VStack(spacing: 12) {
                ForEach(selected) { item in
                    HStack {
                        Text(item.asset.name)
                            .font(.subheadline.weight(.semibold))
                        Spacer()
                        Text("Historisch \(cagr(for: item)) • Prognose \(projectionDelta(for: item))")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
    }

    private func cagr(for series: ComparisonAssetSeries) -> String {
        guard let first = series.history.first, let last = series.history.last, first.year != last.year else {
            return "–"
        }
        let years = Double(last.year - first.year)
        let growth = pow(max(last.value, 0.1) / max(first.value, 0.1), 1 / years) - 1
        return growth.formatted(.percent.precision(.fractionLength(1)))
    }

    private func projectionDelta(for series: ComparisonAssetSeries) -> String {
        guard let lastHistory = series.history.last,
              let lastProjection = series.projection.last else { return "–" }
        let delta = (lastProjection.value - lastHistory.value) / max(lastHistory.value, 0.1)
        return delta.formatted(.percent.precision(.fractionLength(1)))
    }
}

private struct AssetComparisonChart: View {
    let series: [ComparisonAssetSeries]
    let mode: ComparisonMode
    let currency: String

    private let colors: [ComparisonAsset: Color] = [
        .equityDE: Theme.accent,
        .equityUSA: Theme.accentStrong,
        .equityLON: Theme.accentInfo,
        .realEstateDE: Theme.accent.opacity(0.8),
        .realEstateES: Theme.accentStrong.opacity(0.8),
        .realEstateFR: Theme.accentInfo.opacity(0.8),
        .realEstateLON: Theme.accent.opacity(0.6),
        .gold: Theme.accentStrong,
        .silver: Theme.accentInfo
    ]

    var body: some View {
        let currentYear = Calendar.current.component(.year, from: Date())
        Chart {
            ForEach(series) { asset in
                if mode == .history {
                    ForEach(asset.history) { point in
                        LineMark(
                            x: .value("Jahr", point.year),
                            y: .value("Wert", point.value)
                        )
                        .interpolationMethod(.catmullRom)
                        .foregroundStyle(colors[asset.asset] ?? Theme.accent)
                    }
                } else {
                    ForEach(asset.projection) { point in
                        LineMark(
                            x: .value("Jahr", point.year),
                            y: .value("Wert", point.value)
                        )
                        .interpolationMethod(.catmullRom)
                        .foregroundStyle(colors[asset.asset] ?? Theme.accent)
                    }
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
        .chartYAxisLabel("Wert in \(currency)")
        .chartXScale(domain: xDomain)
        .chartYScale(domain: yDomain)
        .cardStyle()
    }

    private var xDomain: ClosedRange<Int> {
        let years = series.flatMap { mode == .history ? $0.history.map(\.year) : $0.projection.map(\.year) }
        let minY = years.min() ?? Calendar.current.component(.year, from: Date())
        let maxY = years.max() ?? minY
        return minY...maxY
    }

    private var yDomain: ClosedRange<Double> {
        let values = series.flatMap { mode == .history ? $0.history.map(\.value) : $0.projection.map(\.value) }
        let maxValue = values.max() ?? 100
        return 0...(maxValue * 1.1)
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
            Text("Prognose")
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
        case .forecast: return "Prognose"
        }
    }
}
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
