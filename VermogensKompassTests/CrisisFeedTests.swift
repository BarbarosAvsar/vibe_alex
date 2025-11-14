import XCTest
@testable import VermogensKompass

final class CrisisFeedTests: XCTestCase {
    func testEarthquakeFeedParsesEvents() async throws {
        let payload = """
        {"features":[{"id":"eq-1","properties":{"mag":5.6,"place":"Berlin","time":1700000000000,"url":"https://example.com/eq","title":"M 5.6 - Berlin"}}]}
        """.data(using: .utf8)!
        let stub = StubHTTPClient(responses: ["https://earthquake.usgs.gov/earthquakes/feed/v1.0/summary/all_week.geojson": payload])
        let feed = EarthquakeCrisisFeed(client: stub)

        let events = try await feed.fetchEvents()

        XCTAssertEqual(events.count, 1)
        XCTAssertEqual(events.first?.id, "eq-1")
        XCTAssertEqual(events.first?.category, .seismic)
    }

    func testGeopoliticalFeedHonorsInstabilityThreshold() async throws {
        let warningResponse = Self.makeWorldBankResponse(value: -0.8)
        let safeResponse = Self.makeWorldBankResponse(value: -0.2)
        let stub = StubHTTPClient(responses: [
            "https://api.worldbank.org/v2/country/TST/indicator/PV.PSR.PIND?format=json&per_page=2": warningResponse,
            "https://api.worldbank.org/v2/country/SFE/indicator/PV.PSR.PIND?format=json&per_page=2": safeResponse
        ])
        let feed = GeopoliticalAlertCrisisFeed(client: stub, watchList: [("Testland", "TST"), ("Safeland", "SFE")])

        let events = try await feed.fetchEvents()

        XCTAssertEqual(events.count, 1)
        XCTAssertEqual(events.first?.region, "Testland")
        XCTAssertEqual(events.first?.category, .geopolitical)
    }

    func testStormFeedFiltersEventsByKeyword() async throws {
        let payload = """
        {
          "features": [
            {"id": "storm-1", "properties": {"event": "Severe Storm", "headline": "Storm Warning", "severity": "severe", "areaDesc": "USA", "effective": "2024-01-01T00:00:00Z"}},
            {"id": "flood-1", "properties": {"event": "Flood", "headline": "Flood", "severity": "moderate", "areaDesc": "USA", "effective": "2024-01-01T00:00:00Z"}}
          ]
        }
        """.data(using: .utf8)!
        let stub = StubHTTPClient(responses: ["https://api.weather.gov/alerts/active?status=actual&message_type=alert": payload])
        let feed = StormAlertCrisisFeed(client: stub)

        let events = try await feed.fetchEvents()

        XCTAssertEqual(events.count, 1)
        XCTAssertEqual(events.first?.id, "storm-1")
        XCTAssertEqual(events.first?.category, .storm)
    }

    func testFinancialFeedOnlyEmitsNegativeGrowth() async throws {
        let recessionResponse = Self.makeWorldBankResponse(value: -1.2)
        let growthResponse = Self.makeWorldBankResponse(value: 2.4)
        let stub = StubHTTPClient(responses: [
            "https://api.worldbank.org/v2/country/GER/indicator/NY.GDP.MKTP.KD.ZG?format=json&per_page=2": recessionResponse,
            "https://api.worldbank.org/v2/country/USA/indicator/NY.GDP.MKTP.KD.ZG?format=json&per_page=2": growthResponse
        ])
        let feed = FinancialStressCrisisFeed(client: stub, watchList: [("Germany", "GER"), ("United States", "USA")])

        let events = try await feed.fetchEvents()

        XCTAssertEqual(events.count, 1)
        XCTAssertEqual(events.first?.region, "Germany")
        XCTAssertEqual(events.first?.category, .financial)
    }

    private static func makeWorldBankResponse(value: Double) -> Data {
        """
        [
          {"page":1},
          [
            {"date":"2023","value":\(value)}
          ]
        ]
        """.data(using: .utf8)!
    }
}

private final class StubHTTPClient: HTTPClienting {
    enum Error: Swift.Error {
        case missingResponse
    }

    private let responses: [URL: Data]

    init(responses: [String: Data]) {
        var storage: [URL: Data] = [:]
        for (key, value) in responses {
            storage[URL(string: key)!] = value
        }
        self.responses = storage
    }

    func get(_ url: URL) async throws -> Data {
        guard let data = responses[url] else {
            throw Error.missingResponse
        }
        return data
    }
}
