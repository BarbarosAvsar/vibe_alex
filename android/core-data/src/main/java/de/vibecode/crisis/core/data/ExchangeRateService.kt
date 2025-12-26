package de.vibecode.crisis.core.data

import de.vibecode.crisis.core.model.DisplayCurrency
import de.vibecode.crisis.core.model.ExchangeRates
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import kotlinx.datetime.Instant
import kotlinx.datetime.LocalDate
import kotlinx.datetime.TimeZone
import kotlinx.datetime.atStartOfDayIn
import okhttp3.OkHttpClient
import okhttp3.Request
import org.xmlpull.v1.XmlPullParser
import org.xmlpull.v1.XmlPullParserFactory

class ExchangeRateService(private val client: OkHttpClient) {
    suspend fun fetchRates(): ExchangeRates {
        val body = getBody("https://www.ecb.europa.eu/stats/eurofxref/eurofxref-daily.xml")
        val parser = EcbRateParser()
        parser.parse(body)
        val usdRate = parser.rates["USD"] ?: error("Missing USD rate")
        val timestamp = parser.date ?: Instant.fromEpochMilliseconds(0)
        return ExchangeRates(base = DisplayCurrency.EUR, timestamp = timestamp, values = mapOf(DisplayCurrency.USD to usdRate))
    }

    private suspend fun getBody(url: String): String = withContext(Dispatchers.IO) {
        val request = Request.Builder().url(url).build()
        client.newCall(request).execute().use { response ->
            response.body?.string().orEmpty()
        }
    }
}

internal class EcbRateParser {
    val rates: MutableMap<String, Double> = mutableMapOf()
    var date: Instant? = null

    fun parse(xml: String) {
        if (xml.isBlank()) return
        val factory = XmlPullParserFactory.newInstance()
        factory.isNamespaceAware = true
        val parser = factory.newPullParser()
        parser.setInput(xml.reader())
        var event = parser.eventType
        while (event != XmlPullParser.END_DOCUMENT) {
            if (event == XmlPullParser.START_TAG && parser.name == "Cube") {
                val timeValue = parser.getAttributeValue(null, "time")
                if (timeValue != null) {
                    date = runCatching {
                        LocalDate.parse(timeValue).atStartOfDayIn(TimeZone.UTC)
                    }.getOrNull()
                }
                val currency = parser.getAttributeValue(null, "currency")
                val rate = parser.getAttributeValue(null, "rate")
                if (currency != null && rate != null) {
                    rates[currency] = rate.toDoubleOrNull() ?: 0.0
                }
            }
            event = parser.next()
        }
    }
}
