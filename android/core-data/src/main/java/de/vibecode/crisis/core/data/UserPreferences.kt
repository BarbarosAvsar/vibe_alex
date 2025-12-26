package de.vibecode.crisis.core.data

import android.content.Context
import androidx.datastore.preferences.core.booleanPreferencesKey
import androidx.datastore.preferences.core.edit
import androidx.datastore.preferences.core.longPreferencesKey
import androidx.datastore.preferences.core.stringPreferencesKey
import androidx.datastore.preferences.core.stringSetPreferencesKey
import androidx.datastore.preferences.preferencesDataStoreFile
import androidx.datastore.preferences.core.PreferenceDataStoreFactory
import de.vibecode.crisis.core.model.DisplayCurrency
import de.vibecode.crisis.core.model.CrisisSettings
import de.vibecode.crisis.core.model.CrisisThresholdProfile
import de.vibecode.crisis.core.model.CrisisWatchlists
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.first
import kotlinx.coroutines.flow.map
import kotlinx.datetime.Instant

class UserPreferences(context: Context) {
    private val dataStore = PreferenceDataStoreFactory.create {
        context.preferencesDataStoreFile("crisis_prefs")
    }

    private val currencyKey = stringPreferencesKey("preferred_currency")
    private val lastNotifiedKey = stringPreferencesKey("last_notified_crisis_id")
    private val lastSyncKey = longPreferencesKey("last_sync_time")
    private val lastSyncErrorKey = stringPreferencesKey("last_sync_error")
    private val onboardingKey = booleanPreferencesKey("notification_onboarding_completed")
    private val geoWatchlistKey = stringSetPreferencesKey("watchlist_geopolitical")
    private val financialWatchlistKey = stringSetPreferencesKey("watchlist_financial")
    private val thresholdProfileKey = stringPreferencesKey("crisis_threshold_profile")
    private val languageKey = stringPreferencesKey("preferred_language")

    val selectedCurrencyFlow: Flow<DisplayCurrency> = dataStore.data.map { prefs ->
        val code = prefs[currencyKey] ?: DisplayCurrency.EUR.code
        DisplayCurrency.fromCode(code) ?: DisplayCurrency.EUR
    }

    val lastNotifiedIdFlow: Flow<String?> = dataStore.data.map { prefs ->
        prefs[lastNotifiedKey]
    }

    val lastSuccessfulSyncFlow: Flow<Instant?> = dataStore.data.map { prefs ->
        prefs[lastSyncKey]?.let { Instant.fromEpochMilliseconds(it) }
    }

    val lastSyncErrorFlow: Flow<String?> = dataStore.data.map { prefs ->
        prefs[lastSyncErrorKey]
    }

    val onboardingCompletedFlow: Flow<Boolean> = dataStore.data.map { prefs ->
        prefs[onboardingKey] ?: false
    }

    val geopoliticalWatchlistFlow: Flow<Set<String>> = dataStore.data.map { prefs ->
        prefs[geoWatchlistKey] ?: CrisisWatchlists.geopolitical.map { it.code }.toSet()
    }

    val financialWatchlistFlow: Flow<Set<String>> = dataStore.data.map { prefs ->
        prefs[financialWatchlistKey] ?: CrisisWatchlists.financial.map { it.code }.toSet()
    }

    val crisisThresholdProfileFlow: Flow<CrisisThresholdProfile> = dataStore.data.map { prefs ->
        CrisisThresholdProfile.fromId(prefs[thresholdProfileKey])
    }

    val appLanguageTagFlow: Flow<String> = dataStore.data.map { prefs ->
        prefs[languageKey] ?: "de"
    }

    suspend fun setSelectedCurrency(currency: DisplayCurrency) {
        dataStore.edit { prefs ->
            prefs[currencyKey] = currency.code
        }
    }

    suspend fun setLastNotifiedId(id: String) {
        dataStore.edit { prefs ->
            prefs[lastNotifiedKey] = id
        }
    }

    suspend fun setLastSuccessfulSync(instant: Instant?) {
        dataStore.edit { prefs ->
            if (instant == null) {
                prefs.remove(lastSyncKey)
            } else {
                prefs[lastSyncKey] = instant.toEpochMilliseconds()
            }
        }
    }

    suspend fun setLastSyncError(message: String?) {
        dataStore.edit { prefs ->
            if (message == null) {
                prefs.remove(lastSyncErrorKey)
            } else {
                prefs[lastSyncErrorKey] = message
            }
        }
    }

    suspend fun setOnboardingCompleted(completed: Boolean) {
        dataStore.edit { prefs ->
            prefs[onboardingKey] = completed
        }
    }

    suspend fun setGeopoliticalWatchlist(codes: Set<String>) {
        dataStore.edit { prefs ->
            prefs[geoWatchlistKey] = codes
        }
    }

    suspend fun setFinancialWatchlist(codes: Set<String>) {
        dataStore.edit { prefs ->
            prefs[financialWatchlistKey] = codes
        }
    }

    suspend fun setCrisisThresholdProfile(profile: CrisisThresholdProfile) {
        dataStore.edit { prefs ->
            prefs[thresholdProfileKey] = profile.id
        }
    }

    suspend fun setAppLanguageTag(tag: String) {
        dataStore.edit { prefs ->
            prefs[languageKey] = tag
        }
    }

    suspend fun getCrisisSettings(): CrisisSettings {
        val prefs = dataStore.data.first()
        val geopolitical = prefs[geoWatchlistKey] ?: CrisisWatchlists.geopolitical.map { it.code }.toSet()
        val financial = prefs[financialWatchlistKey] ?: CrisisWatchlists.financial.map { it.code }.toSet()
        val profile = CrisisThresholdProfile.fromId(prefs[thresholdProfileKey])
        return CrisisSettings(profile, geopolitical, financial)
    }
}
