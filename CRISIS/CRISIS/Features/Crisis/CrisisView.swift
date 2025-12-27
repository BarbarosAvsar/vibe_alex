import Foundation
import SwiftUI

@MainActor
struct CrisisView: View {
    @Environment(AppState.self) private var appState
    @Environment(LanguageSettings.self) private var languageSettings
    @Binding var showSettings: Bool
    private let summaryGenerator = CrisisSummaryGenerator()

    var body: some View {
        NavigationStack {
            ZStack {
                LiquidGlassBackground()
                ScrollView {
                    AsyncStateView(state: appState.dashboardState) {
                        Task { await appState.refreshDashboard(force: true) }
                    } content: { snapshot in
                        VStack(alignment: .leading, spacing: 24) {
                            historicalTimelineSection()
                            AdaptiveStack(spacing: 24) {
                                VStack(alignment: .leading, spacing: 24) {
                                    overviewSection(snapshot.crises)
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)

                                VStack(alignment: .leading, spacing: 24) {
                                    crisisFeedSection(snapshot.crises)
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle(Localization.text("crisis_title", language: languageSettings.selectedLanguage))
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
    private func overviewSection(_ events: [CrisisEvent]) -> some View {
        let language = languageSettings.selectedLanguage
        DashboardSection(
            Localization.text("crisis_overview_title", language: language),
            subtitle: Localization.text("crisis_overview_subtitle", language: language)
        ) {
            if let summary = summaryGenerator.summarize(events: events, language: language) {
                VStack(alignment: .leading, spacing: 8) {
                    Text(summary.headline)
                        .font(.headline)
                    ForEach(summary.highlights, id: \.self) { highlight in
                        Text(highlight)
                            .font(.caption)
                            .foregroundStyle(Theme.textSecondary)
                    }
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    Theme.surface,
                    in: RoundedRectangle(cornerRadius: 18, style: .continuous)
                )
            } else {
                Text(Localization.text("crisis_overview_empty", language: language))
                    .font(.subheadline)
                    .foregroundStyle(Theme.textSecondary)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(
                        Theme.surface,
                        in: RoundedRectangle(cornerRadius: 18, style: .continuous)
                    )
            }
        }
    }

    @ViewBuilder
    private func crisisFeedSection(_ events: [CrisisEvent]) -> some View {
        let language = languageSettings.selectedLanguage
        DashboardSection(
            Localization.text("crisis_feed_title", language: language),
            subtitle: Localization.text("crisis_feed_subtitle", language: language)
        ) {
            if events.isEmpty {
                Text(Localization.text("crisis_feed_empty", language: language))
                    .font(.subheadline)
                    .foregroundStyle(Theme.textSecondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            } else {
                VStack(spacing: 12) {
                    ForEach(events) { event in
                        CrisisEventCard(event: event)
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func historicalTimelineSection() -> some View {
        let language = languageSettings.selectedLanguage
        let events = CrisisTimelineEvent.allCases
        DashboardSection(
            Localization.text("crisis_timeline_title", language: language),
            subtitle: Localization.text("crisis_timeline_subtitle", language: language)
        ) {
            VStack(alignment: .leading, spacing: 16) {
                TimelineIntroCard(
                    title: Localization.text("crisis_timeline_intro_title", language: language),
                    body: Localization.text("crisis_timeline_intro_body", language: language)
                )

                ForEach(events) { event in
                    TimelineEventCard(event: event, language: language)
                }

                Text(Localization.text("crisis_timeline_disclaimer", language: language))
                    .font(.caption)
                    .foregroundStyle(Theme.textMuted)

                TimelineInsightCard(
                    title: Localization.text("crisis_timeline_insight_title", language: language),
                    body: Localization.text("crisis_timeline_insight_body", language: language)
                )
            }
        }
    }
}

@MainActor
private struct CrisisEventCard: View {
    let event: CrisisEvent
    @Environment(LanguageSettings.self) private var languageSettings

    var body: some View {
        let language = languageSettings.selectedLanguage
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top) {
                Text(localizedCrisisEventTitle(event, language: language))
                    .font(.headline)
                Spacer()
                Text(event.localizedSeverityBadge(language: language))
                    .font(.caption2.weight(.semibold))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(badgeTint.opacity(0.2), in: Capsule())
            }

            if let summary = event.summary {
                Text(summary)
                    .font(.subheadline)
                    .foregroundStyle(Theme.textSecondary)
            }

            HStack {
                Label(localizedWatchlistCountry(event.region, language: language), systemImage: "globe.europe.africa")
                    .font(.caption)
                    .foregroundStyle(Theme.textMuted)
                Spacer()
                Text(event.occurredAt, format: .dateTime.year().month().day().hour().minute())
                    .font(.caption)
                    .foregroundStyle(Theme.textMuted)
            }

            HStack(spacing: 8) {
                Text(categoryLabel)
                    .font(.caption.weight(.semibold))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(categoryTint.opacity(0.2), in: Capsule())
                Text(event.sourceName ?? event.source.rawValue)
                    .font(.caption)
                    .foregroundStyle(Theme.textSecondary)
            }
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

    private var categoryLabel: String {
        event.category.localizedLabel(language: languageSettings.selectedLanguage)
    }

    private var categoryTint: Color {
        switch event.category {
        case .financial:
            return Theme.accent
        case .geopolitical:
            return Theme.accentInfo
        }
    }

    private var badgeTint: Color {
        switch event.severityScore {
        case ..<4:
            return Theme.accentInfo
        case 4..<6:
            return Theme.accent
        default:
            return Theme.accentStrong
        }
    }
}

private struct TimelineIntroCard: View {
    let title: String
    let body: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: "info.circle.fill")
                .foregroundStyle(Theme.accent)
            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(.headline)
                Text(body)
                    .font(.subheadline)
                    .foregroundStyle(Theme.textSecondary)
            }
        }
        .liquidGlassCard()
    }
}

private struct TimelineInsightCard: View {
    let title: String
    let body: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
            Text(body)
                .font(.subheadline)
                .foregroundStyle(Theme.textSecondary)
        }
        .padding()
        .background(
            Theme.accent.opacity(0.28),
            in: RoundedRectangle(cornerRadius: 20, style: .continuous)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .strokeBorder(Theme.accent.opacity(0.2), lineWidth: 1)
        )
    }
}

private struct TimelineEventCard: View {
    let event: CrisisTimelineEvent
    let language: AppLanguage

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top, spacing: 12) {
                TimelineMarker(year: event.year, tag: event.tag)
                VStack(alignment: .leading, spacing: 6) {
                    Text(Localization.text(event.tag.labelKey, language: language))
                        .font(.caption2.weight(.semibold))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(event.tag.tint.opacity(0.2), in: Capsule())
                    Text(Localization.text(event.titleKey, language: language))
                        .font(.headline)
                }
            }

            Text(Localization.text(event.summaryKey, language: language))
                .font(.subheadline)
                .foregroundStyle(Theme.textSecondary)

            VStack(alignment: .leading, spacing: 8) {
                Text(Localization.text("crisis_timeline_impact_title", language: language))
                    .font(.caption)
                    .foregroundStyle(Theme.textMuted)
                TimelineImpactRow(
                    label: Localization.text("comparison_scenario_equities", language: language),
                    icon: "chart.line.uptrend.xyaxis",
                    value: event.impact.equities
                )
                TimelineImpactRow(
                    label: Localization.text("comparison_scenario_real_estate", language: language),
                    icon: "house.fill",
                    value: event.impact.realEstate
                )
                TimelineImpactRow(
                    label: Localization.text("comparison_scenario_metals", language: language),
                    icon: "sparkles",
                    value: event.impact.metals
                )
            }
        }
        .liquidGlassCard()
    }
}

private struct TimelineImpactRow: View {
    let label: String
    let icon: String
    let value: Int

    var body: some View {
        HStack {
            Label(label, systemImage: icon)
                .font(.caption)
                .foregroundStyle(Theme.textSecondary)
            Spacer()
            Text("\(value > 0 ? "+" : "")\(value)%")
                .font(.caption.weight(.semibold))
                .foregroundStyle(value >= 0 ? Theme.accentStrong : .red)
        }
    }
}

private struct TimelineMarker: View {
    let year: Int
    let tag: CrisisTimelineTag

    var body: some View {
        VStack(spacing: 6) {
            Text(String(year))
                .font(.caption2)
                .foregroundStyle(Theme.textMuted)
            ZStack {
                Circle()
                    .fill(tag.tint.opacity(0.2))
                Image(systemName: tag.icon)
                    .font(.caption2)
                    .foregroundStyle(Theme.textPrimary)
            }
            .frame(width: 28, height: 28)
        }
    }
}

private enum CrisisTimelineTag {
    case currency
    case inflation
    case market
    case geopolitical
    case pandemic
    case forecast

    var labelKey: String {
        switch self {
        case .currency:
            return "crisis_timeline_tag_currency"
        case .inflation:
            return "crisis_timeline_tag_inflation"
        case .market:
            return "crisis_timeline_tag_market"
        case .geopolitical:
            return "crisis_timeline_tag_geopolitical"
        case .pandemic:
            return "crisis_timeline_tag_pandemic"
        case .forecast:
            return "crisis_timeline_tag_forecast"
        }
    }

    var icon: String {
        switch self {
        case .currency:
            return "banknote.fill"
        case .inflation:
            return "chart.line.uptrend.xyaxis"
        case .market:
            return "exclamationmark.triangle.fill"
        case .geopolitical:
            return "globe.europe.africa.fill"
        case .pandemic:
            return "cross.case.fill"
        case .forecast:
            return "calendar"
        }
    }

    var tint: Color {
        switch self {
        case .currency:
            return Theme.accentStrong
        case .inflation:
            return Theme.accent
        case .market:
            return Theme.accentInfo
        case .geopolitical:
            return Theme.accent
        case .pandemic:
            return Theme.accentInfo
        case .forecast:
            return Theme.accentStrong
        }
    }
}

private struct CrisisTimelineImpact {
    let equities: Int
    let realEstate: Int
    let metals: Int
}

private enum CrisisTimelineEvent: CaseIterable, Identifiable {
    case event1948
    case event1971
    case event1973
    case event1987
    case event1999
    case event2001
    case event2008
    case event2020
    case event2022
    case event2028
    case event2045

    var id: Int { year }

    var year: Int {
        switch self {
        case .event1948: return 1948
        case .event1971: return 1971
        case .event1973: return 1973
        case .event1987: return 1987
        case .event1999: return 1999
        case .event2001: return 2001
        case .event2008: return 2008
        case .event2020: return 2020
        case .event2022: return 2022
        case .event2028: return 2028
        case .event2045: return 2045
        }
    }

    var tag: CrisisTimelineTag {
        switch self {
        case .event1948, .event1971, .event1999:
            return .currency
        case .event1973:
            return .inflation
        case .event1987, .event2001, .event2008:
            return .market
        case .event2020:
            return .pandemic
        case .event2022:
            return .geopolitical
        case .event2028, .event2045:
            return .forecast
        }
    }

    var titleKey: String {
        switch self {
        case .event1948: return "crisis_timeline_event_1948_title"
        case .event1971: return "crisis_timeline_event_1971_title"
        case .event1973: return "crisis_timeline_event_1973_title"
        case .event1987: return "crisis_timeline_event_1987_title"
        case .event1999: return "crisis_timeline_event_1999_title"
        case .event2001: return "crisis_timeline_event_2001_title"
        case .event2008: return "crisis_timeline_event_2008_title"
        case .event2020: return "crisis_timeline_event_2020_title"
        case .event2022: return "crisis_timeline_event_2022_title"
        case .event2028: return "crisis_timeline_event_2028_title"
        case .event2045: return "crisis_timeline_event_2045_title"
        }
    }

    var summaryKey: String {
        switch self {
        case .event1948: return "crisis_timeline_event_1948_summary"
        case .event1971: return "crisis_timeline_event_1971_summary"
        case .event1973: return "crisis_timeline_event_1973_summary"
        case .event1987: return "crisis_timeline_event_1987_summary"
        case .event1999: return "crisis_timeline_event_1999_summary"
        case .event2001: return "crisis_timeline_event_2001_summary"
        case .event2008: return "crisis_timeline_event_2008_summary"
        case .event2020: return "crisis_timeline_event_2020_summary"
        case .event2022: return "crisis_timeline_event_2022_summary"
        case .event2028: return "crisis_timeline_event_2028_summary"
        case .event2045: return "crisis_timeline_event_2045_summary"
        }
    }

    var impact: CrisisTimelineImpact {
        switch self {
        case .event1948:
            return CrisisTimelineImpact(equities: -40, realEstate: -30, metals: 85)
        case .event1971:
            return CrisisTimelineImpact(equities: -15, realEstate: -8, metals: 120)
        case .event1973:
            return CrisisTimelineImpact(equities: -25, realEstate: -10, metals: 65)
        case .event1987:
            return CrisisTimelineImpact(equities: -35, realEstate: -5, metals: 15)
        case .event1999:
            return CrisisTimelineImpact(equities: 5, realEstate: 0, metals: 8)
        case .event2001:
            return CrisisTimelineImpact(equities: -30, realEstate: -8, metals: 20)
        case .event2008:
            return CrisisTimelineImpact(equities: -40, realEstate: -25, metals: 40)
        case .event2020:
            return CrisisTimelineImpact(equities: -20, realEstate: -5, metals: 25)
        case .event2022:
            return CrisisTimelineImpact(equities: -15, realEstate: -8, metals: 18)
        case .event2028:
            return CrisisTimelineImpact(equities: -25, realEstate: -15, metals: 35)
        case .event2045:
            return CrisisTimelineImpact(equities: -35, realEstate: -20, metals: 50)
        }
    }
}
