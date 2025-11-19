import Foundation

enum CrisisCategory: String, Codable, CaseIterable {
    case geopolitical
    case financial
}

struct CrisisEvent: Identifiable, Hashable, Codable {
    let id: String
    let title: String
    let summary: String?
    let region: String
    let occurredAt: Date
    let publishedAt: Date?
    let detailURL: URL?
    let sourceName: String?
    let source: DataSource
    let category: CrisisCategory
    let severityScore: Double

    var severityBadge: String {
        switch severityScore {
        case ..<4: return "Info"
        case 4..<6: return "Moderat"
        default: return "Hoch"
        }
    }
}
