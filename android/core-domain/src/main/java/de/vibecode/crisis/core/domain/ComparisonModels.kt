package de.vibecode.crisis.core.domain

enum class AssetGroup(val label: String) {
    EQUITIES("Aktienmärkte"),
    REAL_ESTATE("Immobilienpreise"),
    METALS("Edelmetalle")
}

enum class MarketInstrument(val symbol: String) {
    DAX("^dax"),
    SPX("^spx"),
    FTSE("^ftse"),
    US_REAL_ESTATE("vnq.us"),
    EURO_REAL_ESTATE("iqq7.de"),
    XAU("xauusd"),
    XAG("xagusd")
}

data class ComparisonPoint(val year: Int, val value: Double)

data class ComparisonAssetSeries(
    val asset: ComparisonAsset,
    val history: List<ComparisonPoint>,
    val projection: List<ComparisonPoint>
)

enum class ComparisonAsset(
    val displayName: String,
    val icon: String,
    val group: AssetGroup,
    val marketInstrument: MarketInstrument?
) {
    EQUITY_DE("Deutschland Aktien", "chart", AssetGroup.EQUITIES, MarketInstrument.DAX),
    EQUITY_USA("USA Aktien", "chart", AssetGroup.EQUITIES, MarketInstrument.SPX),
    EQUITY_LON("London Aktien", "chart", AssetGroup.EQUITIES, MarketInstrument.FTSE),
    REAL_ESTATE_DE("Deutschland Immobilien", "home", AssetGroup.REAL_ESTATE, MarketInstrument.EURO_REAL_ESTATE),
    REAL_ESTATE_ES("Spanien Immobilien", "home", AssetGroup.REAL_ESTATE, MarketInstrument.EURO_REAL_ESTATE),
    REAL_ESTATE_FR("Frankreich Immobilien", "home", AssetGroup.REAL_ESTATE, MarketInstrument.EURO_REAL_ESTATE),
    REAL_ESTATE_LON("London Immobilien", "home", AssetGroup.REAL_ESTATE, MarketInstrument.US_REAL_ESTATE),
    GOLD("Gold", "star", AssetGroup.METALS, MarketInstrument.XAU),
    SILVER("Silber", "sparkles", AssetGroup.METALS, MarketInstrument.XAG);

    fun multiplier(phase: BennerPhase): Double {
        return when (group) {
            AssetGroup.EQUITIES -> when (phase) {
                BennerPhase.GOOD_TIMES -> 0.05
                BennerPhase.HARD_TIMES -> -0.02
                BennerPhase.PANIC -> -0.08
            }
            AssetGroup.REAL_ESTATE -> when (phase) {
                BennerPhase.GOOD_TIMES -> 0.03
                BennerPhase.HARD_TIMES -> -0.015
                BennerPhase.PANIC -> -0.06
            }
            AssetGroup.METALS -> when (phase) {
                BennerPhase.GOOD_TIMES -> 0.015
                BennerPhase.HARD_TIMES -> 0.03
                BennerPhase.PANIC -> 0.08
            }
        }
    }
}
