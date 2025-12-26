import Foundation

struct CrisisSummaryGenerator {
    func summarize(events: [CrisisEvent], language: AppLanguage) -> CrisisSummary? {
        guard events.isEmpty == false else { return nil }

        let severeEvents = events.filter { $0.severityScore >= CrisisThresholds.highRiskSeverityScore }
        let headline: String
        if severeEvents.isEmpty {
            headline = Localization.text("crisis_summary_headline_none", language: language)
        } else {
            headline = Localization.plural("crisis_summary_headline_count", count: severeEvents.count, language: language)
        }

        let groupedByRegion = Dictionary(grouping: events, by: { $0.region })
        let dominantRegion = groupedByRegion
            .map { ($0.key, $0.value.count) }
            .sorted { $0.1 > $1.1 }
            .first

        let groupedByCategory = Dictionary(grouping: events, by: { $0.category })
        let dominantCategory = groupedByCategory
            .map { ($0.key, $0.value.count) }
            .sorted { $0.1 > $1.1 }
            .first

        let recentEvents = events.sorted { $0.occurredAt > $1.occurredAt }.prefix(2)

        var highlights: [String] = []
        if let dominantRegion {
            let regionLabel = localizedWatchlistCountry(dominantRegion.0, language: language)
            highlights.append(Localization.plural(
                "crisis_summary_highlight_region",
                count: dominantRegion.1,
                language: language,
                regionLabel
            ))
        }
        if let dominantCategory {
            highlights.append(Localization.format(
                "crisis_summary_highlight_category",
                language: language,
                dominantCategory.1,
                dominantCategory.0.localizedLabel(language: language)
            ))
        }
        if let latest = recentEvents.first {
            let formatter = DateFormatter()
            formatter.locale = language.locale
            formatter.dateStyle = .short
            formatter.timeStyle = .short
            highlights.append(Localization.format(
                "crisis_summary_highlight_latest",
                language: language,
                localizedCrisisEventTitle(latest, language: language),
                formatter.string(from: latest.occurredAt)
            ))
        }

        return CrisisSummary(headline: headline, highlights: highlights)
    }
}

struct CrisisSummary: Equatable {
    let headline: String
    let highlights: [String]
}
