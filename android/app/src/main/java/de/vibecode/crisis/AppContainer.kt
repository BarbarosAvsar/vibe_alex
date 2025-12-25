package de.vibecode.crisis

import android.content.Context
import de.vibecode.crisis.core.data.AppConfig
import de.vibecode.crisis.core.data.AssetComparisonEngine
import de.vibecode.crisis.core.data.ConsultationService
import de.vibecode.crisis.core.data.CrisisMonitorService
import de.vibecode.crisis.core.data.CurrencyRepository
import de.vibecode.crisis.core.data.DashboardCache
import de.vibecode.crisis.core.data.DashboardRepository
import de.vibecode.crisis.core.data.ExchangeRateService
import de.vibecode.crisis.core.data.FinancialStressCrisisFeed
import de.vibecode.crisis.core.data.GeopoliticalAlertCrisisFeed
import de.vibecode.crisis.core.data.MacroIndicatorService
import de.vibecode.crisis.core.data.MarketDataService
import de.vibecode.crisis.core.data.MetalPriceService
import de.vibecode.crisis.core.data.PoliticalFinancialNewsFeed
import de.vibecode.crisis.core.data.UserPreferences
import de.vibecode.crisis.core.domain.BennerCycleService
import de.vibecode.crisis.core.network.NetworkClient

class AppContainer(context: Context) {
    private val appContext = context.applicationContext

    private val json = NetworkClient.json
    private val okHttpClient = NetworkClient.httpClient()
    private val goldPriceApi = NetworkClient.goldPriceApi()
    private val newsApi = NetworkClient.newsApi()

    val userPreferences = UserPreferences(appContext)
    val bennerCycleService = BennerCycleService()

    val metalPriceService = MetalPriceService(goldPriceApi)
    val macroIndicatorService = MacroIndicatorService(okHttpClient, json)
    val crisisMonitorService = CrisisMonitorService(
        listOf(
            PoliticalFinancialNewsFeed(newsApi, BuildConfig.NEWS_API_KEY.ifBlank { null }),
            GeopoliticalAlertCrisisFeed(okHttpClient, json),
            FinancialStressCrisisFeed(okHttpClient, json)
        )
    )

    val dashboardRepository = DashboardRepository(metalPriceService, macroIndicatorService, crisisMonitorService)
    val dashboardCache = DashboardCache(appContext, json)

    val exchangeRateService = ExchangeRateService(okHttpClient)
    val currencyRepository = CurrencyRepository(userPreferences, exchangeRateService)

    val marketDataService = MarketDataService(okHttpClient)
    val comparisonEngine = AssetComparisonEngine(marketDataService)

    val consultationService = ConsultationService(okHttpClient, json, AppConfig.CONSULTATION_ENDPOINT)

    val notificationHelper = NotificationHelper(appContext, userPreferences)
}
