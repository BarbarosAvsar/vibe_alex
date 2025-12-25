import SwiftUI

struct WatchContentView: View {
    @Environment(AppState.self) private var appState

    var body: some View {
        NavigationStack {
            AsyncStateView(state: appState.dashboardState) {
                Task { await appState.refreshDashboard(force: true) }
            } content: { snapshot in
                List {
                    if let entry = nextBennerEntry(from: appState.bennerCycleEntries) {
                        Section("Benner") {
                            Text("\(entry.year) \(entry.phase.title)")
                                .font(.caption)
                            Text(entry.summary)
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                    }

                    Section("Metalle") {
                        if snapshot.metals.isEmpty {
                            Text("Keine Daten.")
                        } else {
                            ForEach(snapshot.metals.prefix(2)) { metal in
                                HStack {
                                    Text(metal.name)
                                    Spacer()
                                    Text(metal.price, format: .currency(code: metal.currency))
                                }
                            }
                        }
                    }

                    Section("Makro") {
                        if snapshot.macroOverview.indicators.isEmpty {
                            Text("Keine Daten.")
                        } else {
                            ForEach(snapshot.macroOverview.indicators.prefix(2)) { indicator in
                                HStack {
                                    Text(indicator.title)
                                    Spacer()
                                    Text(indicator.formattedValue)
                                }
                                .font(.caption)
                            }
                        }
                    }

                    Section("Krisen") {
                        if snapshot.crises.isEmpty {
                            Text("Keine Meldungen.")
                        } else {
                            ForEach(snapshot.crises.prefix(2)) { event in
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(event.title)
                                        .font(.caption)
                                    Text(event.severityBadge)
                                        .font(.caption2)
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("CRISIS")
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
