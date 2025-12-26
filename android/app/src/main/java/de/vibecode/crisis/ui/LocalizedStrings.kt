package de.vibecode.crisis.ui

import androidx.compose.runtime.Composable
import androidx.compose.ui.res.stringResource
import de.vibecode.crisis.AppLanguage
import de.vibecode.crisis.R
import de.vibecode.crisis.core.domain.AssetGroup
import de.vibecode.crisis.core.domain.BennerPhase
import de.vibecode.crisis.core.domain.ComparisonAsset
import de.vibecode.crisis.core.model.CrisisEvent
import de.vibecode.crisis.core.model.DataSource
import de.vibecode.crisis.core.model.DisplayCurrency
import de.vibecode.crisis.core.model.MacroIndicatorKind
import de.vibecode.crisis.core.model.MetalInsight

@Composable
fun appLanguageLabel(language: AppLanguage): String = stringResource(language.labelRes)

@Composable
fun displayCurrencyLabel(currency: DisplayCurrency): String {
    return when (currency) {
        DisplayCurrency.EUR -> stringResource(R.string.currency_eur)
        DisplayCurrency.USD -> stringResource(R.string.currency_usd)
    }
}

@Composable
fun assetGroupLabel(group: AssetGroup): String {
    return when (group) {
        AssetGroup.EQUITIES -> stringResource(R.string.asset_group_equities)
        AssetGroup.REAL_ESTATE -> stringResource(R.string.asset_group_real_estate)
        AssetGroup.METALS -> stringResource(R.string.asset_group_metals)
    }
}

@Composable
fun comparisonAssetLabel(asset: ComparisonAsset): String {
    return when (asset) {
        ComparisonAsset.EQUITY_DE -> stringResource(R.string.asset_equity_de)
        ComparisonAsset.EQUITY_USA -> stringResource(R.string.asset_equity_usa)
        ComparisonAsset.EQUITY_LON -> stringResource(R.string.asset_equity_lon)
        ComparisonAsset.REAL_ESTATE_DE -> stringResource(R.string.asset_real_estate_de)
        ComparisonAsset.REAL_ESTATE_ES -> stringResource(R.string.asset_real_estate_es)
        ComparisonAsset.REAL_ESTATE_FR -> stringResource(R.string.asset_real_estate_fr)
        ComparisonAsset.REAL_ESTATE_LON -> stringResource(R.string.asset_real_estate_lon)
        ComparisonAsset.GOLD -> stringResource(R.string.asset_gold)
        ComparisonAsset.SILVER -> stringResource(R.string.asset_silver)
    }
}

@Composable
fun macroIndicatorTitle(kind: MacroIndicatorKind): String {
    return when (kind) {
        MacroIndicatorKind.INFLATION -> stringResource(R.string.macro_indicator_inflation_title)
        MacroIndicatorKind.GROWTH -> stringResource(R.string.macro_indicator_growth_title)
        MacroIndicatorKind.DEFENSE -> stringResource(R.string.macro_indicator_defense_title)
    }
}

@Composable
fun macroIndicatorUnit(kind: MacroIndicatorKind): String {
    return when (kind) {
        MacroIndicatorKind.INFLATION -> stringResource(R.string.macro_indicator_inflation_unit)
        MacroIndicatorKind.GROWTH -> stringResource(R.string.macro_indicator_growth_unit)
        MacroIndicatorKind.DEFENSE -> stringResource(R.string.macro_indicator_defense_unit)
    }
}

@Composable
fun macroIndicatorDescription(kind: MacroIndicatorKind): String {
    return when (kind) {
        MacroIndicatorKind.INFLATION -> stringResource(R.string.macro_indicator_inflation_description)
        MacroIndicatorKind.GROWTH -> stringResource(R.string.macro_indicator_growth_description)
        MacroIndicatorKind.DEFENSE -> stringResource(R.string.macro_indicator_defense_description)
    }
}

@Composable
fun bennerPhaseTitle(phase: BennerPhase): String {
    return when (phase) {
        BennerPhase.PANIC -> stringResource(R.string.benner_phase_panic_title)
        BennerPhase.GOOD_TIMES -> stringResource(R.string.benner_phase_good_title)
        BennerPhase.HARD_TIMES -> stringResource(R.string.benner_phase_hard_title)
    }
}

@Composable
fun bennerPhaseSubtitle(phase: BennerPhase): String {
    return when (phase) {
        BennerPhase.PANIC -> stringResource(R.string.benner_phase_panic_subtitle)
        BennerPhase.GOOD_TIMES -> stringResource(R.string.benner_phase_good_subtitle)
        BennerPhase.HARD_TIMES -> stringResource(R.string.benner_phase_hard_subtitle)
    }
}

@Composable
fun bennerPhaseGuidance(phase: BennerPhase): String {
    return when (phase) {
        BennerPhase.PANIC -> stringResource(R.string.benner_phase_panic_guidance)
        BennerPhase.GOOD_TIMES -> stringResource(R.string.benner_phase_good_guidance)
        BennerPhase.HARD_TIMES -> stringResource(R.string.benner_phase_hard_guidance)
    }
}

@Composable
fun watchlistCountryLabel(code: String): String {
    return when (code.uppercase()) {
        "UKR" -> stringResource(R.string.watchlist_country_ukraine)
        "ISR" -> stringResource(R.string.watchlist_country_israel)
        "TWN" -> stringResource(R.string.watchlist_country_taiwan)
        "ZAF" -> stringResource(R.string.watchlist_country_south_africa)
        "DEU" -> stringResource(R.string.watchlist_country_germany)
        "USA" -> stringResource(R.string.watchlist_country_usa)
        "GBR" -> stringResource(R.string.watchlist_country_uk)
        "JPN" -> stringResource(R.string.watchlist_country_japan)
        "CHN" -> stringResource(R.string.watchlist_country_china)
        else -> code
    }
}

@Composable
fun metalInsightLabel(insight: MetalInsight): String {
    return when (insight.label.trim().lowercase()) {
        "24h" -> stringResource(R.string.metal_insight_24h)
        "veränderung", "veraenderung" -> stringResource(R.string.metal_insight_change)
        else -> insight.label
    }
}

@Composable
fun crisisEventTitle(event: CrisisEvent): String {
    return when (event.source) {
        DataSource.WORLD_BANK_GOVERNANCE -> stringResource(R.string.crisis_event_title_governance, event.region)
        DataSource.WORLD_BANK_FINANCE -> stringResource(R.string.crisis_event_title_recession, event.region)
        else -> event.title
    }
}
