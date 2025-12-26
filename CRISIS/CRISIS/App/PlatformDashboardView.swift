import SwiftUI

struct PlatformDashboardView: View {
    @Environment(AppState.self) private var appState
    @Environment(CurrencySettings.self) private var currencySettings
    @Environment(LanguageSettings.self) private var languageSettings
    let onRequestConsultation: () -> Void

    var body: some View {
        ZStack {
            LiquidGlassBackground()
            ScrollView {
                AsyncStateView(state: appState.dashboardState) {
                    Task { await appState.refreshDashboard(force: true) }
                } content: { snapshot in
                    VStack(spacing: 24) {
                        AdaptiveStack(spacing: 24) {
                            column {
                                bennerSection(entries: appState.bennerCycleEntries)
                                metalsSection(snapshot.metals)
                            }

                            column {
                                macroSection(snapshot.macroOverview.indicators)
                                crisisSection(snapshot.crises)
                                WhyEdelmetalleSection()
                            }
                        }

                        PrimaryCTAButton(action: onRequestConsultation)
                    }
                    .padding()
                }
            }
        }
        .background(Theme.background)
        .refreshable {
            await appState.refreshDashboard(force: true)
        }
        .task {
            await currencySettings.refreshRates()
            guard appState.hasLoadedOnce == false else { return }
            await appState.refreshDashboard(force: true)
        }
    }

    private func column<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 24, content: content)
            .frame(maxWidth: .infinity, alignment: .leading)
    }

    @ViewBuilder
    private func bennerSection(entries: [BennerCycleEntry]) -> some View {
        if let entry = nextBennerEntry(from: entries) {
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
    private func metalsSection(_ metals: [MetalAsset]) -> some View {
        let language = languageSettings.selectedLanguage
        DashboardSection(
            Localization.text("metals_title", language: language),
            subtitle: Localization.text("overview_metals_focus_subtitle", language: language)
        ) {
            if metals.isEmpty {
                Text(Localization.text("comparison_no_data", language: language))
                    .font(.subheadline)
                    .foregroundStyle(Theme.textSecondary)
            } else {
                VStack(spacing: 12) {
                    ForEach(metals.prefix(2)) { asset in
                        MetalCard(asset: asset)
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func macroSection(_ indicators: [MacroIndicator]) -> some View {
        let language = languageSettings.selectedLanguage
        DashboardSection(
            Localization.text("overview_macro_title", language: language),
            subtitle: Localization.text("overview_macro_subtitle", language: language)
        ) {
            if indicators.isEmpty {
                Text(Localization.text("comparison_macro_no_data", language: language))
                    .font(.subheadline)
                    .foregroundStyle(Theme.textSecondary)
            } else {
                VStack(spacing: 12) {
                    ForEach(indicators) { indicator in
                        MacroRow(indicator: indicator)
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func crisisSection(_ events: [CrisisEvent]) -> some View {
        let language = languageSettings.selectedLanguage
        DashboardSection(
            Localization.text("crisis_feed_title", language: language),
            subtitle: Localization.text("crisis_feed_subtitle", language: language)
        ) {
            if events.isEmpty {
                Text(Localization.text("crisis_feed_empty", language: language))
                    .font(.subheadline)
                    .foregroundStyle(Theme.textSecondary)
            } else {
                VStack(spacing: 12) {
                    ForEach(events.prefix(3)) { event in
                        CrisisRow(event: event)
                    }
                }
            }
        }
    }

    private func nextBennerEntry(from entries: [BennerCycleEntry]) -> BennerCycleEntry? {
        let currentYear = Calendar.current.component(.year, from: Date())
        return entries.first(where: { $0.year >= currentYear }) ?? entries.last
    }
}

private struct MacroRow: View {
    let indicator: MacroIndicator
    @Environment(LanguageSettings.self) private var languageSettings

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(indicator.localizedTitle(language: languageSettings.selectedLanguage))
                    .font(.subheadline.weight(.semibold))
                Spacer()
                Text(indicator.localizedFormattedValue(language: languageSettings.selectedLanguage))
                    .font(.subheadline)
                    .foregroundStyle(Theme.textSecondary)
            }
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

private struct CrisisRow: View {
    let event: CrisisEvent
    @Environment(LanguageSettings.self) private var languageSettings

    var body: some View {
        let language = languageSettings.selectedLanguage
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .top) {
                Text(localizedCrisisEventTitle(event, language: language))
                    .font(.subheadline.weight(.semibold))
                Spacer()
                Text(event.localizedSeverityBadge(language: language))
                    .font(.caption2.weight(.semibold))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Theme.surface, in: Capsule())
            }
            Text(localizedWatchlistCountry(event.region, language: language))
                .font(.caption)
                .foregroundStyle(Theme.textMuted)
        }
        .padding()
        .background(
            Theme.surface.opacity(0.6),
            in: RoundedRectangle(cornerRadius: 18, style: .continuous)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .strokeBorder(Theme.border.opacity(0.3), lineWidth: 1)
        )
    }
}
