import Foundation

struct MacroIndicator: Identifiable, Hashable, Codable {
    let id: MacroIndicatorKind
    let title: String
    let latestValue: Double?
    let previousValue: Double?
    let unit: String
    let description: String
    let source: DataSource

    var formattedValue: String {
        guard let latestValue else { return "–" }
        return latestValue.formatted(.number.precision(.fractionLength(1))) + unit
    }

    var deltaDescription: String {
        guard let latest = latestValue, let previous = previousValue else { return "Kein Verlauf" }
        let delta = latest - previous
        return (delta >= 0 ? "+" : "") +
            delta.formatted(.number.precision(.fractionLength(1))) + unit + " vs. Vorjahr"
    }
}

enum MacroIndicatorKind: String, CaseIterable, Identifiable, Codable {
    case inflation
    case growth
    case defense

    var id: String { rawValue }

    var title: String {
        switch self {
        case .inflation: return "Inflation"
        case .growth: return "Wachstum"
        case .defense: return "Verteidigung"
        }
    }

    var indicatorCode: String {
        switch self {
        case .inflation: return "FP.CPI.TOTL.ZG"
        case .growth: return "NY.GDP.MKTP.KD.ZG"
        case .defense: return "MS.MIL.XPND.GD.ZS"
        }
    }

    var unit: String {
        switch self {
        case .defense: return "% BIP"
        default: return "%"
        }
    }

    var explanation: String {
        switch self {
        case .inflation:
            return "Jährliche Verbraucherpreisinflation laut Weltbank"
        case .growth:
            return "Reales BIP-Wachstum"
        case .defense:
            return "Militärausgaben im Verhältnis zum BIP"
        }
    }
}

struct MacroDataPoint: Identifiable, Hashable, Codable {
    let id: UUID
    let year: Int
    let value: Double

    init(id: UUID = UUID(), year: Int, value: Double) {
        self.id = id
        self.year = year
        self.value = value
    }
}

struct MacroSeries: Identifiable, Hashable, Codable {
    let id: UUID
    let kind: MacroIndicatorKind
    let points: [MacroDataPoint]

    init(id: UUID = UUID(), kind: MacroIndicatorKind, points: [MacroDataPoint]) {
        self.id = id
        self.kind = kind
        self.points = points
    }
}

struct MacroOverview: Codable {
    let indicators: [MacroIndicator]
}

extension MacroIndicator {
    func localizedTitle(language: AppLanguage) -> String {
        id.localizedTitle(language: language)
    }

    func localizedUnit(language: AppLanguage) -> String {
        id.localizedUnit(language: language)
    }

    func localizedDescription(language: AppLanguage) -> String {
        id.localizedDescription(language: language)
    }

    func localizedFormattedValue(language: AppLanguage) -> String {
        guard let latestValue else {
            return Localization.text("not_available_short", language: language)
        }
        let formatter = FloatingPointFormatStyle<Double>.number
            .precision(.fractionLength(1))
            .locale(language.locale)
        return latestValue.formatted(formatter) + localizedUnit(language: language)
    }

    func localizedDeltaDescription(language: AppLanguage) -> String {
        guard let latest = latestValue, let previous = previousValue else {
            return Localization.text("macro_delta_no_trend", language: language)
        }
        let delta = latest - previous
        let formatter = FloatingPointFormatStyle<Double>.number
            .precision(.fractionLength(1))
            .locale(language.locale)
        let sign = delta >= 0 ? "+" : ""
        let deltaText = delta.formatted(formatter)
        let unit = localizedUnit(language: language)
        return Localization.format("macro_delta_vs_previous", language: language, sign, deltaText, unit)
    }
}
