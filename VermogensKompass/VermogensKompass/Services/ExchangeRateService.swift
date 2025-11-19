import Foundation

struct ExchangeRates: Sendable {
    let base: DisplayCurrency
    let timestamp: Date
    private let values: [DisplayCurrency: Double]

    init(base: DisplayCurrency, timestamp: Date, values: [DisplayCurrency: Double]) {
        self.base = base
        self.timestamp = timestamp
        self.values = values
    }

    func multiplier(from source: DisplayCurrency, to target: DisplayCurrency) -> Double? {
        guard source != target else { return 1 }
        if source == base {
            return values[target]
        }
        if target == base {
            guard let rate = values[source] else { return nil }
            return 1 / rate
        }
        guard
            let sourceRate = values[source],
            let targetRate = values[target]
        else {
            return nil
        }
        return targetRate / sourceRate
    }
}

struct CurrencyConverter {
    let rates: ExchangeRates?

    func convert(amount: Double, from sourceCode: String, to target: DisplayCurrency) -> Double {
        guard let source = DisplayCurrency(currencyCode: sourceCode) else {
            return amount
        }
        return convert(amount: amount, from: source, to: target)
    }

    func convert(amount: Double, from source: DisplayCurrency, to target: DisplayCurrency) -> Double {
        guard let rates, let rate = rates.multiplier(from: source, to: target) else {
            return amount
        }
        return amount * rate
    }
}

struct ExchangeRateService {
    enum ServiceError: Error {
        case invalidResponse
        case missingRate
    }

    private let client: HTTPClienting

    init(client: HTTPClienting = HTTPClient()) {
        self.client = client
    }

    func fetchRates() async throws -> ExchangeRates {
        guard let url = URL(string: "https://www.ecb.europa.eu/stats/eurofxref/eurofxref-daily.xml") else {
            throw ServiceError.invalidResponse
        }
        let data = try await client.get(url)
        let parser = ECBRateParser()
        parser.parse(data: data)
        guard let usdRate = parser.rates["USD"], let date = parser.date else {
            throw ServiceError.missingRate
        }
        return ExchangeRates(base: .eur, timestamp: date, values: [.usd: usdRate])
    }
}

private final class ECBRateParser: NSObject, XMLParserDelegate {
    private(set) var rates: [String: Double] = [:]
    private(set) var date: Date?

    func parse(data: Data) {
        let parser = XMLParser(data: data)
        parser.delegate = self
        parser.parse()
    }

    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        if elementName == "Cube", let timeValue = attributeDict["time"] {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            formatter.locale = Locale(identifier: "en_US_POSIX")
            date = formatter.date(from: timeValue)
        }

        if elementName == "Cube", let currency = attributeDict["currency"], let rateText = attributeDict["rate"], let rate = Double(rateText) {
            rates[currency] = rate
        }
    }
}
