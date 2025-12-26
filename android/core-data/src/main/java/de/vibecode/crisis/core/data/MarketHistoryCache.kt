package de.vibecode.crisis.core.data

import android.content.Context
import de.vibecode.crisis.core.domain.ComparisonPoint
import de.vibecode.crisis.core.domain.MarketInstrument
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import kotlinx.serialization.Serializable
import kotlinx.serialization.json.Json
import java.io.File

class MarketHistoryCache(
    context: Context,
    private val json: Json
) {
    private val cacheDir = File(context.cacheDir, "market-history").apply { mkdirs() }

    suspend fun loadHistory(instrument: MarketInstrument): List<ComparisonPoint>? {
        return withContext(Dispatchers.IO) {
            val file = File(cacheDir, fileName(instrument))
            if (!file.exists()) return@withContext null
            runCatching {
                val snapshot = json.decodeFromString(MarketHistorySnapshot.serializer(), file.readText())
                snapshot.points.map { ComparisonPoint(it.year, it.value) }
            }.getOrNull()
        }
    }

    suspend fun persistHistory(instrument: MarketInstrument, points: List<ComparisonPoint>) {
        withContext(Dispatchers.IO) {
            val file = File(cacheDir, fileName(instrument))
            runCatching {
                val snapshot = MarketHistorySnapshot(points.map { MarketHistoryEntry(it.year, it.value) })
                file.writeText(json.encodeToString(MarketHistorySnapshot.serializer(), snapshot))
            }
        }
    }

    private fun fileName(instrument: MarketInstrument): String = "${instrument.symbol}.json"
}

@Serializable
private data class MarketHistorySnapshot(
    val points: List<MarketHistoryEntry>
)

@Serializable
private data class MarketHistoryEntry(
    val year: Int,
    val value: Double
)
