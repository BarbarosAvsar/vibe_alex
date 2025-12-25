package de.vibecode.crisis.core.data

import de.vibecode.crisis.core.model.DataSource
import de.vibecode.crisis.core.model.MacroDataPoint
import de.vibecode.crisis.core.model.MacroIndicator
import de.vibecode.crisis.core.model.MacroIndicatorKind
import de.vibecode.crisis.core.model.MacroSeries
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import kotlinx.serialization.json.Json
import kotlinx.serialization.json.doubleOrNull
import kotlinx.serialization.json.jsonArray
import kotlinx.serialization.json.jsonObject
import kotlinx.serialization.json.jsonPrimitive
import okhttp3.OkHttpClient
import okhttp3.Request

class MacroIndicatorService(
    private val client: OkHttpClient,
    private val json: Json
) {
    suspend fun fetchIndicator(kind: MacroIndicatorKind, limit: Int = 8): Pair<MacroIndicator, MacroSeries> {
        val url = "https://api.worldbank.org/v2/country/${AppConfig.FOCUS_COUNTRY_ISO}/indicator/${kind.indicatorCode}?format=json&per_page=$limit"
        val body = getBody(url)
        val points = parseSeries(body)
        val sorted = points.sortedBy { it.year }
        val latest = sorted.lastOrNull()
        val previous = sorted.dropLast(1).lastOrNull()

        val indicator = MacroIndicator(
            id = kind,
            title = kind.title,
            latestValue = latest?.value,
            previousValue = previous?.value,
            unit = kind.unit,
            description = kind.explanation,
            source = DataSource.WORLD_BANK
        )

        return indicator to MacroSeries(kind, sorted)
    }

    private suspend fun getBody(url: String): String = withContext(Dispatchers.IO) {
        val request = Request.Builder().url(url).build()
        client.newCall(request).execute().use { response ->
            response.body?.string().orEmpty()
        }
    }

    private fun parseSeries(body: String): List<MacroDataPoint> {
        if (body.isBlank()) return emptyList()
        val root = json.parseToJsonElement(body).jsonArray
        val entries = root.getOrNull(1)?.jsonArray ?: return emptyList()
        return entries.mapNotNull { entry ->
            val obj = entry.jsonObject
            val year = obj["date"]?.jsonPrimitive?.content?.toIntOrNull() ?: return@mapNotNull null
            val value = obj["value"]?.jsonPrimitive?.doubleOrNull ?: return@mapNotNull null
            MacroDataPoint(year = year, value = value)
        }
    }
}
