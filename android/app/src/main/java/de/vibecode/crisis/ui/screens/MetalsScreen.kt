package de.vibecode.crisis.ui.screens

import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.horizontalScroll
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.ExperimentalMaterialApi
import androidx.compose.material.pullrefresh.PullRefreshIndicator
import androidx.compose.material.pullrefresh.pullRefresh
import androidx.compose.material.pullrefresh.rememberPullRefreshState
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.LinearProgressIndicator
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.material3.TopAppBar
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateMapOf
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.unit.dp
import androidx.compose.material3.windowsizeclass.WindowSizeClass
import de.vibecode.crisis.CrisisApp
import de.vibecode.crisis.R
import de.vibecode.crisis.core.domain.BennerCycleEntry
import de.vibecode.crisis.core.domain.BennerPhase
import de.vibecode.crisis.core.domain.metalTrendMultiplier
import de.vibecode.crisis.core.model.AsyncState
import de.vibecode.crisis.core.model.CurrencyConverter
import de.vibecode.crisis.core.model.DashboardSnapshot
import de.vibecode.crisis.core.model.DisplayCurrency
import de.vibecode.crisis.core.model.ExchangeRates
import de.vibecode.crisis.core.model.MetalAsset
import de.vibecode.crisis.ui.components.AdaptiveColumns
import de.vibecode.crisis.ui.components.AsyncStateView
import de.vibecode.crisis.ui.components.BrilliantDiamondIcon
import de.vibecode.crisis.ui.components.DashboardSection
import de.vibecode.crisis.ui.components.GlassCard
import de.vibecode.crisis.ui.components.LineChart
import de.vibecode.crisis.ui.components.LineSeries
import de.vibecode.crisis.ui.components.ChartPoint
import de.vibecode.crisis.ui.components.LogoMark
import de.vibecode.crisis.ui.components.MetalCard
import de.vibecode.crisis.ui.components.PrimaryCTAButton
import de.vibecode.crisis.ui.components.SettingsButton
import de.vibecode.crisis.ui.components.WhyMetalsSection
import de.vibecode.crisis.ui.bennerPhaseSubtitle
import de.vibecode.crisis.ui.theme.CrisisColors
import kotlin.math.max
import java.util.Calendar

@Composable
@OptIn(ExperimentalMaterialApi::class, ExperimentalMaterial3Api::class)
fun MetalsScreen(
    dashboardState: AsyncState<DashboardSnapshot>,
    bennerEntries: List<BennerCycleEntry>,
    windowSizeClass: WindowSizeClass,
    selectedCurrency: DisplayCurrency,
    exchangeRates: ExchangeRates?,
    onRefresh: () -> Unit,
    onOpenSettings: () -> Unit,
    onOpenConsultation: () -> Unit
) {
    val context = LocalContext.current
    val marketService = remember { (context.applicationContext as CrisisApp).container.marketDataService }
    val pullState = rememberPullRefreshState(refreshing = dashboardState is AsyncState.Loading, onRefresh = onRefresh)
    val metalHistories = remember { mutableStateMapOf<String, List<MetalTrendPoint>>() }
    var selectedMetalId by remember { mutableStateOf<String?>(null) }
    var isLoadingHistory by remember { mutableStateOf(false) }

    Column {
        TopAppBar(
            title = { Text(text = stringResource(R.string.metals_title)) },
            navigationIcon = { LogoMark() },
            actions = { SettingsButton(onOpenSettings) }
        )

        Box(modifier = Modifier.pullRefresh(pullState)) {
            AsyncStateView(state = dashboardState, onRetry = onRefresh) { snapshot ->
                val converter = CurrencyConverter(exchangeRates)
                val scrollState = rememberScrollState()
                Column(
                    modifier = Modifier
                        .verticalScroll(scrollState)
                        .padding(16.dp),
                    verticalArrangement = Arrangement.spacedBy(24.dp)
                ) {
                    AdaptiveColumns(
                        windowSizeClass = windowSizeClass,
                        first = {
                            MetalSelector(
                                metals = snapshot.metals,
                                selectedId = selectedMetalId,
                                onSelect = { selectedMetalId = it }
                            )
                            val focus = selectedMetal(snapshot.metals, selectedMetalId)
                            if (focus != null) {
                                MetalCard(asset = focus, displayCurrency = selectedCurrency, converter = converter)
                                BennerProjection(entries = bennerEntries, metal = focus)
                            }
                        },
                        second = {
                            val focus = selectedMetal(snapshot.metals, selectedMetalId)
                            if (focus != null) {
                                TrendChart(
                                    metal = focus,
                                    entries = bennerEntries,
                                    history = metalHistories[focus.id],
                                    isLoadingHistory = isLoadingHistory,
                                    converter = converter,
                                    displayCurrency = selectedCurrency
                                )
                                CrisisResilience(metal = focus, snapshot = snapshot)
                                WhyMetalsSection()
                            }
                        }
                    )

                    PrimaryCTAButton(
                        title = stringResource(R.string.cta_title),
                        subtitle = stringResource(R.string.cta_subtitle),
                        onClick = onOpenConsultation
                    )
                }

                val focus = selectedMetal(snapshot.metals, selectedMetalId)
                LaunchedEffect(focus?.id) {
                    if (focus != null && metalHistories[focus.id] == null && !isLoadingHistory) {
                        isLoadingHistory = true
                        val instrument = when (focus.symbol.lowercase()) {
                            "xau" -> de.vibecode.crisis.core.domain.MarketInstrument.XAU
                            "xag" -> de.vibecode.crisis.core.domain.MarketInstrument.XAG
                            else -> null
                        }
                        if (instrument != null) {
                            val points = marketService.fetchHistory(instrument, limitYears = 10)
                            metalHistories[focus.id] = points.map { MetalTrendPoint(it.year, it.value, isProjection = false) }
                        }
                        isLoadingHistory = false
                    }
                }
            }
            PullRefreshIndicator(
                refreshing = dashboardState is AsyncState.Loading,
                state = pullState,
                modifier = Modifier.align(Alignment.TopCenter)
            )
        }
    }
}

