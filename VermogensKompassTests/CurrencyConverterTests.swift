import XCTest
@testable import VermogensKompass

final class CurrencyConverterTests: XCTestCase {
    func testConvertUsdToEur() {
        let rates = ExchangeRates(base: .eur, timestamp: Date(), values: [.usd: 1.1])
        let converter = CurrencyConverter(rates: rates)
        let amount = converter.convert(amount: 110, from: .usd, to: .eur)
        XCTAssertEqual(amount, 100, accuracy: 0.001)
    }

    func testConvertEurToUsd() {
        let rates = ExchangeRates(base: .eur, timestamp: Date(), values: [.usd: 1.2])
        let converter = CurrencyConverter(rates: rates)
        let amount = converter.convert(amount: 50, from: .eur, to: .usd)
        XCTAssertEqual(amount, 60, accuracy: 0.001)
    }

    func testFallsBackWhenRatesMissing() {
        let converter = CurrencyConverter(rates: nil)
        XCTAssertEqual(converter.convert(amount: 42, from: .usd, to: .eur), 42)
    }

    func testStringBasedConversion() {
        let rates = ExchangeRates(base: .eur, timestamp: Date(), values: [.usd: 1.25])
        let converter = CurrencyConverter(rates: rates)
        XCTAssertEqual(converter.convert(amount: 80, from: "USD", to: .eur), 64, accuracy: 0.001)
    }
}
