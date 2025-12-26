import SwiftUI

struct WatchContentView: View {
    @Environment(AppState.self) private var appState
    @Environment(LanguageSettings.self) private var languageSettings

    var body: some View {
        NavigationStack {
            AsyncStateView(state: appState.dashboardState) {
                Task { await appState.refreshDashboard(force: true) }
            } content: { snapshot in
                List {
                    let language = languageSettings.selectedLanguage
                    if let entry = nextBennerEntry(from: appState.bennerCycleEntries) {
                        Section(Localization.text("overview_forecast_label", language: language)) {
                            Text("\(entry.year) \(entry.phase.localizedTitle(language: language))")
                                .font(.caption)
                            Text(Localization.format("benner_entry_summary", language: language, entry.year, entry.phase.localizedSubtitle(language: language)))
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                    }

                    Section(Localization.text("metals_title", language: language)) {
                        if snapshot.metals.isEmpty {
                            Text(Localization.text("comparison_no_data", language: language))
                        } else {
                            ForEach(snapshot.metals.prefix(2)) { metal in
                                HStack {
                                    Text(metal.localizedName(language: language))
                                    Spacer()
                                    Text(metal.price, format: .currency(code: metal.currency))
                                }
                            }
                        }
                    }

                    Section(Localization.text("overview_macro_title", language: language)) {
                        if snapshot.macroOverview.indicators.isEmpty {
                            Text(Localization.text("comparison_macro_no_data", language: language))
                        } else {
                            ForEach(snapshot.macroOverview.indicators.prefix(2)) { indicator in
                                HStack {
                                    Text(indicator.localizedTitle(language: language))
                                    Spacer()
                                    Text(indicator.localizedFormattedValue(language: language))
                                }
                                .font(.caption)
                            }
                        }
                    }

                    Section(Localization.text("crisis_title", language: language)) {
                        if snapshot.crises.isEmpty {
                            Text(Localization.text("crisis_feed_empty", language: language))
                        } else {
                            ForEach(snapshot.crises.prefix(2)) { event in
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(localizedCrisisEventTitle(event, language: language))
                                        .font(.caption)
                                    Text(event.localizedSeverityBadge(language: language))
                                        .font(.caption2)
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle(Localization.text("app_name", language: languageSettings.selectedLanguage))
        }
        .task {
            guard appState.hasLoadedOnce == false else { return }
            await appState.refreshDashboard(force: true)
        }
    }

    private func nextBennerEntry(from entries: [BennerCycleEntry]) -> BennerCycleEntry? {
        let currentYear = Calendar.current.component(.year, from: Date())
        return entries.first(where: { $0.year >= currentYear }) ?? entries.last
    }
}
