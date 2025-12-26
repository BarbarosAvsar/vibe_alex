package de.vibecode.crisis.ui.screens

import androidx.compose.foundation.background
import androidx.compose.foundation.horizontalScroll
import androidx.compose.foundation.verticalScroll
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.rememberScrollState
import androidx.compose.material.ExperimentalMaterialApi
import androidx.compose.material.pullrefresh.PullRefreshIndicator
import androidx.compose.material.pullrefresh.pullRefresh
import androidx.compose.material.pullrefresh.rememberPullRefreshState
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.FilterChip
import androidx.compose.material3.LinearProgressIndicator
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.SingleChoiceSegmentedButtonRow
import androidx.compose.material3.SegmentedButton
import androidx.compose.material3.Slider
import androidx.compose.material3.Text
import androidx.compose.material3.TopAppBar
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.unit.dp
import androidx.compose.material3.windowsizeclass.WindowSizeClass
import de.vibecode.crisis.CrisisApp
import de.vibecode.crisis.R
import de.vibecode.crisis.core.domain.AssetGroup
import de.vibecode.crisis.core.domain.BennerCycleEntry
import de.vibecode.crisis.core.domain.ComparisonAsset
import de.vibecode.crisis.core.domain.ComparisonAssetSeries
import de.vibecode.crisis.core.domain.ComparisonPoint
import de.vibecode.crisis.core.model.MacroIndicatorKind
import de.vibecode.crisis.core.model.MacroSeries
import de.vibecode.crisis.core.model.AsyncState
import de.vibecode.crisis.core.model.DashboardSnapshot
import de.vibecode.crisis.core.data.MacroIndicatorService
import de.vibecode.crisis.ui.components.AdaptiveColumns
import de.vibecode.crisis.ui.components.AsyncStateView
import de.vibecode.crisis.ui.components.DashboardSection
import de.vibecode.crisis.ui.components.GlassCard
import de.vibecode.crisis.ui.components.LineChart
import de.vibecode.crisis.ui.components.LineSeries
import de.vibecode.crisis.ui.components.ChartPoint
import de.vibecode.crisis.ui.components.LogoMark
import de.vibecode.crisis.ui.components.SettingsButton
import de.vibecode.crisis.ui.theme.CrisisColors
import kotlinx.coroutines.async
import kotlinx.coroutines.coroutineScope
import java.util.Calendar
import kotlin.math.pow

