package de.vibecode.crisis.core.model

import kotlinx.serialization.Serializable

@Serializable
data class DashboardSnapshot(
    val metals: List<MetalAsset>,
    val macroOverview: MacroOverview,
    val macroSeries: List<MacroSeries>,
    val crises: List<CrisisEvent>
)
