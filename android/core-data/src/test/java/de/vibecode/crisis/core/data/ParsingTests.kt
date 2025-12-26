package de.vibecode.crisis.core.data

import de.vibecode.crisis.core.domain.MarketInstrument
import kotlinx.datetime.Instant
import kotlinx.serialization.json.Json
import okhttp3.OkHttpClient
import org.junit.Assert.assertEquals
import org.junit.Assert.assertNotNull
import org.junit.Test

class ParsingTests {
    @Test
    fun `world bank series parsing extracts numeric points`() {
        val json = Json { ignoreUnknownKeys = true }
        val service = MacroIndicatorService(OkHttpClient(), json)
        val body = """
            [
              {"page":1},
              [
                {"date":"2023","value":2.5},
                {"date":"2022","value":1.0},
                {"date":"2021","value":null}
              ]
            ]
        """.trimIndent()

        val points = service.parseSeries(body)
        assertEquals(2, points.size)
        assertEquals(2022, points.last().year)
        assertEquals(1.0, points.last().value, 0.0001)
    }

    @Test
    fun `stooq csv parsing filters invalid rows and trims to recent years`() {
        val csv = """
            Date,Open,High,Low,Close,Volume
            2024-01-02,1,2,0.5,10,100
            2023-01-02,1,2,0.5,8,100
            bad,line
            2022-01-02,1,2,0.5,6,100
        """.trimIndent()

        val service = MarketDataService(OkHttpClient(), cache = null)
        val points = service.parseHistory(csv, limitYears = 1)
        assertEquals(2, points.size)
        assertEquals(2023, points.first().year)
        assertEquals(2024, points.last().year)
    }

    @Test
    fun `ecb xml parsing extracts date and usd rate`() {
        val xml = """
            <gesmes:Envelope xmlns:gesmes="http://www.gesmes.org/xml/2002-08-01">
              <Cube>
                <Cube time="2024-04-10">
                  <Cube currency="USD" rate="1.1"/>
                </Cube>
              </Cube>
            </gesmes:Envelope>
        """.trimIndent()

        val parser = EcbRateParser()
        parser.parse(xml)
        assertEquals(1.1, parser.rates["USD"] ?: 0.0, 0.0001)
        assertNotNull(parser.date)
        assertEquals(Instant.parse("2024-04-10T00:00:00Z"), parser.date)
    }
}