@Composable
@OptIn(ExperimentalMaterialApi::class, ExperimentalMaterial3Api::class)
fun ComparisonScreen(
    dashboardState: AsyncState<DashboardSnapshot>,
    bennerEntries: List<BennerCycleEntry>,
    windowSizeClass: WindowSizeClass,
    onRefresh: () -> Unit,
    onOpenSettings: () -> Unit
) {
    val context = LocalContext.current
    val engine = remember { (context.applicationContext as CrisisApp).container.comparisonEngine }
    val macroService = remember { (context.applicationContext as CrisisApp).container.macroIndicatorService }
    var mode by remember { mutableStateOf(ComparisonMode.HISTORY) }
    var activeAssets by remember { mutableStateOf(setOf(ComparisonAsset.EQUITY_DE, ComparisonAsset.EQUITY_USA, ComparisonAsset.GOLD)) }
    var series by remember { mutableStateOf<List<ComparisonAssetSeries>>(emptyList()) }
    var isLoading by remember { mutableStateOf(false) }

    val pullState = rememberPullRefreshState(refreshing = dashboardState is AsyncState.Loading, onRefresh = onRefresh)

    Column {
        TopAppBar(
            title = { Text(text = stringResource(R.string.comparison_title)) },
            navigationIcon = { LogoMark() },
            actions = { SettingsButton(onOpenSettings) }
        )

        Box(modifier = Modifier.pullRefresh(pullState)) {
            AsyncStateView(state = dashboardState, onRetry = onRefresh) { snapshot ->
                LaunchedEffect(bennerEntries) {
                    if (series.isEmpty()) {
                        isLoading = true
                        series = engine.loadAssets(bennerEntries)
                        isLoading = false
                    }
                }

                Column(
                    modifier = Modifier
                        .verticalScroll(rememberScrollState())
                        .padding(16.dp)
                ) {
                    AdaptiveColumns(
                        windowSizeClass = windowSizeClass,
                        first = {
                            AssetSelection(
                                mode = mode,
                                onModeChange = { mode = it },
                                series = series,
                                activeAssets = activeAssets,
                                onToggleAsset = { asset ->
                                    activeAssets = if (activeAssets.contains(asset)) {
                                        activeAssets - asset
                                    } else {
                                        activeAssets + asset
                                    }
                                },
                                isLoading = isLoading
                            )
                        },
                        second = {
                            ComparisonChartSection(
                                series = series,
                                mode = mode,
                                activeAssets = activeAssets,
                                isLoading = isLoading
                            )
                            Spacer(modifier = Modifier.height(16.dp))
                            PerformanceSection(series = series, activeAssets = activeAssets, isLoading = isLoading)
                            Spacer(modifier = Modifier.height(16.dp))
                            MacroComparisonSection(macroService = macroService)
                            Spacer(modifier = Modifier.height(16.dp))
                            ScenarioLabSection(snapshot = snapshot)
                        }
                    )
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
@OptIn(ExperimentalMaterial3Api::class)
private fun AssetSelection(
    mode: ComparisonMode,
    onModeChange: (ComparisonMode) -> Unit,
    series: List<ComparisonAssetSeries>,
    activeAssets: Set<ComparisonAsset>,
    onToggleAsset: (ComparisonAsset) -> Unit,
    isLoading: Boolean
) {
    DashboardSection(
        title = stringResource(R.string.comparison_section_title),
        subtitle = stringResource(R.string.comparison_section_subtitle)
    ) {
        if (isLoading && series.isEmpty()) {
            Text(text = stringResource(R.string.comparison_loading))
        }

        SingleChoiceSegmentedButtonRow {
            ComparisonMode.entries.forEach { item ->
                SegmentedButton(
                    selected = mode == item,
                    onClick = { onModeChange(item) },
                    shape = androidx.compose.foundation.shape.RoundedCornerShape(50)
                ) {
                    Text(text = stringResource(item.label))
                }
            }
        }

        Spacer(modifier = Modifier.height(12.dp))

        AssetGroup.entries.forEach { group ->
            Text(text = group.label, style = MaterialTheme.typography.labelLarge)
            Row(
                modifier = Modifier
                    .horizontalScroll(rememberScrollState())
                    .padding(vertical = 8.dp),
                horizontalArrangement = Arrangement.spacedBy(10.dp)
            ) {
                series.filter { it.asset.group == group }.forEach { item ->
                    FilterChip(
                        selected = activeAssets.contains(item.asset),
                        onClick = { onToggleAsset(item.asset) },
                        label = { Text(text = item.asset.displayName) }
                    )
                }
            }
        }
    }
}

@Composable
private fun ComparisonChartSection(
    series: List<ComparisonAssetSeries>,
    mode: ComparisonMode,
    activeAssets: Set<ComparisonAsset>,
    isLoading: Boolean
) {
    DashboardSection(
        title = stringResource(R.string.comparison_chart_title),
        subtitle = stringResource(R.string.comparison_chart_subtitle)
    ) {
        val selected = series.filter { activeAssets.contains(it.asset) }
        val hasData = selected.any { (mode == ComparisonMode.HISTORY && it.history.isNotEmpty()) || (mode == ComparisonMode.FORECAST && it.projection.isNotEmpty()) }

        when {
            isLoading && !hasData -> {
                Text(text = stringResource(R.string.comparison_loading))
            }
            !hasData -> {
                Text(text = stringResource(R.string.comparison_no_data), color = CrisisColors.textSecondary)
            }
            else -> {
                GlassCard {
                    val colorMap = comparisonColors()
                    val lineSeries = selected.mapNotNull { item ->
                        val points = if (mode == ComparisonMode.HISTORY) item.history else item.projection
                        if (points.isEmpty()) null else {
                            LineSeries(
                                points = points.map { ChartPoint(it.year.toFloat(), it.value.toFloat()) },
                                color = colorMap[item.asset] ?: CrisisColors.accent
                            )
                        }
                    }
                    val currentYear = Calendar.getInstance().get(Calendar.YEAR).toFloat()
                    LineChart(series = lineSeries, showTodayMarker = true, todayX = currentYear)
                }
            }
        }
    }
}

@Composable
private fun PerformanceSection(
    series: List<ComparisonAssetSeries>,
    activeAssets: Set<ComparisonAsset>,
    isLoading: Boolean
) {
    DashboardSection(
        title = stringResource(R.string.comparison_performance_title),
        subtitle = stringResource(R.string.comparison_performance_subtitle)
    ) {
        val selected = series.filter { activeAssets.contains(it.asset) }
        val hasHistory = selected.any { it.history.isNotEmpty() }

        when {
            isLoading && !hasHistory -> {
                Text(text = stringResource(R.string.comparison_loading))
            }
            !hasHistory -> {
                Text(text = stringResource(R.string.comparison_no_data), color = CrisisColors.textSecondary)
            }
            else -> {
                Column(verticalArrangement = Arrangement.spacedBy(10.dp)) {
                    selected.forEach { item ->
                        Row {
                            Text(text = item.asset.displayName, style = MaterialTheme.typography.labelLarge)
                            Spacer(modifier = Modifier.weight(1f))
                            Text(
                                text = "Historisch ${cagr(item.history)} / Prognose ${projectionDelta(item.history, item.projection)}",
                                style = MaterialTheme.typography.bodySmall,
                                color = CrisisColors.textSecondary
                            )
                        }
                    }
                }
            }
        }
    }
}

@Composable
@OptIn(ExperimentalMaterial3Api::class)
private fun MacroComparisonSection(
    macroService: MacroIndicatorService
) {
    val regions = remember { macroRegions() }
    var selectedKind by remember { mutableStateOf(MacroIndicatorKind.INFLATION) }
    var seriesByRegion by remember { mutableStateOf<Map<String, MacroSeries>>(emptyMap()) }
    var isLoading by remember { mutableStateOf(false) }

    LaunchedEffect(selectedKind) {
        isLoading = true
        val result = coroutineScope {
            regions.map { region ->
                async {
                    val series = runCatching {
                        macroService.fetchIndicator(selectedKind, region.iso, limit = 12).second
                    }.getOrNull()
                    region.iso to series
                }
            }.mapNotNull { deferred ->
                val (iso, series) = deferred.await()
                series?.let { iso to it }
            }.toMap()
        }
        seriesByRegion = result
        isLoading = false
    }

    DashboardSection(
        title = stringResource(R.string.comparison_macro_title),
        subtitle = stringResource(R.string.comparison_macro_subtitle)
    ) {
        SingleChoiceSegmentedButtonRow {
            MacroIndicatorKind.entries.forEach { kind ->
                SegmentedButton(
                    selected = selectedKind == kind,
                    onClick = { selectedKind = kind },
                    shape = androidx.compose.foundation.shape.RoundedCornerShape(50)
                ) {
                    Text(text = kind.title)
                }
            }
        }

        Spacer(modifier = Modifier.height(12.dp))

        when {
            isLoading && seriesByRegion.isEmpty() -> {
                Text(text = stringResource(R.string.comparison_macro_loading))
            }
            seriesByRegion.isEmpty() -> {
                Text(text = stringResource(R.string.comparison_macro_no_data), color = CrisisColors.textSecondary)
            }
            else -> {
                GlassCard {
                    val colors = macroRegionColors()
                    val series = seriesByRegion.mapNotNull { (iso, series) ->
                        val points = series.points.map { ChartPoint(it.year.toFloat(), it.value.toFloat()) }
                        if (points.isEmpty()) null else {
                            LineSeries(
                                points = points,
                                color = colors[iso] ?: CrisisColors.accent
                            )
                        }
                    }
                    LineChart(series = series)
                    Spacer(modifier = Modifier.height(10.dp))
                    Row(horizontalArrangement = Arrangement.spacedBy(10.dp)) {
                        regions.forEach { region ->
                            Row(verticalAlignment = Alignment.CenterVertically) {
                                Spacer(
                                    modifier = Modifier
                                        .size(8.dp)
                                        .background(colors[region.iso] ?: CrisisColors.accent, shape = androidx.compose.foundation.shape.RoundedCornerShape(50))
                                )
                                Spacer(modifier = Modifier.width(6.dp))
                                Text(text = region.label, style = MaterialTheme.typography.bodySmall, color = CrisisColors.textMuted)
                            }
                        }
                    }
                }
            }
        }
    }
}

@Composable
private fun ScenarioLabSection(snapshot: DashboardSnapshot) {
    val inflationSeed = snapshot.macroOverview.indicators.firstOrNull { it.id == MacroIndicatorKind.INFLATION }?.latestValue?.toFloat() ?: 2f
    val growthSeed = snapshot.macroOverview.indicators.firstOrNull { it.id == MacroIndicatorKind.GROWTH }?.latestValue?.toFloat() ?: 1f
    val defenseSeed = snapshot.macroOverview.indicators.firstOrNull { it.id == MacroIndicatorKind.DEFENSE }?.latestValue?.toFloat() ?: 2f

    var inflation by remember(snapshot) { mutableStateOf(inflationSeed) }
    var growth by remember(snapshot) { mutableStateOf(growthSeed) }
    var defense by remember(snapshot) { mutableStateOf(defenseSeed) }

    val impacts = scenarioImpacts(inflation.toDouble(), growth.toDouble(), defense.toDouble())
    val portfolioScore = portfolioResilience(impacts)

    DashboardSection(
        title = stringResource(R.string.comparison_scenario_title),
        subtitle = stringResource(R.string.comparison_scenario_subtitle)
    ) {
        GlassCard {
            Column(verticalArrangement = Arrangement.spacedBy(12.dp)) {
                ScenarioSliderRow(
                    label = stringResource(R.string.comparison_scenario_inflation),
                    value = inflation,
                    range = -2f..12f,
                    onValueChange = { inflation = it }
                )
                ScenarioSliderRow(
                    label = stringResource(R.string.comparison_scenario_growth),
                    value = growth,
                    range = -5f..10f,
                    onValueChange = { growth = it }
                )
                ScenarioSliderRow(
                    label = stringResource(R.string.comparison_scenario_defense),
                    value = defense,
                    range = 0f..8f,
                    onValueChange = { defense = it }
                )
            }
        }

        Spacer(modifier = Modifier.height(12.dp))

        GlassCard {
            Column(verticalArrangement = Arrangement.spacedBy(12.dp)) {
                ScenarioImpactRow(stringResource(R.string.comparison_scenario_equities), impacts[AssetGroup.EQUITIES] ?: 0.0)
                ScenarioImpactRow(stringResource(R.string.comparison_scenario_real_estate), impacts[AssetGroup.REAL_ESTATE] ?: 0.0)
                ScenarioImpactRow(stringResource(R.string.comparison_scenario_metals), impacts[AssetGroup.METALS] ?: 0.0)
            }
        }

        Spacer(modifier = Modifier.height(12.dp))

        GlassCard {
            Column(verticalArrangement = Arrangement.spacedBy(8.dp)) {
                Text(text = stringResource(R.string.comparison_portfolio_title), style = MaterialTheme.typography.titleMedium)
                Text(text = stringResource(R.string.comparison_portfolio_subtitle), style = MaterialTheme.typography.bodySmall, color = CrisisColors.textSecondary)
                LinearProgressIndicator(
                    progress = { portfolioScore.toFloat() },
                    color = CrisisColors.accentStrong
                )
                Text(
                    text = String.format("%.0f%%", portfolioScore * 100),
                    style = MaterialTheme.typography.bodySmall,
                    color = CrisisColors.textMuted
                )
            }
        }
    }
}

@Composable
private fun ScenarioSliderRow(
    label: String,
    value: Float,
    range: ClosedFloatingPointRange<Float>,
    onValueChange: (Float) -> Unit
) {
    Column {
        Row(verticalAlignment = Alignment.CenterVertically) {
            Text(text = label, style = MaterialTheme.typography.bodyMedium)
            Spacer(modifier = Modifier.weight(1f))
            Text(text = String.format("%.1f", value), style = MaterialTheme.typography.bodySmall, color = CrisisColors.textMuted)
        }
        Slider(
            value = value,
            onValueChange = onValueChange,
            valueRange = range
        )
    }
}

@Composable
private fun ScenarioImpactRow(label: String, impact: Double) {
    val normalized = normalizeImpact(impact)
    Column(verticalArrangement = Arrangement.spacedBy(6.dp)) {
        Row(verticalAlignment = Alignment.CenterVertically) {
            Text(text = label, style = MaterialTheme.typography.bodyMedium)
            Spacer(modifier = Modifier.weight(1f))
            Text(text = String.format("%.1f", impact), style = MaterialTheme.typography.bodySmall, color = CrisisColors.textMuted)
        }
        LinearProgressIndicator(
            progress = { normalized.toFloat() },
            color = CrisisColors.accent
        )
    }
}

private fun scenarioImpacts(inflation: Double, growth: Double, defense: Double): Map<AssetGroup, Double> {
    val equities = growth * 0.6 - inflation * 0.3 - defense * 0.1
    val realEstate = growth * 0.4 + inflation * 0.2 - defense * 0.1
    val metals = inflation * 0.5 + defense * 0.3 - growth * 0.2
    return mapOf(
        AssetGroup.EQUITIES to equities,
        AssetGroup.REAL_ESTATE to realEstate,
        AssetGroup.METALS to metals
    )
}

private fun normalizeImpact(value: Double): Double {
    val normalized = (value + 10) / 20
    return normalized.coerceIn(0.0, 1.0)
}

private fun portfolioResilience(impacts: Map<AssetGroup, Double>): Double {
    val weights = mapOf(
        AssetGroup.EQUITIES to 0.5,
        AssetGroup.REAL_ESTATE to 0.3,
        AssetGroup.METALS to 0.2
    )
    val score = weights.entries.sumOf { (group, weight) ->
        normalizeImpact(impacts[group] ?: 0.0) * weight
    }
    return score.coerceIn(0.0, 1.0)
}

private data class MacroRegionOption(val iso: String, val label: String)

private fun macroRegions(): List<MacroRegionOption> = listOf(
    MacroRegionOption("DEU", "DE"),
    MacroRegionOption("USA", "US"),
    MacroRegionOption("GBR", "UK"),
    MacroRegionOption("ESP", "ES")
)

private fun macroRegionColors(): Map<String, Color> = mapOf(
    "DEU" to CrisisColors.accent,
    "USA" to CrisisColors.accentStrong,
    "GBR" to CrisisColors.accentInfo,
    "ESP" to CrisisColors.textSecondary
)

private fun cagr(history: List<ComparisonPoint>): String {
    val first = history.firstOrNull() ?: return "n/v"
    val last = history.lastOrNull() ?: return "n/v"
    if (first.year == last.year) return "n/v"
    val years = (last.year - first.year).toDouble()
    val base = kotlin.math.max(last.value, 0.1) / kotlin.math.max(first.value, 0.1)
    val growth = base.pow(1 / years) - 1
    return String.format("%.1f%%", growth * 100)
}

private fun projectionDelta(history: List<ComparisonPoint>, projection: List<ComparisonPoint>): String {
    val lastHistory = history.lastOrNull() ?: return "n/v"
    val lastProjection = projection.lastOrNull() ?: return "n/v"
    val delta = (lastProjection.value - lastHistory.value) / kotlin.math.max(lastHistory.value, 0.1)
    return String.format("%.1f%%", delta * 100)
}

private fun comparisonColors(): Map<ComparisonAsset, Color> {
    return mapOf(
        ComparisonAsset.EQUITY_DE to CrisisColors.accent,
        ComparisonAsset.EQUITY_USA to CrisisColors.accentStrong,
        ComparisonAsset.EQUITY_LON to CrisisColors.accentInfo,
        ComparisonAsset.REAL_ESTATE_DE to CrisisColors.accent.copy(alpha = 0.8f),
        ComparisonAsset.REAL_ESTATE_ES to CrisisColors.accentStrong.copy(alpha = 0.8f),
        ComparisonAsset.REAL_ESTATE_FR to CrisisColors.accentInfo.copy(alpha = 0.8f),
        ComparisonAsset.REAL_ESTATE_LON to CrisisColors.accent.copy(alpha = 0.6f),
        ComparisonAsset.GOLD to CrisisColors.accentStrong,
        ComparisonAsset.SILVER to CrisisColors.accentInfo
    )
}

enum class ComparisonMode(val label: Int) {
    HISTORY(R.string.comparison_mode_history),
    FORECAST(R.string.comparison_mode_forecast);
}
