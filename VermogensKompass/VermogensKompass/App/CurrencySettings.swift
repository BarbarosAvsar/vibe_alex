import Foundation
import Observation

@MainActor
@Observable
final class CurrencySettings {
    private let defaults: UserDefaults
    private let rateService: ExchangeRateService
    private let storageKey = "preferredCurrency"

    var selectedCurrency: DisplayCurrency {
        didSet {
            defaults.set(selectedCurrency.rawValue, forKey: storageKey)
        }
    }

    private(set) var exchangeRates: ExchangeRates?

    init(
        defaults: UserDefaults = .standard,
        rateService: ExchangeRateService = ExchangeRateService()
    ) {
        self.defaults = defaults
        self.rateService = rateService
        if let stored = defaults.string(forKey: storageKey),
           let currency = DisplayCurrency(rawValue: stored) {
            selectedCurrency = currency
        } else {
            selectedCurrency = .eur
        }
    }

    func refreshRates() async {
        guard exchangeRates?.timestamp.addingTimeInterval(43_200) ?? .distantPast < Date() else {
            return
        }

        if let rates = try? await rateService.fetchRates() {
            exchangeRates = rates
        }
    }

    var converter: CurrencyConverter {
        CurrencyConverter(rates: exchangeRates)
    }
}
