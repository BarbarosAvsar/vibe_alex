import SwiftUI

struct CrisisView: View {
    @Environment(AppState.self) private var appState
    @Binding var showSettings: Bool
    private let timeline = CrisisTimelineEntry.sampleTimeline

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    learnCard
                    timelineSection
                }
                .padding()
            }
            .navigationTitle("Krisen")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    LogoMark()
                }
                ToolbarItem(placement: .topBarTrailing) {
                    ToolbarStatusControl {
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
                        .foregroundStyle(Theme.textSecondary)
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
                        .foregroundStyle(Theme.textSecondary)
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
                        .foregroundStyle(Theme.textSecondary)
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
                                    Label {
                                        Text(impact.asset)
                                            .font(.subheadline.weight(.semibold))
                                    } icon: {
                                        iconView(for: impact.icon)
                                    }
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

private extension CrisisTimelineCard {
    @ViewBuilder
    func iconView(for icon: CrisisTimelineEntry.Impact.Icon) -> some View {
        switch icon {
        case .diamond:
            BrilliantDiamondIcon(size: 14)
        case .system(let name):
            Image(systemName: name)
        }
    }
}

struct CrisisTimelineEntry: Identifiable {
    struct Impact: Identifiable {
        enum Icon {
            case system(String)
            case diamond
        }

        let id = UUID()
        let asset: String
        let value: Double
        let icon: Icon

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
            Impact(asset: "Aktien", value: -40, icon: .system("chart.line.downtrend.xyaxis")),
            Impact(asset: "Immobilien", value: -30, icon: .system("house.lodge.fill")),
            Impact(asset: "Edelmetalle", value: 85, icon: .diamond)
        ], isForecast: false, tint: Theme.accent, insight: nil),
        .init(year: 1973, title: "Ölkrise", tag: "Inflation", summary: "Inflation und Rezession durch Energiepreisschock in Industrieländern.", impacts: [
            Impact(asset: "Aktien", value: -25, icon: .system("chart.line.downtrend.xyaxis")),
            Impact(asset: "Immobilien", value: -10, icon: .system("building.columns.fill")),
            Impact(asset: "Edelmetalle", value: 65, icon: .diamond)
        ], isForecast: false, tint: Theme.accent, insight: nil),
        .init(year: 1987, title: "Schwarzer Montag", tag: "Wirtschaftskrise", summary: "Größter Börsencrash der Geschichte mit weltweiten Verlusten über 20% an einem Tag.", impacts: [
            Impact(asset: "Aktien", value: -35, icon: .system("chart.line.downtrend.xyaxis")),
            Impact(asset: "Immobilien", value: -5, icon: .system("building.columns.fill")),
            Impact(asset: "Edelmetalle", value: 15, icon: .diamond)
        ], isForecast: false, tint: Theme.accent, insight: nil),
        .init(year: 1999, title: "Euro-Einführung (Buchgeld)", tag: "Währungsreform", summary: "Einführung des Euro als Buchgeld markierte eine historische Währungsreform in Europa.", impacts: [
            Impact(asset: "Aktien", value: 5, icon: .system("chart.line.uptrend.xyaxis")),
            Impact(asset: "Immobilien", value: 0, icon: .system("building.columns.fill")),
            Impact(asset: "Edelmetalle", value: 8, icon: .diamond)
        ], isForecast: false, tint: Theme.accentInfo, insight: nil),
        .init(year: 2001, title: "Dotcom-Blase & 9/11", tag: "Wirtschaftskrise", summary: "Platzen der Internetblase und die Terroranschläge vom 11. September führten zu einer globalen Wirtschaftskrise.", impacts: [
            Impact(asset: "Aktien", value: -30, icon: .system("chart.line.downtrend.xyaxis")),
            Impact(asset: "Immobilien", value: -8, icon: .system("building.columns.fill")),
            Impact(asset: "Edelmetalle", value: 20, icon: .diamond)
        ], isForecast: false, tint: Theme.accent, insight: nil),
        .init(year: 2002, title: "Euro-Bargeld Einführung", tag: "Währungsreform", summary: "Die D-Mark wurde durch Euro-Münzen und -Scheine ersetzt. Viele Bürger empfanden versteckte Preissteigerungen.", impacts: [
            Impact(asset: "Aktien", value: 0, icon: .system("chart.line.uptrend.xyaxis")),
            Impact(asset: "Immobilien", value: 3, icon: .system("building.columns.fill")),
            Impact(asset: "Edelmetalle", value: 12, icon: .diamond)
        ], isForecast: false, tint: Theme.accentInfo, insight: nil),
        .init(year: 2008, title: "Finanzkrise", tag: "Wirtschaftskrise", summary: "Subprime-Krise in den USA führte zur schwersten Finanzkrise seit der Großen Depression.", impacts: [
            Impact(asset: "Aktien", value: -40, icon: .system("chart.line.downtrend.xyaxis")),
            Impact(asset: "Immobilien", value: -25, icon: .system("building.columns.fill")),
            Impact(asset: "Edelmetalle", value: 40, icon: .diamond)
        ], isForecast: false, tint: Theme.accent, insight: nil),
        .init(year: 2020, title: "COVID-19 Pandemie", tag: "Wirtschaftskrise", summary: "Globale Pandemie führte zu massiven wirtschaftlichen Verwerfungen und Staatsschulden.", impacts: [
            Impact(asset: "Aktien", value: -20, icon: .system("chart.line.downtrend.xyaxis")),
            Impact(asset: "Immobilien", value: -5, icon: .system("building.columns.fill")),
            Impact(asset: "Edelmetalle", value: 25, icon: .diamond)
        ], isForecast: false, tint: Theme.accent, insight: nil),
        .init(year: 2028, title: "Prognose: Nächste Marktphase", tag: "Prognose", summary: "Modell erwartet wirtschaftliche Schwierigkeiten.", impacts: [
            Impact(asset: "Aktien", value: -25, icon: .system("chart.line.downtrend.xyaxis")),
            Impact(asset: "Immobilien", value: -15, icon: .system("building.columns.fill")),
            Impact(asset: "Edelmetalle", value: 35, icon: .diamond)
        ], isForecast: true, tint: Theme.accentInfo, insight: nil),
        .init(year: 2045, title: "Prognose: Panikphase", tag: "Prognose", summary: "Modell deutet auf mögliche Panikphase hin, ähnlich 1929 oder 2008.", impacts: [
            Impact(asset: "Aktien", value: -35, icon: .system("chart.line.downtrend.xyaxis")),
            Impact(asset: "Immobilien", value: -20, icon: .system("building.columns.fill")),
            Impact(asset: "Edelmetalle", value: 50, icon: .diamond)
        ], isForecast: true, tint: Theme.accentInfo, insight: "In allen großen Krisen der letzten Jahrzehnte haben Edelmetalle Kaufkraft bewahrt oder gesteigert.")
    ]
}
