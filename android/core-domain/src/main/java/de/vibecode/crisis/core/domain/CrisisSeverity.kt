package de.vibecode.crisis.core.domain

import kotlinx.datetime.Clock
import kotlinx.datetime.Instant
import kotlin.math.abs

object CrisisSeverity {
    fun newsSeverityScore(publishedAt: Instant, now: Instant = Clock.System.now()): Double {
        val hours = (now - publishedAt).inWholeHours
        return when {
            hours < 24 -> 6.0
            hours < 72 -> 5.0
            else -> 4.0
        }
    }

    fun governanceSeverity(value: Double): Double = abs(value) * 2

    fun recessionSeverity(value: Double): Double = abs(value)
}
