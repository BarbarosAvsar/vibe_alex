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
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.ExperimentalMaterialApi
import androidx.compose.material.pullrefresh.PullRefreshIndicator
import androidx.compose.material.pullrefresh.pullRefresh
import androidx.compose.material.pullrefresh.rememberPullRefreshState
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.material3.TopAppBar
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.unit.dp
import androidx.compose.material3.windowsizeclass.WindowSizeClass
import de.vibecode.crisis.R
import de.vibecode.crisis.core.domain.BennerCycleEntry
import de.vibecode.crisis.core.model.AsyncState
import de.vibecode.crisis.core.model.DashboardSnapshot
import de.vibecode.crisis.core.model.CurrencyConverter
import de.vibecode.crisis.core.model.DisplayCurrency
import de.vibecode.crisis.core.model.ExchangeRates
import de.vibecode.crisis.ui.components.AdaptiveColumns
import de.vibecode.crisis.ui.components.AsyncStateView
import de.vibecode.crisis.ui.components.DashboardSection
import de.vibecode.crisis.ui.components.GlassCard
import de.vibecode.crisis.ui.components.LogoMark
import de.vibecode.crisis.ui.components.MetalCard
import de.vibecode.crisis.ui.components.PrimaryCTAButton
import de.vibecode.crisis.ui.components.SettingsButton
import de.vibecode.crisis.ui.components.WhyMetalsSection
import de.vibecode.crisis.ui.theme.CrisisColors
import java.util.Calendar

