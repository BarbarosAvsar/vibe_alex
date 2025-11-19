import Foundation

struct AssetComparisonEngine {
    func makeSeries(from snapshot: DashboardSnapshot, bennerEntries: [BennerCycleEntry]) -> [AssetComparisonSeries] {
        AssetCategory.allCases.map { category in
            let history = makeHistory(for: category, snapshot: snapshot)
            let projection = makeProjection(for: category, bennerEntries: bennerEntries, history: history)
            return AssetComparisonSeries(category: category, history: history, projection: projection)
        }
    }

    private func makeHistory(for category: AssetCategory, snapshot: DashboardSnapshot) -> [AssetComparisonPoint] {
        switch category {
        case .internationalEquities:
            return macroSeries(kind: .growth, snapshot: snapshot) ?? defaultHistory(baseValue: category.baseValue)
        case .realEstate:
            return macroSeries(kind: .inflation, snapshot: snapshot) ?? defaultHistory(baseValue: category.baseValue * 0.9)
        case .preciousMetals:
            return metalHistory(snapshot: snapshot)
        }
    }

    private func macroSeries(kind: MacroIndicatorKind, snapshot: DashboardSnapshot) -> [AssetComparisonPoint]? {
        guard let series = snapshot.macroSeries.first(where: { $0.kind == kind }),
              series.points.isEmpty == false else { return nil }
        return series.points.map { AssetComparisonPoint(year: $0.year, value: $0.value) }
    }

    private func metalHistory(snapshot: DashboardSnapshot) -> [AssetComparisonPoint] {
        let currentYear = Calendar.current.component(.year, from: Date())
        guard let average = snapshot.metals.map(\.price).average else {
            return defaultHistory(baseValue: AssetCategory.preciousMetals.baseValue)
        }

        let normalizedBase = max(average / 100.0, 40)
        return (0..<6).map { index in
            let multiplier = 1 + (Double(index) * 0.04)
            let year = currentYear - (5 - index)
            return AssetComparisonPoint(year: year, value: normalizedBase * multiplier)
        }
    }

    private func defaultHistory(baseValue: Double) -> [AssetComparisonPoint] {
        let currentYear = Calendar.current.component(.year, from: Date())
        return (0..<6).map { index in
            let year = currentYear - (5 - index)
            let multiplier = 1 + (Double(index) * 0.03)
            return AssetComparisonPoint(year: year, value: baseValue * multiplier)
        }
    }

    private func makeProjection(for category: AssetCategory, bennerEntries: [BennerCycleEntry], history: [AssetComparisonPoint]) -> [AssetComparisonPoint] {
        let currentYear = Calendar.current.component(.year, from: Date())
        let relevantEntries = bennerEntries.filter { $0.year >= currentYear }
        var value = history.last?.value ?? category.baseValue
        var projection: [AssetComparisonPoint] = []

        for entry in relevantEntries {
            value += value * category.multiplier(for: entry.phase)
            projection.append(AssetComparisonPoint(year: entry.year, value: value))
        }

        return projection
    }
}

struct AssetComparisonSeries: Identifiable {
    let category: AssetCategory
    let history: [AssetComparisonPoint]
    let projection: [AssetComparisonPoint]

    var id: AssetCategory { category }
}

struct AssetComparisonPoint: Identifiable {
    let year: Int
    let value: Double

    var id: Int { year }
}

enum AssetCategory: String, CaseIterable, Identifiable {
    case internationalEquities
    case realEstate
    case preciousMetals

    var id: String { rawValue }

    var title: String {
        switch self {
        case .internationalEquities: return "Internationale Aktien"
        case .realEstate: return "Immobilienmärkte"
        case .preciousMetals: return "Edelmetalle"
        }
    }

    var subtitle: String {
        switch self {
        case .internationalEquities:
            return "MSCI World Näherung über Wachstum"
        case .realEstate:
            return "Kaufkraftbereinigte Immobilienpreise"
        case .preciousMetals:
            return "Physische Gold/ Silber Benchmarks"
        }
    }

    var icon: String {
        switch self {
        case .internationalEquities: return "globe.europe.africa.fill"
        case .realEstate: return "house.lodge.fill"
        case .preciousMetals: return "rhombus.fill"
        }
    }

    var baseValue: Double {
        switch self {
        case .internationalEquities: return 110
        case .realEstate: return 95
        case .preciousMetals: return 120
        }
    }

    func multiplier(for phase: BennerPhase) -> Double {
        switch self {
        case .internationalEquities:
            switch phase {
            case .goodTimes: return 0.06
            case .hardTimes: return -0.03
            case .panic: return -0.12
            }
        case .realEstate:
            switch phase {
            case .goodTimes: return 0.04
            case .hardTimes: return -0.02
            case .panic: return -0.08
            }
        case .preciousMetals:
            switch phase {
            case .goodTimes: return 0.02
            case .hardTimes: return 0.03
            case .panic: return 0.08
            }
        }
    }
}

private extension Collection where Element == Double {
    var average: Double? {
        guard isEmpty == false else { return nil }
        let total = reduce(0, +)
        return total / Double(count)
    }
}
