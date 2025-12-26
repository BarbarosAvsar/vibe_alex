import Foundation
import Observation

enum AppLanguage: String, CaseIterable, Identifiable {
    case german = "de"
    case english = "en"
    case french = "fr"
    case spanish = "es"

    var id: String { rawValue }
    var locale: Locale { Locale(identifier: rawValue) }
}

@MainActor
@Observable
final class LanguageSettings {
    private let defaults: UserDefaults
    private let storageKey = "preferredLanguage"

    var selectedLanguage: AppLanguage {
        didSet {
            defaults.set(selectedLanguage.rawValue, forKey: storageKey)
        }
    }

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        if let stored = defaults.string(forKey: storageKey),
           let language = AppLanguage(rawValue: stored) {
            selectedLanguage = language
        } else {
            selectedLanguage = .german
        }
    }

    var locale: Locale { selectedLanguage.locale }
}

enum Localization {
    static func text(_ key: String, language: AppLanguage) -> String {
        LocalizationStore.strings[language]?[key]
        ?? LocalizationStore.strings[.german]?[key]
        ?? key
    }

    static func format(_ key: String, language: AppLanguage, _ args: CVarArg...) -> String {
        let format = text(key, language: language)
        return String(format: format, locale: language.locale, arguments: args)
    }

    static func plural(_ key: String, count: Int, language: AppLanguage, _ args: CVarArg...) -> String {
        let variant = count == 1 ? "\(key)_one" : "\(key)_other"
        let format = text(variant, language: language)
        var arguments: [CVarArg] = [count]
        arguments.append(contentsOf: args)
        return String(format: format, locale: language.locale, arguments: arguments)
    }
}
