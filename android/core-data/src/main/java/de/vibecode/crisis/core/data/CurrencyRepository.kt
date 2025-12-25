package de.vibecode.crisis.core.data

import de.vibecode.crisis.core.model.CurrencyConverter
import de.vibecode.crisis.core.model.DisplayCurrency
import de.vibecode.crisis.core.model.ExchangeRates
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.datetime.Clock
import kotlin.time.Duration.Companion.hours

class CurrencyRepository(
    private val preferences: UserPreferences,
    private val exchangeRateService: ExchangeRateService
) {
    private val ratesState = MutableStateFlow<ExchangeRates?>(null)

    val ratesFlow: StateFlow<ExchangeRates?> = ratesState.asStateFlow()
    val selectedCurrencyFlow = preferences.selectedCurrencyFlow

    suspend fun setSelectedCurrency(currency: DisplayCurrency) {
        preferences.setSelectedCurrency(currency)
    }

    suspend fun refreshRatesIfStale() {
        val existing = ratesState.value
        val now = Clock.System.now()
        val needsRefresh = existing?.timestamp?.let { now - it > 12.hours } ?: true
        if (!needsRefresh) return

        try {
            ratesState.value = exchangeRateService.fetchRates()
        } catch (_: Exception) {
            // Keep last known rates when refresh fails.
        }
    }

    fun converter(): CurrencyConverter = CurrencyConverter(ratesState.value)
}
