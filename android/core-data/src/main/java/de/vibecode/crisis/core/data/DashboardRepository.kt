package de.vibecode.crisis.core.data

import de.vibecode.crisis.core.model.DashboardSnapshot
import de.vibecode.crisis.core.model.MacroOverview
import kotlinx.coroutines.async
import kotlinx.coroutines.coroutineScope

class DashboardRepository(
    private val metalService: MetalPriceService,
    private val macroService: MacroIndicatorService,
    private val crisisService: CrisisMonitorService,
    private val preferences: UserPreferences
) {
    suspend fun makeSnapshot(): DashboardSnapshot = coroutineScope {
        val metalsTask = async { metalService.fetchAssets() }
        val inflationTask = async { macroService.fetchIndicator(de.vibecode.crisis.core.model.MacroIndicatorKind.INFLATION) }
        val growthTask = async { macroService.fetchIndicator(de.vibecode.crisis.core.model.MacroIndicatorKind.GROWTH) }
        val defenseTask = async { macroService.fetchIndicator(de.vibecode.crisis.core.model.MacroIndicatorKind.DEFENSE) }
        val crisisTask = async {
            val settings = preferences.getCrisisSettings()
            crisisService.fetchEvents(settings)
        }

        val metals = metalsTask.await()
        val (inflation, inflationSeries) = inflationTask.await()
        val (growth, growthSeries) = growthTask.await()
        val (defense, defenseSeries) = defenseTask.await()
        val crises = crisisTask.await()

        DashboardSnapshot(
            metals = metals,
            macroOverview = MacroOverview(listOf(inflation, growth, defense)),
            macroSeries = listOf(inflationSeries, growthSeries, defenseSeries),
            crises = crises
        )
    }
}
