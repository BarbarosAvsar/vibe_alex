import SwiftUI

struct CrisisView: View {
    @Environment(AppState.self) private var appState
    @Binding var showSettings: Bool
    private let summaryGenerator = CrisisSummaryGenerator()
    private let timeline = CrisisTimelineEntry.sampleTimeline

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    learnCard
                    timelineSection

                    AsyncStateView(state: appState.dashboardState) {
                        Task { await appState.refreshDashboard(force: true) }
                    } content: { snapshot in
                        crisisOverviewSection(snapshot: snapshot)
                    }
                }
                .padding()
            }
            .navigationTitle("Krisen")
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

    private var learnCard: some View {
        DashboardSection("Krisen-Timeline", subtitle: "Historische Krisen und ihre Auswirkungen auf Anlageklassen") {
            HStack(alignment: .top, spacing: 12) {
                Image(systemName: "info.circle.fill")
                    .foregroundStyle(Theme.accent)
                VStack(alignment: .leading, spacing: 8) {
                    Text("Lernen Sie aus der Geschichte")
                        .font(.headline)
                    Text("Diese Timeline zeigt, wie verschiedene Anlageklassen in historischen Krisenzeiten performt haben. Besonders Edelmetalle haben sich als wertstabil erwiesen.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            .padding()
            .background(
                Theme.surface,
                in: RoundedRectangle(cornerRadius: 18, style: .continuous)
            )
        }
    }

    private var timelineSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            ForEach(timeline) { entry in
                CrisisTimelineCard(entry: entry)
            }
            if let insight = timeline.last?.insight {
                DashboardSection("Historische Erkenntnis") {
                    Text(insight)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(
                            Theme.accentInfo.opacity(0.24),
                            in: RoundedRectangle(cornerRadius: 16, style: .continuous)
                        )
                }
            }
        }
    }

    @ViewBuilder
    private func crisisOverviewSection(snapshot: DashboardSnapshot) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            if let summary = summaryGenerator.summarize(events: snapshot.crises) {
                DashboardSection("Kurzüberblick", subtitle: "On-Device Zusammenfassung") {
                    CrisisSummaryCard(summary: summary)
                }
            }
            if snapshot.crises.isEmpty == false {
                DashboardSection("Aktuelle Meldungen", subtitle: "Live-Ereignisse des Krisenmonitors") {
                    VStack(spacing: 16) {
                        ForEach(snapshot.crises) { event in
                            CrisisCard(event: event)
                        }
                    }
                }
            }
        }
    }
}

struct CrisisCard: View {
    let event: CrisisEvent

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(event.title)
                    .font(.headline)
                Spacer()
                Text(event.severityBadge)
                    .font(.caption2)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(badgeColor, in: Capsule())
            }
            HStack {
                Text(event.region)
                    .font(.subheadline)
                Spacer()
                Text(event.category.rawValue.capitalized)
                    .font(.caption2)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Theme.border.opacity(0.25), in: Capsule())
            }
            .font(.subheadline)
            .foregroundStyle(.secondary)
            if let summary = event.summary {
                Text(summary)
                    .font(.subheadline)
                    .foregroundStyle(Theme.textSecondary)
            }
            Text(event.occurredAt, style: .relative)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text("Quelle: \(event.sourceName ?? event.source.rawValue)")
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .cardStyle()
    }

    private var badgeColor: Color {
        switch event.severityBadge {
        case "Hoch": return Theme.accentStrong.opacity(0.85)
        case "Moderat": return Theme.accent.opacity(0.85)
        default: return Theme.border.opacity(0.7)
        }
    }
}

