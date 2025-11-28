import Foundation

struct AssetComparisonEngine {
    func makeAssets(from snapshot: DashboardSnapshot, forecasts: [BennerCycleEntry]) -> [ComparisonAssetSeries] {
        ComparisonAsset.allCases.map { asset in
            let history = makeHistory(for: asset, snapshot: snapshot)
            let projection = makeProjection(for: asset, forecasts: forecasts, history: history)
            return ComparisonAssetSeries(asset: asset, history: history, projection: projection)
        }
    }

    private func makeHistory(for asset: ComparisonAsset, snapshot: DashboardSnapshot) -> [ComparisonPoint] {
        let currentYear = Calendar.current.component(.year, from: Date())
        let years = (0..<6).map { currentYear - (5 - $0) }
        let base = asset.baseValue(snapshot: snapshot)

        return years.enumerated().map { offset, year in
            let factor = 1 + (Double(offset) * asset.historySlope)
            return ComparisonPoint(year: year, value: base * factor)
        }
    }

    private func makeProjection(for asset: ComparisonAsset, forecasts: [BennerCycleEntry], history: [ComparisonPoint]) -> [ComparisonPoint] {
        var value = history.last?.value ?? asset.base
        return forecasts.filter { $0.year >= (history.last?.year ?? 0) }.map { entry in
            value += value * asset.multiplier(for: entry.phase)
            return ComparisonPoint(year: entry.year, value: value)
        }
    }
}

struct ComparisonAssetSeries: Identifiable {
    let asset: ComparisonAsset
    let history: [ComparisonPoint]
    let projection: [ComparisonPoint]

    var id: ComparisonAsset { asset }
}

struct ComparisonPoint: Identifiable {
    let year: Int
    let value: Double
    var id: Int { year }
}

enum ComparisonAsset: String, CaseIterable, Identifiable {
    case equityDE, equityUSA, equityLON
    case realEstateDE, realEstateES, realEstateFR, realEstateLON
    case gold, silver

    var id: String { rawValue }

    var name: String {
        switch self {
        case .equityDE: return "Deutschland Aktien"
        case .equityUSA: return "USA Aktien"
        case .equityLON: return "London Aktien"
        case .realEstateDE: return "Deutschland Immobilien"
        case .realEstateES: return "Spanien Immobilien"
        case .realEstateFR: return "Frankreich Immobilien"
        case .realEstateLON: return "London Immobilien"
        case .gold: return "Gold"
        case .silver: return "Silber"
        }
    }

    var icon: String {
        switch self {
        case .equityDE, .equityUSA, .equityLON: return "chart.bar.fill"
        case .realEstateDE, .realEstateES, .realEstateFR, .realEstateLON: return "house.fill"
        case .gold: return "star.fill"
        case .silver: return "sparkles"
        }
    }

    var group: AssetGroup {
        switch self {
        case .equityDE, .equityUSA, .equityLON: return .equities
        case .realEstateDE, .realEstateES, .realEstateFR, .realEstateLON: return .realEstate
        case .gold, .silver: return .metals
        }
    }

    var historySlope: Double {
        switch group {
        case .equities: return 0.05
        case .realEstate: return 0.035
        case .metals: return 0.045
        }
    }

    var base: Double {
        switch group {
        case .equities: return 120
        case .realEstate: return 95
        case .metals: return 100
        }
    }

    func baseValue(snapshot: DashboardSnapshot) -> Double {
        switch self {
        case .gold:
            return snapshot.metals.first(where: { $0.name.lowercased().contains("gold") })?.price ?? base
        case .silver:
            return snapshot.metals.first(where: { $0.name.lowercased().contains("silber") || $0.symbol == "XAG" })?.price ?? base * 0.3
        default:
            return base
        }
    }

    func multiplier(for phase: BennerPhase) -> Double {
        switch group {
        case .equities:
            switch phase {
            case .goodTimes: return 0.05
            case .hardTimes: return -0.02
            case .panic: return -0.08
            }
        case .realEstate:
            switch phase {
            case .goodTimes: return 0.03
            case .hardTimes: return -0.015
            case .panic: return -0.06
            }
        case .metals:
            switch phase {
            case .goodTimes: return 0.015
            case .hardTimes: return 0.03
            case .panic: return 0.08
            }
        }
    }
}

enum AssetGroup: String, CaseIterable {
    case equities = "Aktienmärkte"
    case realEstate = "Immobilienpreise"
    case metals = "Edelmetalle"
}
