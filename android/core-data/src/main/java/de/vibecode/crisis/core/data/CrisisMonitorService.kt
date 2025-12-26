package de.vibecode.crisis.core.data

import de.vibecode.crisis.core.domain.CrisisSeverity
import de.vibecode.crisis.core.model.CrisisCategory
import de.vibecode.crisis.core.model.CrisisEvent
import de.vibecode.crisis.core.model.CrisisSettings
import de.vibecode.crisis.core.model.CrisisWatchlists
import de.vibecode.crisis.core.model.DataSource
import de.vibecode.crisis.core.model.WatchlistCountry
import de.vibecode.crisis.core.network.NewsApi
import kotlinx.coroutines.async
import kotlinx.coroutines.coroutineScope
import kotlinx.datetime.Clock
import kotlinx.datetime.Instant
import kotlinx.datetime.LocalDate
import kotlinx.datetime.TimeZone
import kotlinx.datetime.atStartOfDayIn
import kotlinx.serialization.json.Json
import kotlinx.serialization.json.doubleOrNull
import kotlinx.serialization.json.jsonArray
import kotlinx.serialization.json.jsonObject
import kotlinx.serialization.json.jsonPrimitive
import okhttp3.OkHttpClient
import okhttp3.Request

interface CrisisFeedService {
    suspend fun fetchEvents(settings: CrisisSettings): List<CrisisEvent>
}

class CrisisMonitorService(private val feeds: List<CrisisFeedService>) {
    suspend fun fetchEvents(settings: CrisisSettings, limit: Int = 12): List<CrisisEvent> = coroutineScope {
        val results = feeds.map { feed ->
            async { feed.fetchEvents(settings) }
        }.flatMap { it.await() }

        results.sortedByDescending { it.occurredAt }.take(limit)
    }
}

class PoliticalFinancialNewsFeed(
    private val api: NewsApi,
    private val apiKey: String?,
    private val cache: NewsCache?
) : CrisisFeedService {
    override suspend fun fetchEvents(settings: CrisisSettings): List<CrisisEvent> {
        if (apiKey.isNullOrBlank()) {
            return cache?.load()?.events ?: emptyList()
        }

        return runCatching {
            val key = apiKey!!
            val financial = api.topHeadlines(category = "business", apiKey = key)
            val political = api.everything(query = AppConfig.NEWS_QUERY, apiKey = key)

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

            val events = unique.values.take(10)
            cache?.persist(events)
            events
        }.getOrElse {
            cache?.load()?.events ?: emptyList()
        }
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
            severityScore = CrisisSeverity.newsSeverityScore(publishedAt)
        )
    }
}

class GeopoliticalAlertCrisisFeed(
    private val client: OkHttpClient,
    private val json: Json
) : CrisisFeedService {
    override suspend fun fetchEvents(settings: CrisisSettings): List<CrisisEvent> = coroutineScope {
        val active = filteredWatchlist(CrisisWatchlists.geopolitical, settings.geopoliticalWatchlist)
        if (active.isEmpty()) return@coroutineScope emptyList()
        active.map { entry ->
            async { fetchGovernanceAlert(entry, settings) }
        }.mapNotNull { it.await() }
    }

    private suspend fun fetchGovernanceAlert(entry: WatchlistCountry, settings: CrisisSettings): CrisisEvent? {
        val name = entry.name
        val code = entry.code
        val url = "https://api.worldbank.org/v2/country/$code/indicator/PV.PSR.PIND?format=json&per_page=2"
        val latest = fetchWorldBankValue(url) ?: return null
        val value = latest.value
        if (value >= settings.thresholdProfile.governanceCutoff) return null

        val yearDate = yearInstant(latest.year)
        return CrisisEvent(
            id = "geo-$code",
            title = "Politische Instabilitaet $name",
            summary = "Governance-Index ${"%.2f".format(value)}",
            region = name,
            occurredAt = yearDate,
            publishedAt = yearDate,
            detailUrl = "https://data.worldbank.org/indicator/PV.PSR.PIND",
            sourceName = "World Bank",
            source = DataSource.WORLD_BANK_GOVERNANCE,
            category = CrisisCategory.GEOPOLITICAL,
            severityScore = CrisisSeverity.governanceSeverity(value)
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
    private val json: Json
) : CrisisFeedService {
    override suspend fun fetchEvents(settings: CrisisSettings): List<CrisisEvent> = coroutineScope {
        val active = filteredWatchlist(CrisisWatchlists.financial, settings.financialWatchlist)
        if (active.isEmpty()) return@coroutineScope emptyList()
        active.map { entry ->
            async { fetchAlert(entry, settings) }
        }.mapNotNull { it.await() }
    }

    private suspend fun fetchAlert(entry: WatchlistCountry, settings: CrisisSettings): CrisisEvent? {
        val name = entry.name
        val code = entry.code
        val url = "https://api.worldbank.org/v2/country/$code/indicator/NY.GDP.MKTP.KD.ZG?format=json&per_page=2"
        val latest = fetchWorldBankValue(url) ?: return null
        val value = latest.value
        if (value >= settings.thresholdProfile.recessionCutoff) return null

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
            severityScore = CrisisSeverity.recessionSeverity(value)
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

private fun filteredWatchlist(
    candidates: List<WatchlistCountry>,
    enabledCodes: Set<String>
): List<WatchlistCountry> {
    if (enabledCodes.isEmpty()) return emptyList()
    return candidates.filter { enabledCodes.contains(it.code) }
}

private fun yearInstant(year: Int): Instant {
    val date = LocalDate(year, 1, 1)
    return date.atStartOfDayIn(TimeZone.UTC)
}

