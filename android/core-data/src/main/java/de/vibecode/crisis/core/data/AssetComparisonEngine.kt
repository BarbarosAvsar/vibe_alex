package de.vibecode.crisis.core.data

import de.vibecode.crisis.core.domain.BennerCycleEntry
import de.vibecode.crisis.core.domain.ComparisonAsset
import de.vibecode.crisis.core.domain.ComparisonAssetSeries
import de.vibecode.crisis.core.domain.ComparisonPoint

class AssetComparisonEngine(private val marketService: MarketDataService) {
    suspend fun loadAssets(forecasts: List<BennerCycleEntry>): List<ComparisonAssetSeries> {
        val series = mutableListOf<ComparisonAssetSeries>()
        for (asset in ComparisonAsset.entries) {
            val history = makeHistory(asset)
            val projection = makeProjection(asset, forecasts, history)
            series.add(ComparisonAssetSeries(asset, history, projection))
        }
        return series
    }

    private suspend fun makeHistory(asset: ComparisonAsset): List<ComparisonPoint> {
        val instrument = asset.marketInstrument ?: return emptyList()
        return try {
            marketService.fetchHistory(instrument, limitYears = 10)
        } catch (error: Exception) {
            emptyList()
        }
    }

    private fun makeProjection(
        asset: ComparisonAsset,
        forecasts: List<BennerCycleEntry>,
        history: List<ComparisonPoint>
    ): List<ComparisonPoint> {
        val last = history.lastOrNull() ?: return emptyList()
        var value = last.value
        return forecasts.filter { it.year >= last.year }.map { entry ->
            value += value * asset.multiplier(entry.phase)
            ComparisonPoint(entry.year, value)
        }
    }
}
