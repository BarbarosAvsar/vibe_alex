import Foundation

struct MetalPriceService {
    private let client = HTTPClient()

    func fetchAssets() async throws -> [MetalAsset] {
        guard let url = URL(string: "https://data-asg.goldprice.org/dbXRates/USD") else {
            throw URLError(.badURL)
        }
        let data = try await client.get(url)
        let payload = try JSONDecoder().decode(GoldPricePayload.self, from: data)
        guard let item = payload.items.first else {
            return []
        }

        let timestamp = Date(timeIntervalSince1970: TimeInterval(payload.ts / 1000))
        let gold = MetalAsset(
            id: "XAU",
            name: "Gold",
            symbol: "XAU",
            price: item.xauPrice,
            dailyChangePercentage: item.pcXau,
            currency: item.curr,
            lastUpdated: timestamp,
            insights: [
                MetalInsight(icon: "arrow.triangle.2.circlepath", label: "24h", value: Self.percentString(item.pcXau)),
                MetalInsight(icon: "dollarsign.arrow.circlepath", label: "Veränderung", value: item.chgXau.formatted(.number.precision(.fractionLength(2))))
            ],
            dataSource: .goldPrice
        )

        let silver = MetalAsset(
            id: "XAG",
            name: "Silber",
            symbol: "XAG",
            price: item.xagPrice,
            dailyChangePercentage: item.pcXag,
            currency: item.curr,
            lastUpdated: timestamp,
            insights: [
                MetalInsight(icon: "arrow.triangle.2.circlepath", label: "24h", value: Self.percentString(item.pcXag)),
                MetalInsight(icon: "dollarsign.arrow.circlepath", label: "Veränderung", value: item.chgXag.formatted(.number.precision(.fractionLength(2))))
            ],
            dataSource: .goldPrice
        )

        return [gold, silver]
    }
}

private struct GoldPricePayload: Decodable {
    struct Item: Decodable {
        let curr: String
        let xauPrice: Double
        let xagPrice: Double
        let chgXau: Double
        let chgXag: Double
        let pcXau: Double
        let pcXag: Double
    }

    let ts: Double
    let items: [Item]
}

private extension MetalPriceService {
    static func percentString(_ value: Double) -> String {
        value.formatted(.number.precision(.fractionLength(2))) + "%"
    }
}
