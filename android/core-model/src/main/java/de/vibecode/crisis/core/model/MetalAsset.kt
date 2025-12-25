package de.vibecode.crisis.core.model

import kotlinx.datetime.Instant
import kotlinx.serialization.Serializable

@Serializable
data class MetalAsset(
    val id: String,
    val name: String,
    val symbol: String,
    val price: Double,
    val dailyChangePercentage: Double,
    val currency: String,
    val lastUpdated: Instant,
    val insights: List<MetalInsight>,
    val dataSource: DataSource
)

@Serializable
data class MetalInsight(
    val id: String,
    val icon: String,
    val label: String,
    val value: String
)
