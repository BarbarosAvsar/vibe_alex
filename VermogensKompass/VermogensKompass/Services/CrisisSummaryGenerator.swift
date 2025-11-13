import Foundation

struct CrisisSummaryGenerator {
    func summarize(events: [CrisisEvent]) -> CrisisSummary? {
        guard events.isEmpty == false else { return nil }

        let severeEvents = events.filter { $0.severityScore >= 5 }
        let headline: String
        if severeEvents.isEmpty {
            headline = "Keine Hochrisiko-Ereignisse erkennbar"
        } else {
            headline = "\(severeEvents.count) Hochrisiko-Ereignis(se) aktiv"
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
            highlights.append("\(dominantRegion.1)x Ereignisse in \(dominantRegion.0)")
        }
        if let dominantCategory {
            highlights.append("\(dominantCategory.1)x Kategorie \(dominantCategory.0.rawValue.capitalized)")
        }
        if let latest = recentEvents.first {
            let formatter = DateFormatter()
            formatter.dateStyle = .short
            formatter.timeStyle = .short
            highlights.append("Zuletzt \(latest.title) um \(formatter.string(from: latest.occurredAt))")
        }

        return CrisisSummary(headline: headline, highlights: highlights)
    }
}

struct CrisisSummary: Equatable {
    let headline: String
    let highlights: [String]
}