@Composable
private fun MetalSelector(
    metals: List<MetalAsset>,
    selectedId: String?,
    onSelect: (String) -> Unit
) {
    if (metals.isEmpty()) return
    val activeId = selectedId ?: metals.first().id

    DashboardSection(title = stringResource(R.string.metals_selector_title)) {
        Row(
            modifier = Modifier.horizontalScroll(rememberScrollState()),
            horizontalArrangement = Arrangement.spacedBy(10.dp)
        ) {
            metals.forEach { metal ->
                val isActive = metal.id == activeId
                Row(
                    modifier = Modifier
                        .background(
                            color = if (isActive) CrisisColors.accent.copy(alpha = 0.14f) else CrisisColors.surface,
                            shape = androidx.compose.foundation.shape.RoundedCornerShape(14.dp)
                        )
                        .padding(horizontal = 14.dp, vertical = 10.dp)
                        .clickable { onSelect(metal.id) },
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    BrilliantDiamondIcon(iconSize = 14.dp)
                    Spacer(modifier = Modifier.width(6.dp))
                    Text(text = metal.name, style = MaterialTheme.typography.labelLarge)
                }
            }
        }
    }
}

@Composable
private fun BennerProjection(entries: List<BennerCycleEntry>, metal: MetalAsset) {
    val currentYear = Calendar.getInstance().get(Calendar.YEAR)
    val projections = entries.filter { it.year >= currentYear }.take(3)

    DashboardSection(
        title = stringResource(R.string.metals_projection_title),
        subtitle = stringResource(R.string.metals_projection_subtitle, metal.name)
    ) {
        Column(verticalArrangement = Arrangement.spacedBy(12.dp)) {
            projections.forEach { entry ->
                GlassCard {
                    Row(verticalAlignment = Alignment.CenterVertically) {
                        Column {
                            Text(text = "${entry.year}", style = MaterialTheme.typography.titleMedium)
                            Text(text = bennerPhaseSubtitle(entry.phase), style = MaterialTheme.typography.bodySmall, color = CrisisColors.textSecondary)
                        }
                        Spacer(modifier = Modifier.weight(1f))
                        LinearProgressIndicator(
                            progress = { entry.progress.toFloat() },
                            color = CrisisColors.accent
                        )
                    }
                }
            }
        }
    }
}

@Composable
private fun TrendChart(
    metal: MetalAsset,
    entries: List<BennerCycleEntry>,
    history: List<MetalTrendPoint>?,
    isLoadingHistory: Boolean,
    converter: CurrencyConverter,
    displayCurrency: DisplayCurrency
) {
    val points = metalTrendPoints(metal, entries, history, converter, displayCurrency)
    DashboardSection(
        title = stringResource(R.string.metals_trend_title),
        subtitle = stringResource(R.string.metals_trend_subtitle, metal.name)
    ) {
        if (isLoadingHistory && history == null) {
            Text(text = stringResource(R.string.metals_trend_loading))
        } else {
            GlassCard {
                val historyPoints = points.filter { !it.isProjection }
                val projectionPoints = points.filter { it.isProjection }
                val series = mutableListOf<LineSeries>()
                if (historyPoints.isNotEmpty()) {
                    series.add(
                        LineSeries(
                            points = historyPoints.map { ChartPoint(it.year.toFloat(), it.value.toFloat()) },
                            color = CrisisColors.accentStrong
                        )
                    )
                }
                if (projectionPoints.isNotEmpty()) {
                    series.add(
                        LineSeries(
                            points = projectionPoints.map { ChartPoint(it.year.toFloat(), it.value.toFloat()) },
                            color = CrisisColors.accentStrong.copy(alpha = 0.85f),
                            fill = true
                        )
                    )
                }
                LineChart(series = series)
            }
        }
    }
}

