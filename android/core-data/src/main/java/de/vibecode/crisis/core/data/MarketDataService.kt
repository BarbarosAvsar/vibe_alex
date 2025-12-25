package de.vibecode.crisis.core.data

import de.vibecode.crisis.core.domain.ComparisonPoint
import de.vibecode.crisis.core.domain.MarketInstrument
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import kotlinx.datetime.LocalDate
import okhttp3.OkHttpClient
import okhttp3.Request

class MarketDataService(private val client: OkHttpClient) {
    suspend fun fetchHistory(instrument: MarketInstrument, limitYears: Int = 10): List<ComparisonPoint> {
        val url = "https://stooq.pl/q/d/l/?s=${instrument.symbol}&i=d"
        val body = getBody(url)
        if (body.isBlank()) return emptyList()
        val lines = body.lineSequence().drop(1)
        val points = lines.mapNotNull { line ->
            val parts = line.split(",")
            if (parts.size < 5) return@mapNotNull null
            val date = runCatching { LocalDate.parse(parts[0]) }.getOrNull() ?: return@mapNotNull null
            val close = parts[4].toDoubleOrNull() ?: return@mapNotNull null
            ComparisonPoint(date.year, close)
        }.toList().sortedBy { it.year }

        if (limitYears <= 0) return points
        val maxYear = points.maxOfOrNull { it.year } ?: return points
        val threshold = maxYear - limitYears
        return points.filter { it.year >= threshold }
    }

    private suspend fun getBody(url: String): String = withContext(Dispatchers.IO) {
        val request = Request.Builder().url(url).build()
        client.newCall(request).execute().use { response ->
            response.body?.string().orEmpty()
        }
    }
}
