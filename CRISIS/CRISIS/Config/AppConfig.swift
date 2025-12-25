import Foundation

enum AppConfig {
    static let minimumSupportedOS = "iOS 26"

    static let focusCountryISO = "DEU"
    static let consultationEndpoint = URL(string: "https://api.midainvest.com/contact")!

    static var newsAPIKey: String? {
        if let envKey = ProcessInfo.processInfo.environment["NEWSAPI_API_KEY"], envKey.isEmpty == false {
            return envKey
        }
        return Bundle.main.object(forInfoDictionaryKey: "NEWSAPI_API_KEY") as? String
    }
}
