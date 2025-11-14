import Foundation

protocol CrisisFeedService: Sendable {
    func fetchEvents() async throws -> [CrisisEvent]
}

struct CrisisMonitorService {
    private let feeds: [any CrisisFeedService]

    init(feeds: [any CrisisFeedService]? = nil, client: HTTPClienting = HTTPClient()) {
        if let feeds {
            self.feeds = feeds
        } else {
            self.feeds = [
                EarthquakeCrisisFeed(client: client),
                StormAlertCrisisFeed(client: client),
                GeopoliticalAlertCrisisFeed(client: client),
                FinancialStressCrisisFeed(client: client)
            ]
        }
    }

    func fetchEvents(limit: Int = 12) async throws -> [CrisisEvent] {
        var aggregated: [CrisisEvent] = []
        try await withThrowingTaskGroup(of: [CrisisEvent].self) { group in
            for feed in feeds {
                group.addTask {
                    try await feed.fetchEvents()
                }
            }

            for try await events in group {
                aggregated.append(contentsOf: events)
            }
        }

        let sorted = aggregated.sorted { $0.occurredAt > $1.occurredAt }
        return Array(sorted.prefix(limit))
    }
}

struct EarthquakeCrisisFeed: CrisisFeedService {
    private let client: HTTPClienting
    private let decoder = JSONDecoder()

    init(client: HTTPClienting = HTTPClient()) {
        self.client = client
    }

    func fetchEvents() async throws -> [CrisisEvent] {
        guard let url = URL(string: "https://earthquake.usgs.gov/earthquakes/feed/v1.0/summary/all_week.geojson") else {
            return []
        }
        let data = try await client.get(url)
        let feed = try decoder.decode(USGSResponse.self, from: data)

        return feed.features.map { feature in
            CrisisEvent(
                id: feature.id,
                title: feature.properties.title,
                magnitude: feature.properties.mag,
                region: feature.properties.place,
                occurredAt: Date(timeIntervalSince1970: feature.properties.time / 1000),
                detailURL: URL(string: feature.properties.url),
                source: .usgs,
                category: .seismic
            )
        }
    }
}

struct StormAlertCrisisFeed: CrisisFeedService {
    private let client: HTTPClienting
    private let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }()

    init(client: HTTPClienting = HTTPClient()) {
        self.client = client
    }

    func fetchEvents() async throws -> [CrisisEvent] {
        guard let url = URL(string: "https://api.weather.gov/alerts/active?status=actual&message_type=alert") else {
            return []
        }
        guard let data = try? await client.get(url),
              let response = try? decoder.decode(NOAAResponse.self, from: data) else {
            return []
        }

        return response.features
            .filter { feature in
                guard let event = feature.properties.event?.lowercased() else { return false }
                return event.contains("storm") || event.contains("hurricane") || event.contains("tornado")
            }
            .prefix(8)
            .map { feature in
                let severityScore = feature.properties.severity?.severityScore ?? 4
                return CrisisEvent(
                    id: feature.id,
                    title: feature.properties.headline ?? (feature.properties.event ?? "Unwetter"),
                    magnitude: Double(severityScore),
                    region: feature.properties.areaDesc ?? "USA",
                    occurredAt: feature.properties.effective ?? Date(),
                    detailURL: URL(string: feature.id),
                    source: .noaa,
                    category: .storm
                )
            }
    }
}

struct GeopoliticalAlertCrisisFeed: CrisisFeedService {
    private let client: HTTPClienting
    private let decoder = JSONDecoder()
    private let watchList: [(name: String, code: String)]

    init(
        client: HTTPClienting = HTTPClient(),
        watchList: [(String, String)] = [("Ukraine", "UKR"), ("Israel", "ISR"), ("Taiwan", "TWN"), ("South Africa", "ZAF"), ("Germany", "DEU")]
    ) {
        self.client = client
        self.watchList = watchList
    }

    func fetchEvents() async throws -> [CrisisEvent] {
        try await withThrowingTaskGroup(of: CrisisEvent?.self) { group in
            for entry in watchList {
                group.addTask {
                    try await self.fetchGovernanceAlert(for: entry)
                }
            }

            var events: [CrisisEvent] = []
            for try await result in group {
                if let event = result {
                    events.append(event)
                }
            }
            return events
        }
    }