struct CrisisSummaryCard: View {
    let summary: CrisisSummary

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(summary.headline)
                .font(.headline)
            ForEach(summary.highlights, id: \.self) { highlight in
                HStack(alignment: .top, spacing: 8) {
                    Image(systemName: "sparkles")
                        .foregroundStyle(Theme.accent)
                    Text(highlight)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .cardStyle()
    }
}

private struct CrisisTimelineCard: View {
    let entry: CrisisTimelineEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 12) {
                VStack(alignment: .center, spacing: 6) {
                    Text("\(entry.year)")
                        .font(.headline)
                    Text(entry.tag)
                        .font(.caption2.weight(.semibold))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(entry.tint.opacity(0.16), in: Capsule())
                }
                Rectangle()
                    .fill(Theme.border.opacity(0.3))
                    .frame(width: 1)
                    .padding(.vertical, 4)
                VStack(alignment: .leading, spacing: 6) {
                    Text(entry.title)
                        .font(.headline)
                    Text(entry.summary)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    if entry.isForecast {
                        Label("Prognose", systemImage: "sparkles")
                            .font(.caption.weight(.semibold))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Theme.accentInfo.opacity(0.3), in: Capsule())
                    }
                    if entry.impacts.isEmpty == false {
                        VStack(spacing: 8) {
                            ForEach(entry.impacts) { impact in
                                HStack {
                                    Label(impact.asset, systemImage: impact.icon)
                                        .font(.subheadline.weight(.semibold))
                                    Spacer()
                                    Text(impact.formatted)
                                        .font(.subheadline.weight(.semibold))
                                        .foregroundStyle(impact.value >= 0 ? .green : .red)
                                }
                            }
                        }
                        .padding()
                        .background(
                            Theme.surface.opacity(0.6),
                            in: RoundedRectangle(cornerRadius: 12, style: .continuous)
                        )
                    }
                }
            }
        }
        .padding()
        .background(
            entry.tint.opacity(0.1),
            in: RoundedRectangle(cornerRadius: 18, style: .continuous)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .strokeBorder(entry.tint.opacity(0.35), lineWidth: 1)
        )
    }
}

struct CrisisTimelineEntry: Identifiable {
    struct Impact: Identifiable {
        let id = UUID()
        let asset: String
        let value: Double
        let icon: String

        var formatted: String {
            let sign = value >= 0 ? "+" : ""
            return "\(sign)\(value.formatted(.number.precision(.fractionLength(0))))%"
        }
    }

    let id = UUID()
    let year: Int
    let title: String
    let tag: String
    let summary: String
    let impacts: [Impact]
    let isForecast: Bool
    let tint: Color
    let insight: String?

