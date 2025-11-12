import Foundation

struct MacroIndicatorService {
    private let client = HTTPClient()

    func fetchIndicator(_ kind: MacroIndicatorKind, limit: Int = 8) async throws -> (MacroIndicator, MacroSeries) {
        let code = kind.indicatorCode
        guard let url = URL(string: "https://api.worldbank.org/v2/country/\(AppConfig.focusCountryISO)/indicator/\(code)?format=json&per_page=\(limit)") else {
            throw URLError(.badURL)
        }
        let data = try await client.get(url)
        let response = try JSONDecoder().decode(WorldBankSeriesResponse.self, from: data)
        let points = response.entries.compactMap { entry -> MacroDataPoint? in
            guard let value = entry.value, let year = Int(entry.date) else { return nil }
            return MacroDataPoint(year: year, value: value)
        }.sorted(by: { $0.year < $1.year })

        let latestPoint = points.last
        let previousPoint = points.dropLast().last

        let indicator = MacroIndicator(
            id: kind,
            title: kind.title,
            latestValue: latestPoint?.value,
            previousValue: previousPoint?.value,
            unit: kind.unit,
            description: kind.explanation,
            source: .worldBank
        )

        let series = MacroSeries(kind: kind, points: points)
        return (indicator, series)
    }
}

private struct WorldBankSeriesResponse: Decodable {
    struct Entry: Decodable {
        let date: String
        let value: Double?
    }

    let entries: [Entry]

    init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        _ = try? container.decode(ResponseMeta.self)
        entries = try container.decode([Entry].self)
    }
}

private struct ResponseMeta: Decodable {}
