import XCTest

#if canImport(CRISIS)
@testable import CRISIS
#elseif canImport(CRISISTahoe)
@testable import CRISISTahoe
#elseif canImport(CRISISVision)
@testable import CRISISVision
#elseif canImport(CRISISWatch)
@testable import CRISISWatch
#endif

final class CrisisFeedTests: XCTestCase {
    func testNewsFeedParsesArticles() async throws {
        let financialPayload = """
        {"articles":[{"source":{"name":"Reuters"},"title":"Banken geraten unter Druck","description":"Stress im Bankensektor","publishedAt":"2024-01-01T12:00:00Z"}]}
        """.data(using: .utf8)!
        let politicalPayload = """
        {"articles":[{"source":{"name":"AP"},"title":"Regierungskrise in Europa","description":"Koalition gerät ins Wanken","publishedAt":"2024-01-02T08:00:00Z"}]}
        """.data(using: .utf8)!
        let businessURL = Self.topHeadlinesURL.absoluteString
        let politicsURL = Self.politicsURL.absoluteString
        let stub = StubHTTPClient(responses: [
            businessURL: financialPayload,
            politicsURL: politicalPayload
        ])
        let feed = PoliticalFinancialNewsFeed(client: stub, apiKey: "test-key")

        let events = try await feed.fetchEvents()

        XCTAssertEqual(events.count, 2)
        XCTAssertEqual(events.first?.category, .financial)
        XCTAssertEqual(events.last?.category, .geopolitical)
        XCTAssertEqual(events.last?.region, "AP")
    }

    func testNewsFeedReturnsEmptyWhenAPIKeyMissing() async throws {
        let feed = PoliticalFinancialNewsFeed(client: StubHTTPClient(responses: [:]), apiKey: nil)
        let events = try await feed.fetchEvents()
        XCTAssertTrue(events.isEmpty)
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

    private static var topHeadlinesURL: URL {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "newsapi.org"
        components.path = "/v2/top-headlines"
        components.queryItems = [
            URLQueryItem(name: "language", value: "en"),
            URLQueryItem(name: "pageSize", value: "6"),
            URLQueryItem(name: "category", value: "business")
        ]
        return components.url!
    }

    private static var politicsURL: URL {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "newsapi.org"
        components.path = "/v2/everything"
        components.queryItems = [
            URLQueryItem(name: "language", value: "en"),
            URLQueryItem(name: "pageSize", value: "6"),
            URLQueryItem(name: "sortBy", value: "publishedAt"),
            URLQueryItem(name: "q", value: "geopolitics OR government OR election OR crisis OR war")
        ]
        return components.url!
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

    func send(_ request: URLRequest) async throws -> Data {
        guard let url = request.url else {
            throw Error.missingResponse
        }
        return try await get(url)
    }
}

