import Foundation

enum CrisisCategory: String, Codable, CaseIterable {
    case seismic
    case storm
    case geopolitical
    case financial
}

struct CrisisEvent: Identifiable, Hashable, Codable {
    let id: String
    let title: String
    let magnitude: Double?
    let region: String
    let occurredAt: Date
    let detailURL: URL?
    let source: DataSource
    let category: CrisisCategory

    var severityBadge: String {
        guard let magnitude else { return "Info" }
        switch magnitude {
        case ..<4: return "Niedrig"
        case 4..<6: return "Moderat"
        default: return "Hoch"
        }
    }

    var severityScore: Double {
        magnitude ?? 0
    }
}
