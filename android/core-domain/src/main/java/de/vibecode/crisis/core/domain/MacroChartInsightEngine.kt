package de.vibecode.crisis.core.domain

import de.vibecode.crisis.core.model.MacroSeries

class MacroChartInsightEngine {
    fun makeAnnotation(series: List<MacroSeries>): MacroChartAnnotation? {
        val candidates = series.mapNotNull { annotationFor(it) }
        return candidates.maxByOrNull { kotlin.math.abs(it.delta) }
    }

    private fun annotationFor(series: MacroSeries): MacroChartAnnotation? {
        val latest = series.points.lastOrNull() ?: return null
        val previous = series.points.dropLast(1).lastOrNull() ?: return null
        val delta = latest.value - previous.value
        val direction = if (delta >= 0) "gestiegen" else "gefallen"
        val message = "${series.kind.title} ist $direction um ${"%.1f".format(delta)}${series.kind.unit} seit ${previous.year}."
        return MacroChartAnnotation(series.kind, latest.year, delta, message)
    }
}

data class MacroChartAnnotation(
    val indicator: de.vibecode.crisis.core.model.MacroIndicatorKind,
    val focusYear: Int,
    val delta: Double,
    val message: String
) {
    val symbol: String
        get() = if (delta >= 0) "arrow.up" else "arrow.down"
}
