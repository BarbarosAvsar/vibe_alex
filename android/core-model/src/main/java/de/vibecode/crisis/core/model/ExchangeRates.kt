package de.vibecode.crisis.core.model

import kotlinx.datetime.Instant
import kotlinx.serialization.Serializable

@Serializable
data class ExchangeRates(
    val base: DisplayCurrency,
    val timestamp: Instant,
    val values: Map<DisplayCurrency, Double>
) {
    fun multiplier(from: DisplayCurrency, to: DisplayCurrency): Double? {
        if (from == to) return 1.0
        if (from == base) return values[to]
        if (to == base) {
            val rate = values[from] ?: return null
            return 1.0 / rate
        }
        val sourceRate = values[from] ?: return null
        val targetRate = values[to] ?: return null
        return targetRate / sourceRate
    }
}

class CurrencyConverter(private val rates: ExchangeRates?) {
    fun convert(amount: Double, fromCode: String, to: DisplayCurrency): Double {
        val source = DisplayCurrency.fromCode(fromCode) ?: return amount
        return convert(amount, source, to)
    }

    fun convert(amount: Double, from: DisplayCurrency, to: DisplayCurrency): Double {
        val multiplier = rates?.multiplier(from, to) ?: return amount
        return amount * multiplier
    }
}
