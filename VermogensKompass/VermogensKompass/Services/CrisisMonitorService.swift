import Foundation

struct CrisisMonitorService {
    private let client = HTTPClient()
    private let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }()

    func fetchEvents(limit: Int = 12) async throws -> [CrisisEvent] {
        async let quakes = fetchEarthquakes()
        async let storms = fetchStormAlerts()
        async let geopolitical = fetchGeopoliticalAlerts()
        async let financial = fetchFinancialStress()

        let quakesEvents = try await quakes
        let stormEvents = await storms
        let geopoliticalEvents = await geopolitical
        let financialEvents = await financial

        let merged = [quakesEvents, stormEvents, geopoliticalEvents, financialEvents].flatMap { $0 }
        let sorted = merged.sorted { $0.occurredAt > $1.occurredAt }
        return Array(sorted.prefix(limit))
    }

    private func fetchEarthquakes() async throws -> [CrisisEvent] {
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

    private func fetchStormAlerts() async -> [CrisisEvent] {
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

    private func fetchGeopoliticalAlerts() async -> [CrisisEvent] {
        let watchList = [("Ukraine", "UKR"), ("Israel", "ISR"), ("Taiwan", "TWN"), ("South Africa", "ZAF"), ("Germany", "DEU")]
        return await withTaskGroup(of: CrisisEvent?.self, returning: [CrisisEvent].self) { group in
            for (name, code) in watchList {
                group.addTask {
                    await fetchGovernanceAlert(for: name, countryCode: code)
                }
            }
            var events: [CrisisEvent] = []
            for await event in group {
                if let event { events.append(event) }
            }
            return events
        }
    }

    private func fetchFinancialStress() async -> [CrisisEvent] {
        let watchList = [("Germany", "DEU"), ("United States", "USA"), ("United Kingdom", "GBR"), ("Japan", "JPN"), ("China", "CHN")]
        return await withTaskGroup(of: CrisisEvent?.self, returning: [CrisisEvent].self) { group in
            for (name, code) in watchList {
                group.addTask {
                    await fetchFinancialAlert(for: name, countryCode: code)
                }
            }
            var results: [CrisisEvent] = []
            for await event in group.compactMap({ $0 }) {
                results.append(event)
            }
            return results
        }
    }

    private func fetchFinancialAlert(for country: String, countryCode: String) async -> CrisisEvent? {
        guard let url = URL(string: "https://api.worldbank.org/v2/country/\(countryCode)/indicator/NY.GDP.MKTP.KD.ZG?format=json&per_page=2") else {
            return nil
        }
        guard let data = try? await client.get(url),
              let response = try? decoder.decode(WorldBankValueResponse.self, from: data),
              let latest = response.entries.first(where: { $0.value != nil }) else {
            return nil
        }
        guard let value = latest.value, value < 0 else {
            return nil
        }

        let yearDate = Calendar.current.date(from: DateComponents(year: Int(latest.date) ?? 2024)) ?? Date()

        return CrisisEvent(
            id: "finance-\(countryCode)",
            title: "Rezession \(country)",
            magnitude: abs(value),
            region: country,
            occurredAt: yearDate,
            detailURL: URL(string: "https://data.worldbank.org/indicator/NY.GDP.MKTP.KD.ZG"),
            source: .worldbankFinance,
            category: .financial
        )
    }

    private func fetchGovernanceAlert(for country: String, countryCode: String) async -> CrisisEvent? {
        guard let url = URL(string: "https://api.worldbank.org/v2/country/\(countryCode)/indicator/PV.PSR.PIND?format=json&per_page=2") else {
            return nil
        }
        guard let data = try? await client.get(url),
              let response = try? decoder.decode(WorldBankValueResponse.self, from: data),
              let latest = response.entries.first(where: { $0.value != nil }) else {
            return nil
        }
        guard let value = latest.value, value < -0.5 else {
            return nil
        }

        let yearDate = Calendar.current.date(from: DateComponents(year: Int(latest.date) ?? 2024)) ?? Date()

        return CrisisEvent(
            id: "geo-\(countryCode)",
            title: "Politische Instabilität \(country)",
            magnitude: abs(value) * 2,
            region: country,
            occurredAt: yearDate,
            detailURL: URL(string: "https://data.worldbank.org/indicator/PV.PSR.PIND"),
            source: .worldBankGovernance,
            category: .geopolitical
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
