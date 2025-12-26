import Foundation

extension AppLanguage {
    func localizedName(in language: AppLanguage) -> String {
        switch self {
        case .german:
            return Localization.text("language_de", language: language)
        case .english:
            return Localization.text("language_en", language: language)
        case .french:
            return Localization.text("language_fr", language: language)
        case .spanish:
            return Localization.text("language_es", language: language)
        }
    }
}

extension DisplayCurrency {
    func localizedTitle(language: AppLanguage) -> String {
        switch self {
        case .eur:
            return Localization.text("currency_eur", language: language)
        case .usd:
            return Localization.text("currency_usd", language: language)
        }
    }
}

extension MacroIndicatorKind {
    func localizedTitle(language: AppLanguage) -> String {
        switch self {
        case .inflation:
            return Localization.text("macro_indicator_inflation_title", language: language)
        case .growth:
            return Localization.text("macro_indicator_growth_title", language: language)
        case .defense:
            return Localization.text("macro_indicator_defense_title", language: language)
        }
    }

    func localizedUnit(language: AppLanguage) -> String {
        switch self {
        case .inflation:
            return Localization.text("macro_indicator_inflation_unit", language: language)
        case .growth:
            return Localization.text("macro_indicator_growth_unit", language: language)
        case .defense:
            return Localization.text("macro_indicator_defense_unit", language: language)
        }
    }

    func localizedDescription(language: AppLanguage) -> String {
        switch self {
        case .inflation:
            return Localization.text("macro_indicator_inflation_description", language: language)
        case .growth:
            return Localization.text("macro_indicator_growth_description", language: language)
        case .defense:
            return Localization.text("macro_indicator_defense_description", language: language)
        }
    }
}

extension BennerPhase {
    func localizedTitle(language: AppLanguage) -> String {
        switch self {
        case .panic:
            return Localization.text("benner_phase_panic_title", language: language)
        case .goodTimes:
            return Localization.text("benner_phase_good_title", language: language)
        case .hardTimes:
            return Localization.text("benner_phase_hard_title", language: language)
        }
    }

    func localizedSubtitle(language: AppLanguage) -> String {
        switch self {
        case .panic:
            return Localization.text("benner_phase_panic_subtitle", language: language)
        case .goodTimes:
            return Localization.text("benner_phase_good_subtitle", language: language)
        case .hardTimes:
            return Localization.text("benner_phase_hard_subtitle", language: language)
        }
    }

    func localizedGuidance(language: AppLanguage) -> String {
        switch self {
        case .panic:
            return Localization.text("benner_phase_panic_guidance", language: language)
        case .goodTimes:
            return Localization.text("benner_phase_good_guidance", language: language)
        case .hardTimes:
            return Localization.text("benner_phase_hard_guidance", language: language)
        }
    }
}

extension ComparisonAsset {
    func localizedName(language: AppLanguage) -> String {
        switch self {
        case .equityDE:
            return Localization.text("asset_equity_de", language: language)
        case .equityUSA:
            return Localization.text("asset_equity_usa", language: language)
        case .equityLON:
            return Localization.text("asset_equity_lon", language: language)
        case .realEstateDE:
            return Localization.text("asset_real_estate_de", language: language)
        case .realEstateES:
            return Localization.text("asset_real_estate_es", language: language)
        case .realEstateFR:
            return Localization.text("asset_real_estate_fr", language: language)
        case .realEstateLON:
            return Localization.text("asset_real_estate_lon", language: language)
        case .gold:
            return Localization.text("asset_gold", language: language)
        case .silver:
            return Localization.text("asset_silver", language: language)
        }
    }
}

extension AssetGroup {
    func localizedLabel(language: AppLanguage) -> String {
        switch self {
        case .equities:
            return Localization.text("asset_group_equities", language: language)
        case .realEstate:
            return Localization.text("asset_group_real_estate", language: language)
        case .metals:
            return Localization.text("asset_group_metals", language: language)
        }
    }
}

extension CrisisCategory {
    func localizedLabel(language: AppLanguage) -> String {
        switch self {
        case .financial:
            return Localization.text("crisis_category_financial", language: language)
        case .geopolitical:
            return Localization.text("crisis_category_geopolitical", language: language)
        }
    }
}

extension MetalAsset {
    func localizedName(language: AppLanguage) -> String {
        switch id.uppercased() {
        case "XAU":
            return Localization.text("asset_gold", language: language)
        case "XAG":
            return Localization.text("asset_silver", language: language)
        default:
            return name
        }
    }
}

extension MetalInsight {
    func localizedLabel(language: AppLanguage) -> String {
        switch icon {
        case "arrow.triangle.2.circlepath":
            return Localization.text("metal_insight_24h", language: language)
        case "dollarsign.arrow.circlepath":
            return Localization.text("metal_insight_change", language: language)
        default:
            return label
        }
    }
}

func localizedWatchlistCountry(_ name: String, language: AppLanguage) -> String {
    switch name.lowercased() {
    case "ukraine":
        return Localization.text("watchlist_country_ukraine", language: language)
    case "israel":
        return Localization.text("watchlist_country_israel", language: language)
    case "taiwan", "taipei":
        return Localization.text("watchlist_country_taiwan", language: language)
    case "south africa":
        return Localization.text("watchlist_country_south_africa", language: language)
    case "germany":
        return Localization.text("watchlist_country_germany", language: language)
    case "usa", "us", "united states":
        return Localization.text("watchlist_country_usa", language: language)
    case "uk", "united kingdom", "great britain":
        return Localization.text("watchlist_country_uk", language: language)
    case "japan":
        return Localization.text("watchlist_country_japan", language: language)
    case "china":
        return Localization.text("watchlist_country_china", language: language)
    default:
        return name
    }
}

func localizedCrisisEventTitle(_ event: CrisisEvent, language: AppLanguage) -> String {
    let regionLabel = localizedWatchlistCountry(event.region, language: language)
    switch event.source {
    case .worldBankGovernance:
        return Localization.format("crisis_event_title_governance", language: language, regionLabel)
    case .worldbankFinance:
        return Localization.format("crisis_event_title_recession", language: language, regionLabel)
    default:
        return event.title
    }
}

extension CrisisEvent {
    func localizedSeverityBadge(language: AppLanguage) -> String {
        switch severityScore {
        case ..<4:
            return Localization.text("crisis_badge_info", language: language)
        case 4..<6:
            return Localization.text("crisis_badge_moderate", language: language)
        default:
            return Localization.text("crisis_badge_high", language: language)
        }
    }
}
