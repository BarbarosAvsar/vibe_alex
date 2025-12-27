package de.vibecode.crisis.core.data

import de.vibecode.crisis.core.model.DisplayCurrency
import de.vibecode.crisis.core.model.ExchangeRates
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import kotlinx.datetime.Instant
import kotlinx.datetime.LocalDate
import kotlinx.datetime.TimeZone
import kotlinx.datetime.atStartOfDayIn
import kotlinx.serialization.Serializable
import kotlinx.serialization.json.Json
import okhttp3.OkHttpClient
import okhttp3.Request

class ExchangeRateService(private val client: OkHttpClient) {
    suspend fun fetchRates(): ExchangeRates {
        val body = getBody("https://api.frankfurter.dev/v1/latest?base=EUR&symbols=USD")
        val response = Json { ignoreUnknownKeys = true }.decodeFromString(FrankfurterResponse.serializer(), body)
        val usdRate = response.rates["USD"] ?: error("Missing USD rate")
        val timestamp = response.date?.let {
            runCatching { LocalDate.parse(it).atStartOfDayIn(TimeZone.UTC) }.getOrNull()
        } ?: Instant.fromEpochMilliseconds(0)
        return ExchangeRates(base = DisplayCurrency.EUR, timestamp = timestamp, values = mapOf(DisplayCurrency.USD to usdRate))
    }

    private suspend fun getBody(url: String): String = withContext(Dispatchers.IO) {
        val request = Request.Builder().url(url).build()
        client.newCall(request).execute().use { response ->
            response.body?.string().orEmpty()
        }
    }
}

@Serializable
private data class FrankfurterResponse(
    val base: String? = null,
    val date: String? = null,
    val rates: Map<String, Double> = emptyMap()
)