    private func fetchGovernanceAlert(for entry: (name: String, code: String)) async throws -> CrisisEvent? {
        guard let url = URL(string: "https://api.worldbank.org/v2/country/\(entry.code)/indicator/PV.PSR.PIND?format=json&per_page=2") else {
            return nil
        }
        guard let data = try? await client.get(url),
              let response = try? decoder.decode(WorldBankValueResponse.self, from: data),
              let latest = response.entries.first(where: { $0.value != nil }),
              let value = latest.value,
              value < CrisisThresholds.politicalInstabilityCutoff else {
            return nil
        }

        let yearDate = makeYearDate(from: latest.date)

        return CrisisEvent(
            id: "geo-\(entry.code)",
            title: "Politische Instabilität \(entry.name)",
            magnitude: abs(value) * 2,
            region: entry.name,
            occurredAt: yearDate,
            detailURL: URL(string: "https://data.worldbank.org/indicator/PV.PSR.PIND"),
            source: .worldBankGovernance,
            category: .geopolitical
        )
    }
}

struct FinancialStressCrisisFeed: CrisisFeedService {
    private let client: HTTPClienting
    private let decoder = JSONDecoder()
    private let watchList: [(name: String, code: String)]

    init(
        client: HTTPClienting = HTTPClient(),
        watchList: [(String, String)] = [("Germany", "DEU"), ("United States", "USA"), ("United Kingdom", "GBR"), ("Japan", "JPN"), ("China", "CHN")]
    ) {
        self.client = client
        self.watchList = watchList
    }

    func fetchEvents() async throws -> [CrisisEvent] {
        try await withThrowingTaskGroup(of: CrisisEvent?.self) { group in
            for entry in watchList {
                group.addTask {
                    try await self.fetchAlert(for: entry)
                }
            }

            var events: [CrisisEvent] = []
            for try await result in group {
                if let event = result {
                    events.append(event)
                }
            }
            return events
        }
    }

    private func fetchAlert(for entry: (name: String, code: String)) async throws -> CrisisEvent? {
        guard let url = URL(string: "https://api.worldbank.org/v2/country/\(entry.code)/indicator/NY.GDP.MKTP.KD.ZG?format=json&per_page=2") else {
            return nil
        }
        guard let data = try? await client.get(url),
              let response = try? decoder.decode(WorldBankValueResponse.self, from: data),
              let latest = response.entries.first(where: { $0.value != nil }),
              let value = latest.value,
              value < CrisisThresholds.recessionGrowthCutoff else {
            return nil
        }

        let yearDate = makeYearDate(from: latest.date)

        return CrisisEvent(
            id: "finance-\(entry.code)",
            title: "Rezession \(entry.name)",
            magnitude: abs(value),
            region: entry.name,
            occurredAt: yearDate,
            detailURL: URL(string: "https://data.worldbank.org/indicator/NY.GDP.MKTP.KD.ZG"),
            source: .worldbankFinance,
            category: .financial
        )
    }
}

private struct USGSResponse: Decodable {
    struct Feature: Decodable {
        struct Properties: Decodable {
            let mag: Double?
            let place: String
            let time: TimeInterval
            let url: String
            let title: String
        }
        let id: String
        let properties: Properties
    }

    let features: [Feature]
}

private struct NOAAResponse: Decodable {
    struct Feature: Decodable {
        struct Properties: Decodable {
            let event: String?
            let headline: String?
            let severity: String?
            let areaDesc: String?
            let effective: Date?
        }
        let id: String
        let properties: Properties
    }
    let features: [Feature]
}

private struct WorldBankValueResponse: Decodable {
    struct Entry: Decodable {
        let date: String
        let value: Double?
    }

    let entries: [Entry]

    init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        _ = try? container.decode(DecodableIgnored.self)
        entries = try container.decode([Entry].self)
    }
}

private struct DecodableIgnored: Decodable { }

private extension String {
    var severityScore: Int {
        switch lowercased() {
        case "extreme": return 6
        case "severe": return 5
        case "moderate": return 4
        case "minor": return 3
        default: return 2
        }
    }
}

private func makeYearDate(from year: String) -> Date {
    Calendar.current.date(from: DateComponents(year: Int(year) ?? 2024)) ?? Date()
}
