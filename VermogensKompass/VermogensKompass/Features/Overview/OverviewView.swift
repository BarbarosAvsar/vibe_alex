import SwiftUI

struct OverviewView: View {
    @Environment(AppState.self) private var appState
    @Binding var showSettings: Bool
    let onRequestConsultation: () -> Void
    @State private var selectedRegion: MacroRegion = .germany

    var body: some View {
        NavigationStack {
            ScrollView {
                AsyncStateView(state: appState.dashboardState) {
                    Task { await appState.refreshDashboard(force: true) }
                } content: { snapshot in
                    VStack(spacing: 24) {
                        warningHero()
                        bennerHighlightSection(appState.bennerCycleEntries)
                        metalFocusSection(snapshot)
                        macroSection(snapshot)
                        WhyEdelmetalleSection()
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
    private func warningHero() -> some View {
        if let entry = nextBennerEntry(from: appState.bennerCycleEntries) {
            DashboardSection("Vermögenssicherung", subtitle: "Historische Analyse & Benner-Prognose") {
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Label("Schwere Zeiten", systemImage: "exclamationmark.triangle.fill")
                            .font(.headline)
                            .foregroundStyle(Theme.textOnAccent)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(Theme.accentStrong, in: Capsule())
                        Spacer()
                        Text("\(entry.year)")
                            .font(.title3.weight(.semibold))
                    }
                    Text(entry.summary)
                        .font(.headline)
                    Text(entry.phase.guidance)
                        .font(.subheadline)
                        .foregroundStyle(Theme.textSecondary)
                    ProgressView(value: entry.progress)
                        .tint(entry.phase.tint)
                    Text("Benner-Cycle Prognose – Vorsicht geboten, Absicherung empfohlen.")
                        .font(.caption)
                        .foregroundStyle(Theme.textMuted)
                }
                .padding()
                .background(
                    Theme.surface,
                    in: RoundedRectangle(cornerRadius: 20, style: .continuous)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .strokeBorder(entry.phase.tint.opacity(0.3), lineWidth: 1)
                )
            }
        }
    }

    @ViewBuilder
    private func metalFocusSection(_ snapshot: DashboardSnapshot) -> some View {
        DashboardSection("Edelmetalle im Fokus", subtitle: "Gold & Silber im aktuellen Marktumfeld") {
            VStack(alignment: .leading, spacing: 12) {
                ForEach(snapshot.metals.prefix(2)) { asset in
                    MetalCard(asset: asset)
                }
            }
        }
    }

    @ViewBuilder
    private func macroSection(_ snapshot: DashboardSnapshot) -> some View {
        DashboardSection("Makro-Lage", subtitle: "Inflation, Wechsel & Wachstum je Region") {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(MacroRegion.allCases) { region in
                        Button {
                            selectedRegion = region
                        } label: {
                            Text(region.label)
                                .font(.subheadline.weight(.semibold))
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(
                                    selectedRegion == region ? Theme.accent.opacity(0.12) : Theme.surface.opacity(0.6),
                                    in: Capsule()
                                )
                                .overlay(
                                    Capsule()
                                        .strokeBorder(selectedRegion == region ? Theme.accent.opacity(0.4) : Theme.border.opacity(0.4), lineWidth: 1)
                                )
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.bottom, 4)
            }

            LazyVGrid(columns: [.init(.flexible()), .init(.flexible())], spacing: 16) {
                ForEach(snapshot.macroOverview.indicators) { indicator in
                    MacroKPI(indicator: indicator, region: selectedRegion)
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

private struct MacroKPI: View {
    let indicator: MacroIndicator
    let region: MacroRegion

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(indicator.title)
                    .font(.headline)
                Spacer()
                Text(region.short)
                    .font(.caption.weight(.semibold))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Theme.accentInfo.opacity(0.4), in: Capsule())
            }
            Text(indicator.formattedValue)
                .font(.title3.weight(.semibold))
            Text(indicator.deltaDescription)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(
            Theme.surface.opacity(0.6),
            in: RoundedRectangle(cornerRadius: 16, style: .continuous)
        )
    }
}

private enum MacroRegion: String, CaseIterable, Identifiable {
    case germany, usa, spain, uk

    var id: String { rawValue }

    var label: String {
        switch self {
        case .germany: return "DE"
        case .usa: return "USA"
        case .spain: return "ES"
        case .uk: return "UK"
        }
    }

    var short: String { label }
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
