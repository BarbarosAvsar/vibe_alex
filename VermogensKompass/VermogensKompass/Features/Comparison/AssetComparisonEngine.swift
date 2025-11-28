import Foundation

struct AssetComparisonEngine {
    private let marketService = MarketDataService()

    func loadAssets(from snapshot: DashboardSnapshot, forecasts: [BennerCycleEntry]) async -> [ComparisonAssetSeries] {
        var series: [ComparisonAssetSeries] = []

        for asset in ComparisonAsset.allCases {
            let history = await makeHistory(for: asset, snapshot: snapshot)
            let projection = makeProjection(for: asset, forecasts: forecasts, history: history)
            series.append(ComparisonAssetSeries(asset: asset, history: history, projection: projection))
        }
        return series
    }

    private func makeHistory(for asset: ComparisonAsset, snapshot: DashboardSnapshot) async -> [ComparisonPoint] {
        if let instrument = asset.marketInstrument {
            if let fetched = try? await marketService.fetchHistory(for: instrument, limitYears: 10), fetched.isEmpty == false {
                return fetched
            }
        }

        // Fallback auf vorherige Heuristik, falls keine Marktdaten vorhanden sind.
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

    var marketInstrument: MarketInstrument? {
        switch self {
        case .equityDE: return .dax
        case .equityUSA: return .spx
        case .equityLON: return .ftse
        case .realEstateDE: return .euroRealEstate
        case .realEstateES: return .euroRealEstate
        case .realEstateFR: return .euroRealEstate
        case .realEstateLON: return .usRealEstate
        case .gold: return .xau
        case .silver: return .xag
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

enum MarketInstrument: String {
    case dax = "^dax"
    case spx = "^spx"
    case ftse = "^ftse"
    case usRealEstate = "vnq.us"
    case euroRealEstate = "iqq7.de"
    case xau = "xauusd"
    case xag = "xagusd"
}

struct MarketDataService {
    private let client: HTTPClienting
    private let formatter: DateFormatter

    init(client: HTTPClienting = HTTPClient()) {
        self.client = client
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        f.locale = Locale(identifier: "en_US_POSIX")
        self.formatter = f
    }

    func fetchHistory(for instrument: MarketInstrument, limitYears: Int) async throws -> [ComparisonPoint] {
        guard let url = URL(string: "https://stooq.pl/q/d/l/?s=\(instrument.rawValue)&i=d") else { return [] }
        let data = try await client.get(url)
        guard let text = String(data: data, encoding: .utf8) else { return [] }
        let lines = text.split(separator: "\n").dropFirst() // drop header

        var points: [ComparisonPoint] = lines.compactMap { line in
            let parts = line.split(separator: ",")
            guard parts.count >= 5,
                  let date = formatter.date(from: String(parts[0])),
                  let close = Double(parts[4]) else { return nil }
            let year = Calendar.current.component(.year, from: date)
            return ComparisonPoint(year: year, value: close)
        }

        points.sort { $0.year < $1.year }

        if limitYears > 0, let maxYear = points.map(\.year).max() {
            let threshold = maxYear - limitYears
            points = points.filter { $0.year >= threshold }
        }

        return points
    }
}