    static let sampleTimeline: [CrisisTimelineEntry] = [
        .init(year: 1948, title: "Währungsreform & Lastenausgleich", tag: "Währungsreform", summary: "Die deutsche Währungsreform führte zur Entwertung von Geldvermögen. Der Lastenausgleich besteuerte Sachwerte zugunsten von Kriegsgeschädigten.", impacts: [
            Impact(asset: "Aktien", value: -40, icon: "chart.line.downtrend.xyaxis"),
            Impact(asset: "Immobilien", value: -30, icon: "house.lodge.fill"),
            Impact(asset: "Edelmetalle", value: 85, icon: "diamond.fill")
        ], isForecast: false, tint: Theme.accent, insight: nil),
        .init(year: 1973, title: "Ölkrise", tag: "Inflation", summary: "Inflation und Rezession durch Energiepreisschock in Industrieländern.", impacts: [
            Impact(asset: "Aktien", value: -25, icon: "chart.line.downtrend.xyaxis"),
            Impact(asset: "Immobilien", value: -10, icon: "building.columns.fill"),
            Impact(asset: "Edelmetalle", value: 65, icon: "diamond.fill")
        ], isForecast: false, tint: Theme.accent, insight: nil),
        .init(year: 1987, title: "Schwarzer Montag", tag: "Wirtschaftskrise", summary: "Größter Börsencrash der Geschichte mit weltweiten Verlusten über 20% an einem Tag.", impacts: [
            Impact(asset: "Aktien", value: -35, icon: "chart.line.downtrend.xyaxis"),
            Impact(asset: "Immobilien", value: -5, icon: "building.columns.fill"),
            Impact(asset: "Edelmetalle", value: 15, icon: "diamond.fill")
        ], isForecast: false, tint: Theme.accent, insight: nil),
        .init(year: 1999, title: "Euro-Einführung (Buchgeld)", tag: "Währungsreform", summary: "Einführung des Euro als Buchgeld markierte eine historische Währungsreform in Europa.", impacts: [
            Impact(asset: "Aktien", value: 5, icon: "chart.line.uptrend.xyaxis"),
            Impact(asset: "Immobilien", value: 0, icon: "building.columns.fill"),
            Impact(asset: "Edelmetalle", value: 8, icon: "diamond.fill")
        ], isForecast: false, tint: Theme.accentInfo, insight: nil),
        .init(year: 2001, title: "Dotcom-Blase & 9/11", tag: "Wirtschaftskrise", summary: "Platzen der Internetblase und die Terroranschläge vom 11. September führten zu einer globalen Wirtschaftskrise.", impacts: [
            Impact(asset: "Aktien", value: -30, icon: "chart.line.downtrend.xyaxis"),
            Impact(asset: "Immobilien", value: -8, icon: "building.columns.fill"),
            Impact(asset: "Edelmetalle", value: 20, icon: "diamond.fill")
        ], isForecast: false, tint: Theme.accent, insight: nil),
        .init(year: 2002, title: "Euro-Bargeld Einführung", tag: "Währungsreform", summary: "Die D-Mark wurde durch Euro-Münzen und -Scheine ersetzt. Viele Bürger empfanden versteckte Preissteigerungen.", impacts: [
            Impact(asset: "Aktien", value: 0, icon: "chart.line.uptrend.xyaxis"),
            Impact(asset: "Immobilien", value: 3, icon: "building.columns.fill"),
            Impact(asset: "Edelmetalle", value: 12, icon: "diamond.fill")
        ], isForecast: false, tint: Theme.accentInfo, insight: nil),
        .init(year: 2008, title: "Finanzkrise", tag: "Wirtschaftskrise", summary: "Subprime-Krise in den USA führte zur schwersten Finanzkrise seit der Großen Depression.", impacts: [
            Impact(asset: "Aktien", value: -40, icon: "chart.line.downtrend.xyaxis"),
            Impact(asset: "Immobilien", value: -25, icon: "building.columns.fill"),
            Impact(asset: "Edelmetalle", value: 40, icon: "diamond.fill")
        ], isForecast: false, tint: Theme.accent, insight: nil),
        .init(year: 2020, title: "COVID-19 Pandemie", tag: "Wirtschaftskrise", summary: "Globale Pandemie führte zu massiven wirtschaftlichen Verwerfungen und Staatsschulden.", impacts: [
            Impact(asset: "Aktien", value: -20, icon: "chart.line.downtrend.xyaxis"),
            Impact(asset: "Immobilien", value: -5, icon: "building.columns.fill"),
            Impact(asset: "Edelmetalle", value: 25, icon: "diamond.fill")
        ], isForecast: false, tint: Theme.accent, insight: nil),
        .init(year: 2028, title: "Prognose: Nächster Benner-Zyklus", tag: "Prognose", summary: "Benner-Zyklus erwartet wirtschaftliche Schwierigkeiten.", impacts: [
            Impact(asset: "Aktien", value: -25, icon: "chart.line.downtrend.xyaxis"),
            Impact(asset: "Immobilien", value: -15, icon: "building.columns.fill"),
            Impact(asset: "Edelmetalle", value: 35, icon: "diamond.fill")
        ], isForecast: true, tint: Theme.accentInfo, insight: nil),
        .init(year: 2045, title: "Prognose: Benner Panik-Phase", tag: "Prognose", summary: "Benner-Zyklus deutet auf mögliche Panikphase hin, ähnlich 1929 oder 2008.", impacts: [
            Impact(asset: "Aktien", value: -35, icon: "chart.line.downtrend.xyaxis"),
            Impact(asset: "Immobilien", value: -20, icon: "building.columns.fill"),
            Impact(asset: "Edelmetalle", value: 50, icon: "diamond.fill")
        ], isForecast: true, tint: Theme.accentInfo, insight: "In allen großen Krisen der letzten Jahrzehnte haben Edelmetalle Kaufkraft bewahrt oder gesteigert.")
    ]
}
