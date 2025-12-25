package de.vibecode.crisis.core.data

import android.content.Context
import androidx.datastore.preferences.core.booleanPreferencesKey
import androidx.datastore.preferences.core.edit
import androidx.datastore.preferences.core.longPreferencesKey
import androidx.datastore.preferences.core.stringPreferencesKey
import androidx.datastore.preferences.preferencesDataStoreFile
import androidx.datastore.preferences.core.PreferenceDataStoreFactory
import de.vibecode.crisis.core.model.DisplayCurrency
import kotlinx.coroutines.flow.Flow
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
}
