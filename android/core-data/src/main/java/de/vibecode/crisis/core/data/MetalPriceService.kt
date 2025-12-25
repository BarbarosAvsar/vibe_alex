package de.vibecode.crisis.core.data

import de.vibecode.crisis.core.model.DataSource
import de.vibecode.crisis.core.model.MetalAsset
import de.vibecode.crisis.core.model.MetalInsight
import de.vibecode.crisis.core.network.GoldPriceApi
import kotlinx.datetime.Instant
import java.util.UUID

class MetalPriceService(private val api: GoldPriceApi) {
    suspend fun fetchAssets(): List<MetalAsset> {
        val payload = api.fetchRates()
        val item = payload.items.firstOrNull() ?: return emptyList()
        val timestamp = Instant.fromEpochMilliseconds((payload.ts).toLong())

        val gold = MetalAsset(
            id = "XAU",
            name = "Gold",
            symbol = "XAU",
            price = item.xauPrice,
            dailyChangePercentage = item.pcXau,
            currency = item.curr,
            lastUpdated = timestamp,
            insights = listOf(
                MetalInsight(UUID.randomUUID().toString(), "arrow", "24h", percentString(item.pcXau)),
                MetalInsight(UUID.randomUUID().toString(), "swap", "Veränderung", "%.2f".format(item.chgXau))
            ),
            dataSource = DataSource.GOLD_PRICE
        )

        val silver = MetalAsset(
            id = "XAG",
            name = "Silber",
            symbol = "XAG",
            price = item.xagPrice,
            dailyChangePercentage = item.pcXag,
            currency = item.curr,
            lastUpdated = timestamp,
            insights = listOf(
                MetalInsight(UUID.randomUUID().toString(), "arrow", "24h", percentString(item.pcXag)),
                MetalInsight(UUID.randomUUID().toString(), "swap", "Veränderung", "%.2f".format(item.chgXag))
            ),
            dataSource = DataSource.GOLD_PRICE
        )

        return listOf(gold, silver)
    }

    private fun percentString(value: Double): String = "%.2f%%".format(value)
}
