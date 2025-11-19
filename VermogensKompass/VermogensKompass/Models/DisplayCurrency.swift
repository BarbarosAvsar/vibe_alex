import Foundation

enum DisplayCurrency: String, CaseIterable, Identifiable, Codable {
    case eur = "EUR"
    case usd = "USD"

    var id: String { rawValue }
    var code: String { rawValue }

    var title: String {
        switch self {
        case .eur: return "Euro (€)"
        case .usd: return "US-Dollar ($)"
        }
    }

    init?(currencyCode: String) {
        self.init(rawValue: currencyCode.uppercased())
    }
}
