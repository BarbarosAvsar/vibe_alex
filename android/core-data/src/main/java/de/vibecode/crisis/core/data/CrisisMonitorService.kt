package de.vibecode.crisis.core.data

import de.vibecode.crisis.core.domain.CrisisThresholds
import de.vibecode.crisis.core.model.CrisisCategory
import de.vibecode.crisis.core.model.CrisisEvent
import de.vibecode.crisis.core.model.DataSource
import de.vibecode.crisis.core.network.NewsApi
import kotlinx.coroutines.async
import kotlinx.coroutines.coroutineScope
import kotlinx.datetime.Clock
import kotlinx.datetime.Instant
import kotlinx.datetime.LocalDate
import kotlinx.datetime.TimeZone
import kotlinx.datetime.toInstant
import kotlinx.serialization.json.Json
import kotlinx.serialization.json.doubleOrNull
import kotlinx.serialization.json.jsonArray
import kotlinx.serialization.json.jsonObject
import kotlinx.serialization.json.jsonPrimitive
import okhttp3.OkHttpClient
import okhttp3.Request
import kotlin.math.abs

interface CrisisFeedService {
    suspend fun fetchEvents(): List<CrisisEvent>
}

class CrisisMonitorService(private val feeds: List<CrisisFeedService>) {
    suspend fun fetchEvents(limit: Int = 12): List<CrisisEvent> = coroutineScope {
        val results = feeds.map { feed ->
            async { feed.fetchEvents() }
        }.flatMap { it.await() }

        results.sortedByDescending { it.occurredAt }.take(limit)
    }
}

class PoliticalFinancialNewsFeed(
    private val api: NewsApi,
    private val apiKey: String?
) : CrisisFeedService {
    override suspend fun fetchEvents(): List<CrisisEvent> {
        if (apiKey.isNullOrBlank()) return emptyList()

        val financial = api.topHeadlines(category = "business", apiKey = apiKey)
        val political = api.everything(query = AppConfig.NEWS_QUERY, apiKey = apiKey)

        val merged = financial.articles.mapNotNull { article ->
            mapArticle(article, CrisisCategory.FINANCIAL)
        } + political.articles.mapNotNull { article ->
            mapArticle(article, CrisisCategory.GEOPOLITICAL)
        }

        val unique = LinkedHashMap<String, CrisisEvent>()
        merged.forEach { event ->
            if (!unique.containsKey(event.id)) {
                unique[event.id] = event
            }
        }

        return unique.values.take(10)
    }

    private fun mapArticle(article: de.vibecode.crisis.core.network.NewsApiArticle, category: CrisisCategory): CrisisEvent? {
        val title = article.title ?: return null
        val publishedAt = article.publishedAt?.let { runCatching { Instant.parse(it) }.getOrNull() } ?: Clock.System.now()
        val identifier = "$category-${title.hashCode()}"
        return CrisisEvent(
            id = "news-$identifier",
            title = title,
            summary = article.description ?: article.content,
            region = article.source.name ?: "Weltweit",
            occurredAt = publishedAt,
            publishedAt = publishedAt,
            detailUrl = article.url,
            sourceName = article.source.name,
            source = DataSource.NEWS_API,
            category = category,
            severityScore = newsSeverityScore(publishedAt)
        )
    }

    private fun newsSeverityScore(publishedAt: Instant): Double {
        val hours = (Clock.System.now() - publishedAt).inWholeHours
        return when {
            hours < 24 -> 6.0
            hours < 72 -> 5.0
            else -> 4.0
        }
    }
}

