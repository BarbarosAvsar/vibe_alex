import SwiftUI
import Charts

@MainActor
struct MetalsView: View {
    @Environment(AppState.self) private var appState
    @Environment(CurrencySettings.self) private var currencySettings
    @Environment(LanguageSettings.self) private var languageSettings
    @Binding var showSettings: Bool
    let onRequestConsultation: () -> Void
    @State private var selectedMetalID: String?
    @State private var metalHistories: [String: [MetalTrendPoint]] = [:]
    @State private var isLoadingHistory = false
    private let marketService = MarketDataService()

    var body: some View {
        NavigationStack {
            ZStack {
                LiquidGlassBackground()
                ScrollView {
                    AsyncStateView(state: appState.dashboardState) {
                        Task { await appState.refreshDashboard(force: true) }
                    } content: { snapshot in
                        VStack(spacing: 24) {
                            AdaptiveStack(spacing: 24) {
                                VStack(alignment: .leading, spacing: 24) {
                                    metalSelector(for: snapshot.metals)
                                    if let focus = selectedMetal(from: snapshot.metals) {
                                        MetalCard(asset: focus)
                                        bennerProjection(for: focus)
                                    }
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)

                                VStack(alignment: .leading, spacing: 24) {
                                    if let focus = selectedMetal(from: snapshot.metals) {
                                        trendChart(for: focus)
                                        crisisResilience(for: focus, snapshot: snapshot)
                                        WhyEdelmetalleSection()
                                    }
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                            }

                            PrimaryCTAButton(action: onRequestConsultation)
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle(Localization.text("metals_title", language: languageSettings.selectedLanguage))
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

    private func selectedMetal(from metals: [MetalAsset]) -> MetalAsset? {
        let fallback = metals.first
        if selectedMetalID == nil, let fallback {
            return fallback
        }
        return metals.first(where: { $0.id == selectedMetalID }) ?? fallback
    }

    @ViewBuilder
    private func metalSelector(for metals: [MetalAsset]) -> some View {
        if metals.isEmpty {
            EmptyView()
        } else {
            let language = languageSettings.selectedLanguage
            let activeID = selectedMetalID ?? metals.first?.id
            VStack(alignment: .leading, spacing: 10) {
                Text(Localization.text("metals_selector_title", language: language))
                    .font(.headline)
                HStack(spacing: 10) {
                    ForEach(metals) { metal in
                        let isActive = activeID == metal.id
                        Button {
                            selectedMetalID = metal.id
                        } label: {
                            HStack(spacing: 8) {
                                BrilliantDiamondIcon(size: 14)
                                Text(metal.localizedName(language: language))
                            }
                            .font(.subheadline.weight(.semibold))
                            .padding(.horizontal, 14)
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

    @ViewBuilder
    private func bennerProjection(for metal: MetalAsset) -> some View {
        let language = languageSettings.selectedLanguage
        let projections = projectionEntries().prefix(3)
        DashboardSection(
            Localization.text("metals_projection_title", language: language),
            subtitle: Localization.format("metals_projection_subtitle", language: language, metal.localizedName(language: language))
        ) {
            VStack(spacing: 12) {
                ForEach(projections) { entry in
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("\(entry.year)")
                                .font(.headline)
                            Text(entry.phase.localizedSubtitle(language: language))
                                .font(.caption)
                                .foregroundStyle(Theme.textSecondary)
                        }
                        Spacer()
                        ProgressView(value: entry.progress)
                            .progressViewStyle(.linear)
                            .tint(entry.phase.tint)
                            .frame(width: 120)
                    }
                    .padding()
                    .background(
                        entry.phase.tint.opacity(0.1),
                        in: RoundedRectangle(cornerRadius: 16, style: .continuous)
                    )
                }
            }
        }
    }

    @ViewBuilder
    private func trendChart(for metal: MetalAsset) -> some View {
        let language = languageSettings.selectedLanguage
        let history = metalHistories[metal.id]
        let points = metalTrendPoints(for: metal)
        DashboardSection(
            Localization.text("metals_trend_title", language: language),
            subtitle: Localization.format("metals_trend_subtitle", language: language, metal.localizedName(language: language))
        ) {
            if isLoadingHistory && history == nil {
                ProgressView(Localization.text("metals_trend_loading", language: language))
                    .frame(height: 240)
            } else {
                Chart(points) { point in
                    LineMark(
                        x: .value(Localization.text("comparison_chart_x_label", language: language), point.year),
                        y: .value(Localization.format("comparison_chart_y_label", language: language, currencySettings.selectedCurrency.code), point.value)
                    )
                    .interpolationMethod(.catmullRom)
                    .foregroundStyle(point.isProjection ? Theme.accentStrong.opacity(0.8) : Theme.accentStrong)

                    if point.isProjection {
                        AreaMark(
                            x: .value(Localization.text("comparison_chart_x_label", language: language), point.year),
                            y: .value(Localization.format("comparison_chart_y_label", language: language, currencySettings.selectedCurrency.code), point.value)
                        )
                        .interpolationMethod(.catmullRom)
                        .foregroundStyle(Theme.accentStrong.opacity(0.15))
                    }
                }
                .frame(height: 260)
                .chartXScale(domain: xDomain(points))
                .chartYScale(domain: yDomain(points))
                .chartYAxisLabel(Localization.format(
                    "comparison_chart_y_label",
                    language: language,
                    currencySettings.selectedCurrency.code
                ))
                .cardStyle()
            }
        }
        .task(id: metal.id) {
            await loadHistory(for: metal)
        }
    }

    @ViewBuilder
    private func crisisResilience(for metal: MetalAsset, snapshot: DashboardSnapshot) -> some View {
        let language = languageSettings.selectedLanguage
        DashboardSection(
            Localization.text("metals_resilience_title", language: language),
            subtitle: Localization.format("metals_resilience_subtitle", language: language, metal.localizedName(language: language))
        ) {
            VStack(spacing: 16) {
                ForEach(scenarios(for: metal, snapshot: snapshot)) { scenario in
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Label(scenario.title, systemImage: scenario.icon)
                                .font(.headline)
                            Spacer()
                            Text(scenario.badgeText)
                                .font(.caption.weight(.semibold))
                                .padding(.horizontal, 10)
                                .padding(.vertical, 4)
                                .background(Theme.surface, in: Capsule())
                        }
                        Text(scenario.description)
                            .font(.footnote)
                            .foregroundStyle(Theme.textMuted)
                        ProgressView(value: scenario.score)
                            .tint(Theme.accent)
                    }
                    .padding()
                    .background(
                        Theme.surface.opacity(0.4),
                        in: RoundedRectangle(cornerRadius: 18, style: .continuous)
                    )
                }
            }
        }
    }

    private func projectionEntries() -> [BennerCycleEntry] {
        let currentYear = Calendar.current.component(.year, from: Date())
        let nextWindow = currentYear...(currentYear + 5)
        return appState.bennerCycleEntries.filter { nextWindow.contains($0.year) }.prefix(5).map { $0 }
    }

    private func metalTrendPoints(for metal: MetalAsset) -> [MetalTrendPoint] {
        let history = metalHistories[metal.id] ?? []
        let currentYear = Calendar.current.component(.year, from: Date())
        let base = history.last?.value ?? max(convertedPrice(for: metal) / 100, 25)
        let projections = appState.bennerCycleEntries
            .filter { $0.year >= currentYear }
            .prefix(5)
            .reduce(into: [MetalTrendPoint]()) { partial, entry in
                let lastValue = partial.last?.value ?? base
                let nextValue = lastValue + lastValue * entry.phase.multiplier
                partial.append(MetalTrendPoint(year: entry.year, value: nextValue, isProjection: true))
            }
        return history + projections
    }

    @MainActor
    private func loadHistory(for metal: MetalAsset) async {
        guard metalHistories[metal.id] == nil, isLoadingHistory == false else { return }
        guard let instrument = metalInstrument(for: metal) else { return }
        isLoadingHistory = true
        defer { isLoadingHistory = false }

        if let points = try? await marketService.fetchHistory(for: instrument, limitYears: 10) {
            let mapped = points.map { MetalTrendPoint(year: $0.year, value: $0.value, isProjection: false) }
            metalHistories[metal.id] = mapped
        }
    }

    private func metalInstrument(for metal: MetalAsset) -> MarketInstrument? {
        switch metal.symbol.lowercased() {
        case "xau": return .xau
        case "xag": return .xag
        default: return nil
        }
    }

    private func convertedPrice(for metal: MetalAsset) -> Double {
        currencySettings.converter.convert(
            amount: metal.price,
            from: metal.currency,
            to: currencySettings.selectedCurrency
        )
    }

    private func xDomain(_ points: [MetalTrendPoint]) -> ClosedRange<Int> {
        let minYear = points.map(\.year).min() ?? Calendar.current.component(.year, from: Date())
        let maxYear = points.map(\.year).max() ?? minYear
        return minYear...maxYear
    }

    private func yDomain(_ points: [MetalTrendPoint]) -> ClosedRange<Double> {
        let maxValue = points.map(\.value).max() ?? 100
        return 0...(maxValue * 1.1)
    }

    private func scenarios(for metal: MetalAsset, snapshot: DashboardSnapshot) -> [CrisisScenario] {
        let language = languageSettings.selectedLanguage
        let inflation = snapshot.macroOverview.indicators.first(where: { $0.id == .inflation })?.latestValue ?? 0
        let growth = snapshot.macroOverview.indicators.first(where: { $0.id == .growth })?.latestValue ?? 0
        let defense = snapshot.macroOverview.indicators.first(where: { $0.id == .defense })?.latestValue ?? 0

        return [
            CrisisScenario(
                title: Localization.text("metals_scenario_inflation", language: language),
                icon: "flame.fill",
                description: Localization.format(
                    "metals_scenario_inflation_detail",
                    language: language,
                    metal.localizedName(language: language)
                ),
                score: normalizedScore(from: inflation + metal.dailyChangePercentage),
                badgeText: Localization.text("metals_badge_protection", language: language)
            ),
            CrisisScenario(
                title: Localization.text("metals_scenario_wars", language: language),
                icon: "shield.lefthalf.filled",
                description: Localization.text("metals_scenario_wars_detail", language: language),
                score: normalizedScore(from: defense + 5),
                badgeText: Localization.text("metals_badge_shield", language: language)
            ),
            CrisisScenario(
                title: Localization.text("metals_scenario_recession", language: language),
                icon: "chart.line.downtrend.xyaxis",
                description: Localization.format(
                    "metals_scenario_recession_detail",
                    language: language,
                    metal.localizedName(language: language)
                ),
                score: normalizedScore(from: -growth + 8),
                badgeText: Localization.text("metals_badge_diversification", language: language)
            )
        ]
    }

    private func normalizedScore(from value: Double) -> Double {
        let normalized = (value + 10) / 20
        return min(max(normalized, 0.05), 0.95)
    }
}

private struct CrisisScenario: Identifiable {
    let id = UUID()
    let title: String
    let icon: String
    let description: String
    let score: Double
    let badgeText: String
}

private struct MetalTrendPoint: Identifiable {
    let year: Int
    let value: Double
    let isProjection: Bool

    var id: Int { year }
}

private extension BennerPhase {
    var multiplier: Double {
        switch self {
        case .panic: return 0.08
        case .goodTimes: return 0.02
        case .hardTimes: return 0.03
        }
    }
}
