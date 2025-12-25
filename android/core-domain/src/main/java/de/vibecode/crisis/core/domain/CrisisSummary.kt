package de.vibecode.crisis.core.domain

import de.vibecode.crisis.core.model.CrisisCategory
import de.vibecode.crisis.core.model.CrisisEvent
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale

object CrisisThresholds {
    const val HIGH_RISK_SEVERITY_SCORE = 5.0
    const val POLITICAL_INSTABILITY_CUTOFF = -0.5
    const val RECESSION_GROWTH_CUTOFF = 0.0
}

data class CrisisSummary(
    val headline: String,
    val highlights: List<String>
)

class CrisisSummaryGenerator {
    fun summarize(events: List<CrisisEvent>): CrisisSummary? {
        if (events.isEmpty()) return null

        val severeEvents = events.filter { it.severityScore >= CrisisThresholds.HIGH_RISK_SEVERITY_SCORE }
        val headline = if (severeEvents.isEmpty()) {
            "Keine Hochrisiko-Ereignisse erkennbar"
        } else {
            "${severeEvents.size} Hochrisiko-Ereignis(se) aktiv"
        }

        val dominantRegion = events.groupBy { it.region }
            .map { it.key to it.value.size }
            .sortedByDescending { it.second }
            .firstOrNull()

        val dominantCategory = events.groupBy { it.category }
            .map { it.key to it.value.size }
            .sortedByDescending { it.second }
            .firstOrNull()

        val highlights = mutableListOf<String>()
        if (dominantRegion != null) {
            highlights.add("${dominantRegion.second}x Ereignisse in ${dominantRegion.first}")
        }
        if (dominantCategory != null) {
            val label = when (dominantCategory.first) {
                CrisisCategory.GEOPOLITICAL -> "Geopolitik"
                CrisisCategory.FINANCIAL -> "Finanzen"
            }
            highlights.add("${dominantCategory.second}x Kategorie $label")
        }
        events.maxByOrNull { it.occurredAt }?.let { latest ->
            val formatter = SimpleDateFormat("dd.MM.yy HH:mm", Locale.getDefault())
            val formatted = formatter.format(Date(latest.occurredAt.toEpochMilliseconds()))
            highlights.add("Zuletzt ${latest.title} um $formatted")
        }

        return CrisisSummary(headline, highlights)
    }
}