class GeopoliticalAlertCrisisFeed(
    private val client: OkHttpClient,
    private val json: Json,
    private val watchList: List<Pair<String, String>> = listOf(
        "Ukraine" to "UKR",
        "Israel" to "ISR",
        "Taiwan" to "TWN",
        "South Africa" to "ZAF",
        "Germany" to "DEU"
    )
) : CrisisFeedService {
    override suspend fun fetchEvents(): List<CrisisEvent> = coroutineScope {
        watchList.map { entry ->
            async { fetchGovernanceAlert(entry) }
        }.mapNotNull { it.await() }
    }

    private suspend fun fetchGovernanceAlert(entry: Pair<String, String>): CrisisEvent? {
        val (name, code) = entry
        val url = "https://api.worldbank.org/v2/country/$code/indicator/PV.PSR.PIND?format=json&per_page=2"
        val latest = fetchWorldBankValue(url) ?: return null
        val value = latest.value
        if (value >= CrisisThresholds.POLITICAL_INSTABILITY_CUTOFF) return null

        val yearDate = yearInstant(latest.year)
        return CrisisEvent(
            id = "geo-$code",
            title = "Politische Instabilität $name",
            summary = "Governance-Index ${"%.2f".format(value)}",
            region = name,
            occurredAt = yearDate,
            publishedAt = yearDate,
            detailUrl = "https://data.worldbank.org/indicator/PV.PSR.PIND",
            sourceName = "World Bank",
            source = DataSource.WORLD_BANK_GOVERNANCE,
            category = CrisisCategory.GEOPOLITICAL,
            severityScore = abs(value) * 2
        )
    }

    private suspend fun fetchWorldBankValue(url: String): WorldBankValue? {
        val body = getBody(url)
        if (body.isBlank()) return null
        val root = json.parseToJsonElement(body).jsonArray
        val entries = root.getOrNull(1)?.jsonArray ?: return null
        val latest = entries.firstOrNull { it.jsonObject["value"]?.jsonPrimitive?.doubleOrNull != null } ?: return null
        val year = latest.jsonObject["date"]?.jsonPrimitive?.content?.toIntOrNull() ?: return null
        val value = latest.jsonObject["value"]?.jsonPrimitive?.doubleOrNull ?: return null
        return WorldBankValue(year, value)
    }

    private suspend fun getBody(url: String): String = kotlinx.coroutines.withContext(kotlinx.coroutines.Dispatchers.IO) {
        val request = Request.Builder().url(url).build()
        client.newCall(request).execute().use { response ->
            response.body?.string().orEmpty()
        }
    }
}

class FinancialStressCrisisFeed(
    private val client: OkHttpClient,
    private val json: Json,
    private val watchList: List<Pair<String, String>> = listOf(
        "Germany" to "DEU",
        "United States" to "USA",
        "United Kingdom" to "GBR",
        "Japan" to "JPN",
        "China" to "CHN"
    )
) : CrisisFeedService {
    override suspend fun fetchEvents(): List<CrisisEvent> = coroutineScope {
        watchList.map { entry ->
            async { fetchAlert(entry) }
        }.mapNotNull { it.await() }
    }

    private suspend fun fetchAlert(entry: Pair<String, String>): CrisisEvent? {
        val (name, code) = entry
        val url = "https://api.worldbank.org/v2/country/$code/indicator/NY.GDP.MKTP.KD.ZG?format=json&per_page=2"
        val latest = fetchWorldBankValue(url) ?: return null
        val value = latest.value
        if (value >= CrisisThresholds.RECESSION_GROWTH_CUTOFF) return null

        val yearDate = yearInstant(latest.year)
        return CrisisEvent(
            id = "finance-$code",
            title = "Rezession $name",
            summary = "Reales BIP-Wachstum ${"%.1f".format(value)}%",
            region = name,
            occurredAt = yearDate,
            publishedAt = yearDate,
            detailUrl = "https://data.worldbank.org/indicator/NY.GDP.MKTP.KD.ZG",
            sourceName = "World Bank",
            source = DataSource.WORLD_BANK_FINANCE,
            category = CrisisCategory.FINANCIAL,
            severityScore = abs(value)
        )
    }

    private suspend fun fetchWorldBankValue(url: String): WorldBankValue? {
        val body = getBody(url)
        if (body.isBlank()) return null
        val root = json.parseToJsonElement(body).jsonArray
        val entries = root.getOrNull(1)?.jsonArray ?: return null
        val latest = entries.firstOrNull { it.jsonObject["value"]?.jsonPrimitive?.doubleOrNull != null } ?: return null
        val year = latest.jsonObject["date"]?.jsonPrimitive?.content?.toIntOrNull() ?: return null
        val value = latest.jsonObject["value"]?.jsonPrimitive?.doubleOrNull ?: return null
        return WorldBankValue(year, value)
    }

    private suspend fun getBody(url: String): String = kotlinx.coroutines.withContext(kotlinx.coroutines.Dispatchers.IO) {
        val request = Request.Builder().url(url).build()
        client.newCall(request).execute().use { response ->
            response.body?.string().orEmpty()
        }
    }
}

private data class WorldBankValue(val year: Int, val value: Double)

private fun yearInstant(year: Int): Instant {
    val date = LocalDate(year, 1, 1)
    return date.toInstant(TimeZone.UTC)
}
