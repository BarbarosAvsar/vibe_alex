package de.vibecode.crisis.core.domain

import org.junit.Assert.assertEquals
import org.junit.Test

class ComparisonMultipliersTest {
    @Test
    fun `comparison multipliers match spec`() {
        val panic = ComparisonMultipliers(BennerPhase.PANIC)
        assertEquals(-0.08, panic.forEquities(), 0.0001)
        assertEquals(-0.06, panic.forRealEstate(), 0.0001)
        assertEquals(0.08, panic.forMetals(), 0.0001)

        val good = ComparisonMultipliers(BennerPhase.GOOD_TIMES)
        assertEquals(0.05, good.forEquities(), 0.0001)
        assertEquals(0.03, good.forRealEstate(), 0.0001)
        assertEquals(0.015, good.forMetals(), 0.0001)

        val hard = ComparisonMultipliers(BennerPhase.HARD_TIMES)
        assertEquals(-0.02, hard.forEquities(), 0.0001)
        assertEquals(-0.015, hard.forRealEstate(), 0.0001)
        assertEquals(0.03, hard.forMetals(), 0.0001)
    }

    @Test
    fun `asset group multipliers align with phase`() {
        assertEquals(0.08, ComparisonAsset.GOLD.multiplier(BennerPhase.PANIC), 0.0001)
        assertEquals(-0.08, ComparisonAsset.EQUITY_DE.multiplier(BennerPhase.PANIC), 0.0001)
        assertEquals(-0.015, ComparisonAsset.REAL_ESTATE_DE.multiplier(BennerPhase.HARD_TIMES), 0.0001)
    }
}
