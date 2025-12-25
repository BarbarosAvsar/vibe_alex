package de.vibecode.crisis.core.model

import kotlinx.serialization.Serializable

@Serializable
data class MacroIndicator(
    val id: MacroIndicatorKind,
    val title: String,
    val latestValue: Double?,
    val previousValue: Double?,
    val unit: String,
    val description: String,
    val source: DataSource
)

@Serializable
enum class MacroIndicatorKind(val indicatorCode: String, val unit: String, val explanation: String, val title: String) {
    INFLATION("FP.CPI.TOTL.ZG", "%", "Jährliche Verbraucherpreisinflation laut Weltbank", "Inflation"),
    GROWTH("NY.GDP.MKTP.KD.ZG", "%", "Reales BIP-Wachstum", "Wachstum"),
    DEFENSE("MS.MIL.XPND.GD.ZS", "% BIP", "Militärausgaben im Verhältnis zum BIP", "Verteidigung")
}

@Serializable
data class MacroDataPoint(
    val year: Int,
    val value: Double
)

@Serializable
data class MacroSeries(
    val kind: MacroIndicatorKind,
    val points: List<MacroDataPoint>
)

@Serializable
data class MacroOverview(
    val indicators: List<MacroIndicator>
)
