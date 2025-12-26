package de.vibecode.crisis.ui.screens

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
import androidx.compose.foundation.rememberScrollState
import androidx.compose.material.ExperimentalMaterialApi
import androidx.compose.material.pullrefresh.PullRefreshIndicator
import androidx.compose.material.pullrefresh.pullRefresh
import androidx.compose.material.pullrefresh.rememberPullRefreshState
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.FilterChip
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.SingleChoiceSegmentedButtonRow
import androidx.compose.material3.SegmentedButton
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
import de.vibecode.crisis.core.model.AsyncState
import de.vibecode.crisis.core.model.DashboardSnapshot
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
            AsyncStateView(state = dashboardState, onRetry = onRefresh) {
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
