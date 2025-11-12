import Foundation

enum DataSource: String, Hashable, CaseIterable, Codable {
    case goldPrice = "GoldPrice.org"
    case worldBank = "World Bank"
    case usgs = "USGS"
    case noaa = "NOAA"
    case worldBankGovernance = "World Bank Governance"
    case worldbankFinance = "World Bank Finance"

    var url: URL {
        switch self {
        case .goldPrice:
            return URL(string: "https://data-asg.goldprice.org")!
        case .worldBank:
            return URL(string: "https://data.worldbank.org")!
        case .usgs:
            return URL(string: "https://earthquake.usgs.gov")!
        case .noaa:
            return URL(string: "https://api.weather.gov")!
        case .worldBankGovernance:
            return URL(string: "https://data.worldbank.org/indicator/PV.PSR.PIND")!
        case .worldbankFinance:
            return URL(string: "https://data.worldbank.org/indicator/NY.GDP.MKTP.KD.ZG")!
        }
    }
}

struct MetalAsset: Identifiable, Hashable, Codable {
    let id: String
    let name: String
    let symbol: String
    let price: Double
    let dailyChangePercentage: Double
    let currency: String
    let lastUpdated: Date
    let insights: [MetalInsight]
    let dataSource: DataSource
}

struct MetalInsight: Identifiable, Hashable, Codable {
    let id: UUID
    let icon: String
    let label: String
    let value: String

    init(id: UUID = UUID(), icon: String, label: String, value: String) {
        self.id = id
        self.icon = icon
        self.label = label
        self.value = value
    }
}