@Composable
@OptIn(ExperimentalMaterialApi::class, ExperimentalMaterial3Api::class)
fun OverviewScreen(
    dashboardState: AsyncState<DashboardSnapshot>,
    bennerEntries: List<BennerCycleEntry>,
    windowSizeClass: WindowSizeClass,
    selectedCurrency: DisplayCurrency,
    exchangeRates: ExchangeRates?,
    onRefresh: () -> Unit,
    onOpenSettings: () -> Unit,
    onOpenConsultation: () -> Unit
) {
    val pullState = rememberPullRefreshState(
        refreshing = dashboardState is AsyncState.Loading,
        onRefresh = onRefresh
    )

    Column {
        TopAppBar(
            title = { Text(text = stringResource(R.string.overview_title)) },
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
                            WarningHero(entries = bennerEntries)
                            MetalFocusSection(snapshot, selectedCurrency, converter)
                        },
                        second = {
                            MacroSection(snapshot)
                            WhyMetalsSection()
                        }
                    )

                    PrimaryCTAButton(
                        title = stringResource(R.string.cta_title),
                        subtitle = stringResource(R.string.cta_subtitle),
                        onClick = onOpenConsultation
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
private fun WarningHero(entries: List<BennerCycleEntry>) {
    val currentYear = Calendar.getInstance().get(Calendar.YEAR)
    val entry = entries.firstOrNull { it.year >= currentYear } ?: entries.lastOrNull()
    if (entry == null) return

    DashboardSection(
        title = stringResource(R.string.overview_hero_title),
        subtitle = stringResource(R.string.overview_hero_subtitle)
    ) {
        GlassCard {
            Column(verticalArrangement = Arrangement.spacedBy(12.dp)) {
                Row(verticalAlignment = Alignment.CenterVertically) {
                    Text(
                        text = stringResource(R.string.overview_forecast_label),
                        style = MaterialTheme.typography.labelLarge,
                        color = CrisisColors.textOnAccent,
                        modifier = Modifier
                            .background(CrisisColors.accentStrong, shape = androidx.compose.foundation.shape.RoundedCornerShape(20.dp))
                            .padding(horizontal = 12.dp, vertical = 6.dp)
                    )
                    Spacer(modifier = Modifier.weight(1f))
                    Text(text = "${entry.year}", style = MaterialTheme.typography.titleMedium)
                }
                Text(text = entry.summary, style = MaterialTheme.typography.titleMedium)
                Text(
                    text = stringResource(R.string.overview_forecast_hint),
                    style = MaterialTheme.typography.bodySmall,
                    color = CrisisColors.textMuted
                )
            }
        }
    }
}

@Composable
private fun MetalFocusSection(
    snapshot: DashboardSnapshot,
    selectedCurrency: DisplayCurrency,
    converter: CurrencyConverter
) {
    DashboardSection(
        title = stringResource(R.string.overview_metals_focus),
        subtitle = stringResource(R.string.overview_metals_focus_subtitle)
    ) {
        Column(verticalArrangement = Arrangement.spacedBy(12.dp)) {
            snapshot.metals.take(2).forEach { asset ->
                MetalCard(asset = asset, displayCurrency = selectedCurrency, converter = converter)
            }
        }
    }
}

@Composable
private fun MacroSection(snapshot: DashboardSnapshot) {
    var selectedRegion by remember { mutableStateOf(MacroRegion.GERMANY) }

    DashboardSection(
        title = stringResource(R.string.overview_macro_title),
        subtitle = stringResource(R.string.overview_macro_subtitle)
    ) {
        Row(
            modifier = Modifier.horizontalScroll(rememberScrollState()),
            horizontalArrangement = Arrangement.spacedBy(10.dp)
        ) {
            MacroRegion.entries.forEach { region ->
                val isActive = region == selectedRegion
                Text(
                    text = region.label,
                    style = MaterialTheme.typography.labelLarge,
                    color = if (isActive) CrisisColors.accentStrong else CrisisColors.textSecondary,
                    modifier = Modifier
                        .background(
                            color = if (isActive) CrisisColors.accent.copy(alpha = 0.15f) else CrisisColors.surface,
                            shape = androidx.compose.foundation.shape.RoundedCornerShape(50)
                        )
                        .padding(horizontal = 12.dp, vertical = 8.dp)
                        .clickable { selectedRegion = region }
                )
            }
        }
        Spacer(modifier = Modifier.height(12.dp))
        val indicators = snapshot.macroOverview.indicators
        Row(horizontalArrangement = Arrangement.spacedBy(16.dp), modifier = Modifier.fillMaxWidth()) {
            Column(modifier = Modifier.weight(1f), verticalArrangement = Arrangement.spacedBy(12.dp)) {
                indicators.filterIndexed { index, _ -> index % 2 == 0 }.forEach { indicator ->
                    MacroKpi(indicator = indicator, region = selectedRegion)
                }
            }
            Column(modifier = Modifier.weight(1f), verticalArrangement = Arrangement.spacedBy(12.dp)) {
                indicators.filterIndexed { index, _ -> index % 2 == 1 }.forEach { indicator ->
                    MacroKpi(indicator = indicator, region = selectedRegion)
                }
            }
        }
    }
}

@Composable
private fun MacroKpi(indicator: de.vibecode.crisis.core.model.MacroIndicator, region: MacroRegion) {
    GlassCard {
        Column(verticalArrangement = Arrangement.spacedBy(8.dp)) {
            Row(verticalAlignment = Alignment.CenterVertically) {
                Text(text = indicator.title, style = MaterialTheme.typography.titleMedium)
                Spacer(modifier = Modifier.weight(1f))
                Text(
                    text = region.short,
                    style = MaterialTheme.typography.labelLarge,
                    modifier = Modifier
                        .background(CrisisColors.accentInfo.copy(alpha = 0.3f), shape = androidx.compose.foundation.shape.RoundedCornerShape(20.dp))
                        .padding(horizontal = 8.dp, vertical = 4.dp)
                )
            }
            val latest = indicator.latestValue
            val previous = indicator.previousValue
            val formatted = latest?.let { "%.1f${indicator.unit}".format(it) } ?: "-"
            val delta = if (latest != null && previous != null) {
                val diff = latest - previous
                val sign = if (diff >= 0) "+" else ""
                "$sign${"%.1f".format(diff)}${indicator.unit} vs. Vorjahr"
            } else {
                "Kein Verlauf"
            }
            Text(text = formatted, style = MaterialTheme.typography.titleLarge)
            Text(text = delta, style = MaterialTheme.typography.bodySmall, color = CrisisColors.textMuted)
        }
    }
}

private enum class MacroRegion(val label: String) {
    GERMANY("DE"),
    USA("USA"),
    SPAIN("ES"),
    UK("UK");

    val short: String
        get() = label
}
