package de.vibecode.crisis.core.domain

import kotlinx.datetime.Instant
import org.junit.Assert.assertEquals
import org.junit.Test

class CrisisSeverityTest {
    @Test
    fun `news severity favors recent items`() {
        val now = Instant.parse("2024-04-10T12:00:00Z")
        val fresh = Instant.parse("2024-04-10T01:00:00Z")
        val mid = Instant.parse("2024-04-08T12:00:00Z")
        val old = Instant.parse("2024-04-01T12:00:00Z")

        assertEquals(6.0, CrisisSeverity.newsSeverityScore(fresh, now), 0.0001)
        assertEquals(5.0, CrisisSeverity.newsSeverityScore(mid, now), 0.0001)
        assertEquals(4.0, CrisisSeverity.newsSeverityScore(old, now), 0.0001)
    }

    @Test
    fun `governance and recession severity scale by absolute value`() {
        assertEquals(1.0, CrisisSeverity.governanceSeverity(-0.5), 0.0001)
        assertEquals(0.7, CrisisSeverity.recessionSeverity(-0.7), 0.0001)
    }
}
