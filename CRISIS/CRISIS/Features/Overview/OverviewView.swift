import SwiftUI

struct OverviewView: View {
    @Environment(AppState.self) private var appState
    @Environment(LanguageSettings.self) private var languageSettings
    @Binding var showSettings: Bool
    let onRequestConsultation: () -> Void
    @State private var selectedRegion: MacroRegion = .germany

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
                                    warningHero()
                                    metalFocusSection(snapshot)
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)

                                VStack(alignment: .leading, spacing: 24) {
                                    macroSection(snapshot)
                                    WhyEdelmetalleSection()
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                            }

                            PrimaryCTAButton(action: onRequestConsultation)
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle(Localization.text("overview_title", language: languageSettings.selectedLanguage))
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
    private func warningHero() -> some View {
        if let entry = nextBennerEntry(from: appState.bennerCycleEntries) {
            let language = languageSettings.selectedLanguage
            DashboardSection(
                Localization.text("overview_hero_title", language: language),
                subtitle: Localization.text("overview_hero_subtitle", language: language)
            ) {
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text(Localization.text("overview_forecast_label", language: language))
                            .font(.headline)
                            .foregroundStyle(Theme.textOnAccent)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(Theme.accentStrong, in: Capsule())
                        Spacer()
                        Text("\(entry.year)")
                            .font(.title3.weight(.semibold))
                    }
                    Text(Localization.format("benner_entry_summary", language: language, entry.year, entry.phase.localizedSubtitle(language: language)))
                        .font(.headline)
                    Text(Localization.text("overview_forecast_hint", language: language))
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
        let language = languageSettings.selectedLanguage
        DashboardSection(
            Localization.text("overview_metals_focus", language: language),
            subtitle: Localization.text("overview_metals_focus_subtitle", language: language)
        ) {
            VStack(alignment: .leading, spacing: 12) {
                ForEach(snapshot.metals.prefix(2)) { asset in
                    MetalCard(asset: asset)
                }
            }
        }
    }

    @ViewBuilder
    private func macroSection(_ snapshot: DashboardSnapshot) -> some View {
        let language = languageSettings.selectedLanguage
        DashboardSection(
            Localization.text("overview_macro_title", language: language),
            subtitle: Localization.text("overview_macro_subtitle", language: language)
        ) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(MacroRegion.allCases) { region in
                        Button {
                            selectedRegion = region
                        } label: {
                            Text(region.label(language: language))
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

    private func nextBennerEntry(from entries: [BennerCycleEntry]) -> BennerCycleEntry? {
        let currentYear = Calendar.current.component(.year, from: Date())
        return entries.first(where: { $0.year >= currentYear }) ?? entries.last
    }
}

private struct MacroKPI: View {
    let indicator: MacroIndicator
    let region: MacroRegion
    @Environment(LanguageSettings.self) private var languageSettings

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(indicator.localizedTitle(language: languageSettings.selectedLanguage))
                    .font(.headline)
                Spacer()
                Text(region.short(language: languageSettings.selectedLanguage))
                    .font(.caption.weight(.semibold))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Theme.accentInfo.opacity(0.4), in: Capsule())
            }
            Text(indicator.localizedFormattedValue(language: languageSettings.selectedLanguage))
                .font(.title3.weight(.semibold))
            Text(indicator.localizedDeltaDescription(language: languageSettings.selectedLanguage))
                .font(.caption)
                .foregroundStyle(Theme.textMuted)
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

    func label(language: AppLanguage) -> String {
        switch self {
        case .germany:
            return Localization.text("macro_region_de", language: language)
        case .usa:
            return Localization.text("macro_region_us", language: language)
        case .spain:
            return Localization.text("macro_region_es", language: language)
        case .uk:
            return Localization.text("macro_region_uk", language: language)
        }
    }

    func short(language: AppLanguage) -> String { label(language: language) }
}
