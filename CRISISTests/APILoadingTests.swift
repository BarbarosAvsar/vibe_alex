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

final class APILoadingTests: XCTestCase {
    func testMetalPriceServiceParsesAssets() async throws {
        let url = URL(string: "https://data-asg.goldprice.org/dbXRates/USD")!
        let payload = """
        {
          "ts": 1700000000000,
          "items": [
            {
              "curr": "USD",
              "xauPrice": 2000.5,
              "xagPrice": 23.4,
              "chgXau": 1.2,
              "chgXag": 0.5,
              "pcXau": 0.2,
              "pcXag": -0.1
            }
          ]
        }
        """
        let client = MockHTTPClient(dataByURL: [url: Data(payload.utf8)])
        let service = MetalPriceService(client: client)

        let assets = try await service.fetchAssets()

        XCTAssertEqual(assets.count, 2)
        XCTAssertEqual(assets[0].symbol, "XAU")
        XCTAssertEqual(assets[1].symbol, "XAG")
        XCTAssertEqual(assets[0].currency, "USD")
    }

    func testMacroIndicatorServiceParsesSeries() async throws {
        let url = URL(
            string: "https://api.worldbank.org/v2/country/DEU/indicator/FP.CPI.TOTL.ZG?format=json&per_page=8"
        )!
        let payload = """
        [
          { "page": 1, "pages": 1 },
          [
            { "date": "2023", "value": 1.2 },
            { "date": "2024", "value": 2.3 }
          ]
        ]
        """
        let client = MockHTTPClient(dataByURL: [url: Data(payload.utf8)])
        let service = MacroIndicatorService(client: client)

        let (indicator, series) = try await service.fetchIndicator(.inflation, limit: 8)

        XCTAssertEqual(indicator.latestValue, 2.3, accuracy: 0.001)
        XCTAssertEqual(indicator.previousValue, 1.2, accuracy: 0.001)
        XCTAssertEqual(series.points.map(\.year), [2023, 2024])
    }
}

private struct MockHTTPClient: HTTPClienting {
    enum MockError: Error {
        case missingData
    }

    let dataByURL: [URL: Data]

    func get(_ url: URL) async throws -> Data {
        try data(for: url)
    }

    func send(_ request: URLRequest) async throws -> Data {
        guard let url = request.url else {
            throw MockError.missingData
        }
        return try data(for: url)
    }

    private func data(for url: URL) throws -> Data {
        guard let data = dataByURL[url] else {
            throw MockError.missingData
        }
        return data
    }
}
