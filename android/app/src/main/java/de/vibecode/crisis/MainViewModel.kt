package de.vibecode.crisis

import android.app.Application
import androidx.lifecycle.AndroidViewModel
import androidx.lifecycle.viewModelScope
import de.vibecode.crisis.core.model.AsyncState
import de.vibecode.crisis.core.model.DashboardSnapshot
import de.vibecode.crisis.core.model.CrisisThresholdProfile
import de.vibecode.crisis.core.model.DisplayCurrency
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.SharingStarted
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.stateIn
import kotlinx.coroutines.launch
import kotlinx.datetime.Clock
import kotlinx.datetime.Instant

class MainViewModel(application: Application) : AndroidViewModel(application) {
    private val container = (application as CrisisApp).container

    val bennerEntries = container.bennerCycleService.makeEntries()

    private val _dashboardState = MutableStateFlow<AsyncState<DashboardSnapshot>>(AsyncState.Idle)
    val dashboardState: StateFlow<AsyncState<DashboardSnapshot>> = _dashboardState

    private val _syncNotice = MutableStateFlow<SyncNotice?>(null)
    val syncNotice: StateFlow<SyncNotice?> = _syncNotice

    private val _notificationStatus = MutableStateFlow(NotificationAuthorizationState.UNKNOWN)
    val notificationStatus: StateFlow<NotificationAuthorizationState> = _notificationStatus

    private val _lastUpdated = MutableStateFlow<Instant?>(null)
    val lastUpdated: StateFlow<Instant?> = _lastUpdated

    val selectedCurrency = container.currencyRepository.selectedCurrencyFlow
        .stateIn(viewModelScope, SharingStarted.WhileSubscribed(5_000), DisplayCurrency.EUR)

    val exchangeRates = container.currencyRepository.ratesFlow
        .stateIn(viewModelScope, SharingStarted.WhileSubscribed(5_000), null)

    val onboardingCompleted = container.userPreferences.onboardingCompletedFlow
        .stateIn(viewModelScope, SharingStarted.WhileSubscribed(5_000), false)

    val geopoliticalWatchlist = container.userPreferences.geopoliticalWatchlistFlow
        .stateIn(viewModelScope, SharingStarted.WhileSubscribed(5_000), emptySet())

    val financialWatchlist = container.userPreferences.financialWatchlistFlow
        .stateIn(viewModelScope, SharingStarted.WhileSubscribed(5_000), emptySet())

    val crisisThresholdProfile = container.userPreferences.crisisThresholdProfileFlow
        .stateIn(viewModelScope, SharingStarted.WhileSubscribed(5_000), CrisisThresholdProfile.STANDARD)

    private val lastSuccessfulSync = container.userPreferences.lastSuccessfulSyncFlow
        .stateIn(viewModelScope, SharingStarted.WhileSubscribed(5_000), null)

    fun refreshDashboard(force: Boolean = false) {
        if (_dashboardState.value is AsyncState.Loading && !force) return
        viewModelScope.launch {
            _dashboardState.value = AsyncState.Loading
            _syncNotice.value = null
            try {
                val snapshot = container.dashboardRepository.makeSnapshot()
                _dashboardState.value = AsyncState.Loaded(snapshot)
                val now = Clock.System.now()
                _lastUpdated.value = now
                container.dashboardCache.persist(snapshot)
                container.userPreferences.setLastSuccessfulSync(now)
                container.userPreferences.setLastSyncError(null)
                container.notificationHelper.processHighPriorityAlert(snapshot.crises)
                _syncNotice.value = null
            } catch (error: Exception) {
                val cached = container.dashboardCache.load()
                val message = error.message ?: "Fehler beim Laden"
                container.userPreferences.setLastSyncError(message)
                if (cached != null) {
                    _dashboardState.value = AsyncState.Loaded(cached)
                } else {
                    _dashboardState.value = AsyncState.Failed(message)
                }
                _syncNotice.value = SyncNotice(lastSuccessfulSync.value, message)
            }
        }
    }

    fun refreshNotificationStatus() {
        _notificationStatus.value = container.notificationHelper.currentStatus()
    }

    fun setSelectedCurrency(currency: DisplayCurrency) {
        viewModelScope.launch {
            container.currencyRepository.setSelectedCurrency(currency)
        }
    }

    fun refreshRates() {
        viewModelScope.launch {
            container.currencyRepository.refreshRatesIfStale()
        }
    }

    fun markOnboardingCompleted() {
        viewModelScope.launch {
            container.userPreferences.setOnboardingCompleted(true)
        }
    }

    fun setGeopoliticalWatchlist(codes: Set<String>) {
        viewModelScope.launch {
            container.userPreferences.setGeopoliticalWatchlist(codes)
        }
    }

    fun setFinancialWatchlist(codes: Set<String>) {
        viewModelScope.launch {
            container.userPreferences.setFinancialWatchlist(codes)
        }
    }

    fun setCrisisThresholdProfile(profile: CrisisThresholdProfile) {
        viewModelScope.launch {
            container.userPreferences.setCrisisThresholdProfile(profile)
        }
    }
}

data class SyncNotice(
    val lastSuccessfulSync: Instant?,
    val errorDescription: String
)
