import SwiftUI

struct PlatformDashboardView: View {
    @Environment(AppState.self) private var appState
    @Environment(CurrencySettings.self) private var currencySettings
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
            DashboardSection("Benner-Zyklus", subtitle: "Lokales Prognosemodell") {
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("Prognose")
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
                    Text("Vorsicht empfohlen, Absicherung priorisieren.")
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
        DashboardSection("Edelmetalle", subtitle: "Aktuelle Preise") {
            if metals.isEmpty {
                Text("Keine Daten verfuegbar.")
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
        DashboardSection("Makro", subtitle: "Aktuelle Kennzahlen") {
            if indicators.isEmpty {
                Text("Keine Daten verfuegbar.")
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
        DashboardSection("Krisenfeed", subtitle: "Aktuelle Hinweise") {
            if events.isEmpty {
                Text("Keine Meldungen.")
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

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(indicator.title)
                    .font(.subheadline.weight(.semibold))
                Spacer()
                Text(indicator.formattedValue)
                    .font(.subheadline)
                    .foregroundStyle(Theme.textSecondary)
            }
            Text(indicator.deltaDescription)
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

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .top) {
                Text(event.title)
                    .font(.subheadline.weight(.semibold))
                Spacer()
                Text(event.severityBadge)
                    .font(.caption2.weight(.semibold))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Theme.surface, in: Capsule())
            }
            Text(event.region)
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