@Composable
private fun CrisisResilience(metal: MetalAsset, snapshot: DashboardSnapshot) {
    DashboardSection(
        title = stringResource(R.string.metals_resilience_title),
        subtitle = stringResource(R.string.metals_resilience_subtitle, metal.name)
    ) {
        val inflation = snapshot.macroOverview.indicators.firstOrNull { it.id == de.vibecode.crisis.core.model.MacroIndicatorKind.INFLATION }?.latestValue ?: 0.0
        val growth = snapshot.macroOverview.indicators.firstOrNull { it.id == de.vibecode.crisis.core.model.MacroIndicatorKind.GROWTH }?.latestValue ?: 0.0
        val defense = snapshot.macroOverview.indicators.firstOrNull { it.id == de.vibecode.crisis.core.model.MacroIndicatorKind.DEFENSE }?.latestValue ?: 0.0

        val scenarios = listOf(
            CrisisScenario(
                title = stringResource(R.string.metals_scenario_inflation),
                description = stringResource(R.string.metals_scenario_inflation_detail, metal.name),
                score = normalizedScore(inflation + metal.dailyChangePercentage),
                badge = stringResource(R.string.metals_badge_protection)
            ),
            CrisisScenario(
                title = stringResource(R.string.metals_scenario_wars),
                description = stringResource(R.string.metals_scenario_wars_detail),
                score = normalizedScore(defense + 5),
                badge = stringResource(R.string.metals_badge_shield)
            ),
            CrisisScenario(
                title = stringResource(R.string.metals_scenario_recession),
                description = stringResource(R.string.metals_scenario_recession_detail, metal.name),
                score = normalizedScore(-growth + 8),
                badge = stringResource(R.string.metals_badge_diversification)
            )
        )

        Column(verticalArrangement = Arrangement.spacedBy(12.dp)) {
            scenarios.forEach { scenario ->
                GlassCard {
                    Column(verticalArrangement = Arrangement.spacedBy(8.dp)) {
                        Row(verticalAlignment = Alignment.CenterVertically) {
                            Text(text = scenario.title, style = MaterialTheme.typography.titleMedium)
                            Spacer(modifier = Modifier.weight(1f))
                            Text(
                                text = scenario.badge,
                                style = MaterialTheme.typography.labelLarge,
                                modifier = Modifier
                                    .background(CrisisColors.surface, shape = androidx.compose.foundation.shape.RoundedCornerShape(20.dp))
                                    .padding(horizontal = 10.dp, vertical = 4.dp)
                            )
                        }
                        Text(text = scenario.description, style = MaterialTheme.typography.bodySmall, color = CrisisColors.textMuted)
                        LinearProgressIndicator(progress = { scenario.score.toFloat() }, color = CrisisColors.accent)
                    }
                }
            }
        }
    }
}

private fun selectedMetal(metals: List<MetalAsset>, selectedId: String?): MetalAsset? {
    if (metals.isEmpty()) return null
    if (selectedId == null) return metals.first()
    return metals.firstOrNull { it.id == selectedId } ?: metals.first()
}

private fun metalTrendPoints(
    metal: MetalAsset,
    entries: List<BennerCycleEntry>,
    history: List<MetalTrendPoint>?,
    converter: CurrencyConverter,
    displayCurrency: DisplayCurrency
): List<MetalTrendPoint> {
    val historyPoints = history.orEmpty()
    val currentYear = Calendar.getInstance().get(Calendar.YEAR)
    val base = historyPoints.lastOrNull()?.value
        ?: max(converter.convert(metal.price, metal.currency, displayCurrency) / 100, 25.0)
    val projections = entries
        .filter { it.year >= currentYear }
        .takeWhile { it.year <= 2050 }
        .fold(mutableListOf<MetalTrendPoint>()) { acc, entry ->
            val lastValue = acc.lastOrNull()?.value ?: base
            val nextValue = lastValue + lastValue * entry.phase.metalTrendMultiplier
            acc.add(MetalTrendPoint(entry.year, nextValue, isProjection = true))
            acc
        }
    return historyPoints + projections
}

private fun normalizedScore(value: Double): Double {
    val normalized = (value + 10) / 20
    return normalized.coerceIn(0.05, 0.95)
}

private data class CrisisScenario(
    val title: String,
    val description: String,
    val score: Double,
    val badge: String
)

private data class MetalTrendPoint(
    val year: Int,
    val value: Double,
    val isProjection: Boolean
)
