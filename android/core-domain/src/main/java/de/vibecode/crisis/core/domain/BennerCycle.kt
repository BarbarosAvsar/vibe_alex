package de.vibecode.crisis.core.domain

enum class BennerPhase(val title: String, val subtitle: String, val guidance: String) {
    PANIC(
        "Panikjahr",
        "Extremer Verkaufsdruck - Phase A",
        "Historisch folgten auf diese Jahre heftige Markteinbrüche. Liquidität sichern und Risiko begrenzen."
    ),
    GOOD_TIMES(
        "Gute Zeiten",
        "Hohe Preise - Phase B (Verkäufe bevorzugt)",
        "Überdurchschnittliche Bewertungen. Gewinne sichern und Exposure reduzieren."
    ),
    HARD_TIMES(
        "Schwere Zeiten",
        "Niedrige Preise - Phase C (Akkumulation)",
        "Marktpreise gelten als günstig. Positionsaufbau und Sparpläne bieten sich an."
    );
}

data class BennerCycleEntry(
    val year: Int,
    val phase: BennerPhase,
    val orderInPhase: Int,
    val phaseLength: Int
) {
    val progress: Double
        get() = if (phaseLength <= 0) 1.0 else orderInPhase.toDouble() / phaseLength.toDouble()

    val summary: String
        get() = "$year - ${phase.subtitle}"
}

class BennerCycleService(
    private val initialPanicYear: Int = 1700,
    private val intervals: List<Int> = listOf(18, 20, 16),
    private val range: IntRange = 1780..2150,
    private val goodSpan: Int = 7,
    private val hardSpan: Int = 11
) {
    fun makeEntries(): List<BennerCycleEntry> {
        val panicYears = makePanicYears(range.last + hardSpan + (intervals.maxOrNull() ?: 20))
        val entries = mutableListOf<BennerCycleEntry>()

        for (index in 0 until panicYears.size - 1) {
            val panicYear = panicYears[index]
            val nextPanic = panicYears[index + 1]
            if (panicYear > range.last) break

            if (panicYear in range) {
                entries.add(BennerCycleEntry(panicYear, BennerPhase.PANIC, 1, 1))
            }

            val availableYears = (minOf(nextPanic, range.last + 1) - panicYear - 1).coerceAtLeast(0)
            val cycleGoodYears = minOf(goodSpan, availableYears)
            val cycleHardYears = (availableYears - cycleGoodYears).coerceAtLeast(0)

            if (cycleGoodYears > 0) {
                for (offset in 1..cycleGoodYears) {
                    val year = panicYear + offset
                    if (year in range) {
                        entries.add(BennerCycleEntry(year, BennerPhase.GOOD_TIMES, offset, cycleGoodYears))
                    }
                }
            }

            if (cycleHardYears > 0) {
                for (i in 0 until cycleHardYears) {
                    val year = panicYear + cycleGoodYears + 1 + i
                    if (year in range) {
                        entries.add(BennerCycleEntry(year, BennerPhase.HARD_TIMES, i + 1, cycleHardYears))
                    }
                }
            }
        }

        return entries.sortedBy { it.year }
    }

    private fun makePanicYears(limit: Int): List<Int> {
        val years = mutableListOf(initialPanicYear)
        var index = 0
        while ((years.lastOrNull() ?: 0) < limit) {
            val increment = intervals[index % intervals.size]
            years.add((years.lastOrNull() ?: initialPanicYear) + increment)
            index += 1
        }
        return years
    }
}

val BennerPhase.metalTrendMultiplier: Double
    get() = when (this) {
        BennerPhase.PANIC -> 0.08
        BennerPhase.GOOD_TIMES -> 0.02
        BennerPhase.HARD_TIMES -> 0.03
    }

class ComparisonMultipliers(private val phase: BennerPhase) {
    fun forEquities(): Double = when (phase) {
        BennerPhase.GOOD_TIMES -> 0.05
        BennerPhase.HARD_TIMES -> -0.02
        BennerPhase.PANIC -> -0.08
    }

    fun forRealEstate(): Double = when (phase) {
        BennerPhase.GOOD_TIMES -> 0.03
        BennerPhase.HARD_TIMES -> -0.015
        BennerPhase.PANIC -> -0.06
    }

    fun forMetals(): Double = when (phase) {
        BennerPhase.GOOD_TIMES -> 0.015
        BennerPhase.HARD_TIMES -> 0.03
        BennerPhase.PANIC -> 0.08
    }
}
