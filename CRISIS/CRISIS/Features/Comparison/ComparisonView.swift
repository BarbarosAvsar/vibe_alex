import SwiftUI
import Charts

@MainActor
struct ComparisonView: View {
    @Environment(AppState.self) private var appState
    @Environment(CurrencySettings.self) private var currencySettings
    @Environment(LanguageSettings.self) private var languageSettings
    @Binding var showSettings: Bool
    private let comparisonEngine = AssetComparisonEngine()
    @State private var mode: ComparisonMode = .history
    @State private var activeAssets: Set<ComparisonAsset> = [.equityDE, .equityUSA, .gold]
    @State private var series: [ComparisonAssetSeries] = []
    @State private var isLoadingSeries = false

    var body: some View {
        NavigationStack {
            ZStack {
                LiquidGlassBackground()
                ScrollView {
                    AsyncStateView(state: appState.dashboardState) {
                        Task { await appState.refreshDashboard(force: true) }
                    } content: { _ in
                        AdaptiveStack(spacing: 24) {
                            VStack(alignment: .leading, spacing: 24) {
                                assetSelection(series)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)

                            VStack(alignment: .leading, spacing: 24) {
                                comparisonChart(series)
                                performanceOverview(series)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .padding()
                        .task(id: appState.lastUpdated ?? Date.distantPast) {
                            await loadSeries()
                        }
                    }
                }
            }
            .navigationTitle(Localization.text("comparison_title", language: languageSettings.selectedLanguage))
            .toolbar {
                ToolbarItem(placement: AdaptiveToolbarPlacement.leading) {
                    LogoMark()
                }
                ToolbarItem(placement: AdaptiveToolbarPlacement.trailing) {
                    ToolbarStatusControl {
                        showSettings = true
                    }
                }
            }
            .refreshable {
                await appState.refreshDashboard(force: true)
            }
            .background(Theme.background)
        }
    }

    @ViewBuilder
    private func assetSelection(_ series: [ComparisonAssetSeries]) -> some View {
        let language = languageSettings.selectedLanguage
        DashboardSection(
            Localization.text("comparison_section_title", language: language),
            subtitle: Localization.text("comparison_section_subtitle", language: language)
        ) {
            if isLoadingSeries && series.isEmpty {
                ProgressView(Localization.text("comparison_loading", language: language))
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            Picker(Localization.text("comparison_period", language: language), selection: $mode) {
                ForEach(ComparisonMode.allCases) { item in
                    Text(item.label(language: language)).tag(item)
                }
            }
            .pickerStyle(.segmented)

            ForEach(AssetGroup.allCases, id: \.self) { group in
                VStack(alignment: .leading, spacing: 8) {
                    Text(group.localizedLabel(language: language))
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
                                        assetIcon(for: item.asset)
                                        Text(item.asset.localizedName(language: language))
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
        let language = languageSettings.selectedLanguage
        let selected = series.filter { activeAssets.contains($0.asset) }
        DashboardSection(
            Localization.text("comparison_chart_title", language: language),
            subtitle: Localization.text("comparison_chart_subtitle", language: language)
        ) {
            let hasData = selected.contains { $0.history.isEmpty == false || $0.projection.isEmpty == false }
            if isLoadingSeries && hasData == false {
                ProgressView()
                    .frame(height: 240)
            } else if hasData == false {
                Text(Localization.text("comparison_no_data", language: language))
                    .font(.subheadline)
                    .foregroundStyle(Theme.textSecondary)
                    .frame(height: 240)
            } else {
                AssetComparisonChart(series: selected, mode: mode, currency: currencySettings.selectedCurrency.code)
            }
        }
    }

    @ViewBuilder
    private func performanceOverview(_ series: [ComparisonAssetSeries]) -> some View {
        let language = languageSettings.selectedLanguage
        let selected = series.filter { activeAssets.contains($0.asset) }
        DashboardSection(
            Localization.text("comparison_performance_title", language: language),
            subtitle: Localization.text("comparison_performance_subtitle", language: language)
        ) {
            let hasHistory = selected.contains { $0.history.isEmpty == false }
            if isLoadingSeries && hasHistory == false {
                ProgressView()
            } else if hasHistory == false {
                Text(Localization.text("comparison_no_data", language: language))
                    .font(.subheadline)
                    .foregroundStyle(Theme.textSecondary)
            } else {
                VStack(spacing: 12) {
                    ForEach(selected) { item in
                        HStack {
                            Text(item.asset.localizedName(language: language))
                                .font(.subheadline.weight(.semibold))
                            Spacer()
                            Text(Localization.format(
                                "comparison_performance_format",
                                language: language,
                                cagr(for: item),
                                projectionDelta(for: item)
                            ))
                                .font(.caption)
                                .foregroundStyle(Theme.textSecondary)
                        }
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func assetIcon(for asset: ComparisonAsset) -> some View {
        switch asset {
        case .gold:
            BrilliantDiamondIcon(size: 14)
        case .silver:
            Image(systemName: asset.icon)
        default:
            Image(systemName: asset.icon)
        }
    }

    @MainActor
    private func loadSeries() async {
        guard isLoadingSeries == false else { return }
        isLoadingSeries = true
        let loaded = await comparisonEngine.loadAssets(forecasts: appState.bennerCycleEntries)
        series = loaded
        isLoadingSeries = false
    }

    private func cagr(for series: ComparisonAssetSeries) -> String {
        guard let first = series.history.first, let last = series.history.last, first.year != last.year else {
            return Localization.text("not_available_short", language: languageSettings.selectedLanguage)
        }
        let years = Double(last.year - first.year)
        let growth = pow(max(last.value, 0.1) / max(first.value, 0.1), 1 / years) - 1
        let formatter = FloatingPointFormatStyle<Double>.percent
            .precision(.fractionLength(1))
            .locale(languageSettings.selectedLanguage.locale)
        return growth.formatted(formatter)
    }

    private func projectionDelta(for series: ComparisonAssetSeries) -> String {
        guard let lastHistory = series.history.last,
              let lastProjection = series.projection.last else {
            return Localization.text("not_available_short", language: languageSettings.selectedLanguage)
        }
        let delta = (lastProjection.value - lastHistory.value) / max(lastHistory.value, 0.1)
        let formatter = FloatingPointFormatStyle<Double>.percent
            .precision(.fractionLength(1))
            .locale(languageSettings.selectedLanguage.locale)
        return delta.formatted(formatter)
    }
}

private struct AssetComparisonChart: View {
    let series: [ComparisonAssetSeries]
    let mode: ComparisonMode
    let currency: String
    @Environment(LanguageSettings.self) private var languageSettings

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
        let language = languageSettings.selectedLanguage
        let currentYear = Calendar.current.component(.year, from: Date())
        Chart {
            ForEach(series) { asset in
                if mode == .history {
                    ForEach(asset.history) { point in
                        LineMark(
                            x: .value(Localization.text("comparison_chart_x_label", language: language), point.year),
                            y: .value(Localization.format("comparison_chart_y_label", language: language, currency), point.value)
                        )
                        .interpolationMethod(.catmullRom)
                        .foregroundStyle(colors[asset.asset] ?? Theme.accent)
                    }
                } else {
                    ForEach(asset.projection) { point in
                        LineMark(
                            x: .value(Localization.text("comparison_chart_x_label", language: language), point.year),
                            y: .value(Localization.format("comparison_chart_y_label", language: language, currency), point.value)
                        )
                        .interpolationMethod(.catmullRom)
                        .foregroundStyle(colors[asset.asset] ?? Theme.accent)
                    }
                }
            }
            RuleMark(x: .value(Localization.text("comparison_chart_today", language: language), currentYear))
                .lineStyle(StrokeStyle(lineWidth: 1, dash: [4, 4]))
                .annotation(position: .topTrailing) {
                    Text(Localization.text("comparison_chart_today", language: language))
                        .font(.caption2)
                        .foregroundStyle(Theme.textSecondary)
                }
        }
        .frame(height: 260)
        .chartXAxisLabel(Localization.text("comparison_chart_x_label", language: language))
        .chartYAxisLabel(Localization.format("comparison_chart_y_label", language: language, currency))
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
        guard let minValue = values.min(), let maxValue = values.max() else {
            return 0...100
        }
        let padding = (maxValue - minValue) * 0.1
        let lower = max(minValue - padding, 0)
        return lower...(maxValue + padding)
    }
}

private enum ComparisonMode: String, CaseIterable, Identifiable {
    case history
    case forecast

    var id: String { rawValue }

    func label(language: AppLanguage) -> String {
        switch self {
        case .history:
            return Localization.text("comparison_mode_history", language: language)
        case .forecast:
            return Localization.text("comparison_mode_forecast", language: language)
        }
    }
}


