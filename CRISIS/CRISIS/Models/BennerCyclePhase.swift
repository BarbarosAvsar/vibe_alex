import Foundation

enum BennerPhase: String, Codable, CaseIterable {
    case panic
    case goodTimes
    case hardTimes

    var title: String {
        switch self {
        case .panic:
            return "Panikjahr"
        case .goodTimes:
            return "Good Times"
        case .hardTimes:
            return "Hard Times"
        }
    }

    var subtitle: String {
        switch self {
        case .panic:
            return "Extremer Verkaufsdruck – Phase A"
        case .goodTimes:
            return "Hohe Preise – Phase B (Verkäufe bevorzugt)"
        case .hardTimes:
            return "Niedrige Preise – Phase C (Akkumulation)"
        }
    }

    var guidance: String {
        switch self {
        case .panic:
            return "Historisch folgten auf diese Jahre heftige Markteinbrüche. Liquidität sichern und Risiko begrenzen."
        case .goodTimes:
            return "Überdurchschnittliche Bewertungen. Gewinne sichern und Exposure reduzieren."
        case .hardTimes:
            return "Marktpreise gelten als günstig. Positionsaufbau und Sparpläne bieten sich an."
        }
    }
}

struct BennerCycleEntry: Identifiable, Hashable, Codable {
    let year: Int
    let phase: BennerPhase
    let orderInPhase: Int
    let phaseLength: Int

    var id: Int { year }

    var label: String {
        "\(phase.title) • \(orderInPhase)/\(phaseLength)"
    }

    var summary: String {
        "\(year) – \(phase.subtitle)"
    }
}
