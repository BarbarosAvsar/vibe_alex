import SwiftUI
import Charts

@MainActor
struct MetalsView: View {
    @Environment(AppState.self) private var appState
    @Binding var showSettings: Bool
    let onRequestConsultation: () -> Void
    @State private var selectedMetalID: String?

    var body: some View {
        NavigationStack {
            ScrollView {
                AsyncStateView(state: appState.dashboardState) {
                    Task { await appState.refreshDashboard(force: true) }
                } content: { snapshot in
                    VStack(spacing: 24) {
                        metalSelector(for: snapshot.metals)
                        if let focus = selectedMetal(from: snapshot.metals) {
                            MetalCard(asset: focus)
                            trendChart(for: focus, snapshot: snapshot)
                            bennerProjection(for: focus)
                            crisisResilience(for: focus, snapshot: snapshot)
                            WhyEdelmetalleSection()
                        }
                        PrimaryCTAButton(action: onRequestConsultation)
                    }
                    .padding()
                }
            }
            .navigationTitle("Edelmetalle")
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
            let activeID = selectedMetalID ?? metals.first?.id
            VStack(alignment: .leading, spacing: 8) {
                Text("Edelmetall auswählen")
                    .font(.headline)
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(metals) { metal in
                            Button {
                                selectedMetalID = metal.id
                            } label: {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(metal.name)
                                        .font(.subheadline.weight(.semibold))
                                    Text(metal.symbol)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                .padding(.horizontal, 14)
                                .padding(.vertical, 10)
                                .frame(minWidth: 120, alignment: .leading)
                                .background(selectionBackground(isActive: activeID == metal.id), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                                        .stroke(selectionBorder(isActive: activeID == metal.id), lineWidth: 1.5)
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
        }
    }

    private func selectionBackground(isActive: Bool) -> Color {
        isActive ? Theme.accent.opacity(0.15) : Theme.surface.opacity(0.2)
    }

    private func selectionBorder(isActive: Bool) -> Color {
        isActive ? Theme.accent : Theme.border.opacity(0.6)
    }

    @ViewBuilder
    private func bennerProjection(for metal: MetalAsset) -> some View {
        let projections = projectionEntries().prefix(3)
        DashboardSection("Prognose für 3 Jahre", subtitle: "\(metal.name) im Benner-Cycle Ausblick") {
            VStack(spacing: 12) {
                ForEach(projections) { entry in
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("\(entry.year)")
                                .font(.headline)
                            Text(entry.phase.subtitle)
                                .font(.caption)
                                .foregroundStyle(.secondary)
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
    private func trendChart(for metal: MetalAsset, snapshot: DashboardSnapshot) -> some View {
        let points = metalTrendPoints(for: metal)
        DashboardSection("Historisch & Prognose bis 2050", subtitle: "Indexentwicklung \(metal.name)") {
            Chart(points) { point in
                LineMark(
                    x: .value("Jahr", point.year),
                    y: .value("Index", point.value)
                )
                .interpolationMethod(.catmullRom)
                .foregroundStyle(point.isProjection ? Theme.accentStrong.opacity(0.8) : Theme.accentStrong)

                if point.isProjection {
                    AreaMark(
                        x: .value("Jahr", point.year),
                        y: .value("Index", point.value)
                    )
                    .interpolationMethod(.catmullRom)
                    .foregroundStyle(Theme.accentStrong.opacity(0.15))
                }
            }
            .frame(height: 260)
            .cardStyle()
        }
    }

    @ViewBuilder
    private func crisisResilience(for metal: MetalAsset, snapshot: DashboardSnapshot) -> some View {
        DashboardSection("Resilienz in Krisen", subtitle: "\(metal.name) in unterschiedlichen Szenarien") {
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
                            .foregroundStyle(.secondary)
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
        let currentYear = Calendar.current.component(.year, from: Date())
        let history = (0..<6).map { index -> MetalTrendPoint in
            let year = currentYear - (5 - index)
            let factor = 1 + (Double(index) * 0.03)
            let base = max(metal.price / 100, 25)
            return MetalTrendPoint(year: year, value: base * factor, isProjection: false)
        }
        let projections = appState.bennerCycleEntries
            .filter { $0.year >= currentYear }
            .prefix(5)
            .reduce(into: [MetalTrendPoint]()) { partial, entry in
                let lastValue = partial.last?.value ?? history.last?.value ?? metal.price / 10
                let nextValue = lastValue + lastValue * entry.phase.multiplier
                partial.append(MetalTrendPoint(year: entry.year, value: nextValue, isProjection: true))
            }
        return history + projections
    }

    private func scenarios(for metal: MetalAsset, snapshot: DashboardSnapshot) -> [CrisisScenario] {
        let inflation = snapshot.macroOverview.indicators.first(where: { $0.id == .inflation })?.latestValue ?? 0
        let growth = snapshot.macroOverview.indicators.first(where: { $0.id == .growth })?.latestValue ?? 0
        let defense = snapshot.macroOverview.indicators.first(where: { $0.id == .defense })?.latestValue ?? 0

        return [
            CrisisScenario(
                title: "Inflation",
                icon: "flame.fill",
                description: "\(metal.name) reagiert historisch positiv auf steigende Verbraucherpreise.",
                score: normalizedScore(from: inflation + metal.dailyChangePercentage),
                badgeText: inflation >= 0 ? "Schutz" : "Neutral"
            ),
            CrisisScenario(
                title: "Kriege",
                icon: "shield.lefthalf.filled",
                description: "Geopolitische Spannungen erhöhen die Nachfrage nach sicheren Häfen.",
                score: normalizedScore(from: defense + 5),
                badgeText: "Absicherung"
            ),
            CrisisScenario(
                title: "Wirtschaftskrisen",
                icon: "chart.line.downtrend.xyaxis",
                description: "In Rezessionen dient \(metal.name) als Liquiditätsreserve.",
                score: normalizedScore(from: -growth + 8),
                badgeText: "Diversifikation"
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
