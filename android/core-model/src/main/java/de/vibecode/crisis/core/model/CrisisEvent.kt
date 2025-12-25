package de.vibecode.crisis.core.model

import kotlinx.datetime.Instant
import kotlinx.serialization.Serializable

@Serializable
enum class CrisisCategory {
    GEOPOLITICAL,
    FINANCIAL
}

@Serializable
data class CrisisEvent(
    val id: String,
    val title: String,
    val summary: String?,
    val region: String,
    val occurredAt: Instant,
    val publishedAt: Instant?,
    val detailUrl: String?,
    val sourceName: String?,
    val source: DataSource,
    val category: CrisisCategory,
    val severityScore: Double
)
