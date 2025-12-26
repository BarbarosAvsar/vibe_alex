package de.vibecode.crisis.core.domain

import org.junit.Assert.assertEquals
import org.junit.Assert.assertTrue
import org.junit.Test

class BennerCycleServiceTest {
    @Test
    fun `entries stay within configured range`() {
        val entries = BennerCycleService().makeEntries()
        assertTrue(entries.isNotEmpty())
        assertTrue(entries.all { it.year in 1780..2150 })
    }

    @Test
    fun `panic years include expected cycle`() {
        val entries = BennerCycleService().makeEntries()
        val panicYears = entries.filter { it.phase == BennerPhase.PANIC }.map { it.year }
        assertTrue(panicYears.contains(1792))
    }

    @Test
    fun `panic entries report full progress`() {
        val panic = BennerCycleEntry(1900, BennerPhase.PANIC, orderInPhase = 1, phaseLength = 1)
        assertEquals(1.0, panic.progress, 0.0001)
    }
}
