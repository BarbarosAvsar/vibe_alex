package de.vibecode.crisis.ui.screens

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.weight
import androidx.compose.foundation.verticalScroll
import androidx.compose.foundation.rememberScrollState
import androidx.compose.material.ExperimentalMaterialApi
import androidx.compose.material.pullrefresh.PullRefreshIndicator
import androidx.compose.material.pullrefresh.pullRefresh
import androidx.compose.material.pullrefresh.rememberPullRefreshState
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.material3.TopAppBar
import androidx.compose.runtime.Composable
import androidx.compose.runtime.remember
import androidx.compose.runtime.getValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.unit.dp
import androidx.compose.material3.windowsizeclass.WindowSizeClass
import de.vibecode.crisis.R
import de.vibecode.crisis.core.domain.CrisisSummaryGenerator
import de.vibecode.crisis.core.model.AsyncState
import de.vibecode.crisis.core.model.CrisisEvent
import de.vibecode.crisis.core.model.DashboardSnapshot
import de.vibecode.crisis.ui.components.AdaptiveColumns
import de.vibecode.crisis.ui.components.AsyncStateView
import de.vibecode.crisis.ui.components.DashboardSection
import de.vibecode.crisis.ui.components.GlassCard
import de.vibecode.crisis.ui.components.LogoMark
import de.vibecode.crisis.ui.components.SettingsButton
import de.vibecode.crisis.ui.theme.CrisisColors
import java.text.DateFormat
import java.util.Date

@Composable
@OptIn(ExperimentalMaterialApi::class)
fun CrisisScreen(
    dashboardState: AsyncState<DashboardSnapshot>,
    onRefresh: () -> Unit,
    onOpenSettings: () -> Unit,
    windowSizeClass: WindowSizeClass
) {
    val pullState = rememberPullRefreshState(refreshing = dashboardState is AsyncState.Loading, onRefresh = onRefresh)
    val summaryGenerator = remember { CrisisSummaryGenerator() }

    Column {
        TopAppBar(
            title = { Text(text = stringResource(R.string.crisis_title)) },
            navigationIcon = { LogoMark() },
            actions = { SettingsButton(onOpenSettings) }
        )

        Box(modifier = Modifier.pullRefresh(pullState)) {
            AsyncStateView(state = dashboardState, onRetry = onRefresh) { snapshot ->
                Column(
                    modifier = Modifier
                        .verticalScroll(rememberScrollState())
                        .padding(16.dp),
                    verticalArrangement = Arrangement.spacedBy(24.dp)
                ) {
                    AdaptiveColumns(
                        windowSizeClass = windowSizeClass,
                        first = {
                            CrisisOverviewSection(summaryGenerator, snapshot.crises)
                        },
                        second = {
                            CrisisFeedSection(snapshot.crises)
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
private fun CrisisOverviewSection(
    summaryGenerator: CrisisSummaryGenerator,
    events: List<CrisisEvent>
) {
    DashboardSection(
        title = stringResource(R.string.crisis_overview_title),
        subtitle = stringResource(R.string.crisis_overview_subtitle)
    ) {
        val summary = summaryGenerator.summarize(events)
        if (summary == null) {
            Text(text = stringResource(R.string.crisis_overview_empty), color = CrisisColors.textSecondary)
        } else {
            GlassCard {
                Column(verticalArrangement = Arrangement.spacedBy(8.dp)) {
                    Text(text = summary.headline, style = MaterialTheme.typography.titleMedium)
                    summary.highlights.forEach { highlight ->
                        Text(text = highlight, style = MaterialTheme.typography.bodySmall, color = CrisisColors.textSecondary)
                    }
                }
            }
        }
    }
}

@Composable
private fun CrisisFeedSection(events: List<CrisisEvent>) {
    DashboardSection(
        title = stringResource(R.string.crisis_feed_title),
        subtitle = stringResource(R.string.crisis_feed_subtitle)
    ) {
        if (events.isEmpty()) {
            Text(text = stringResource(R.string.crisis_feed_empty), color = CrisisColors.textSecondary)
        } else {
            Column(verticalArrangement = Arrangement.spacedBy(12.dp)) {
                events.forEach { event ->
                    CrisisEventCard(event)
                }
            }
        }
    }
}

@Composable
private fun CrisisEventCard(event: CrisisEvent) {
    GlassCard {
        Column(verticalArrangement = Arrangement.spacedBy(10.dp)) {
            Row {
                Text(text = event.title, style = MaterialTheme.typography.titleMedium)
                Spacer(modifier = Modifier.weight(1f))
                Text(
                    text = severityBadge(event.severityScore),
                    style = MaterialTheme.typography.labelLarge,
                    color = CrisisColors.textPrimary,
                    modifier = Modifier
                        .background(severityTint(event.severityScore).copy(alpha = 0.2f), shape = androidx.compose.foundation.shape.RoundedCornerShape(20.dp))
                        .padding(horizontal = 8.dp, vertical = 4.dp)
                )
            }
            event.summary?.let {
                Text(text = it, style = MaterialTheme.typography.bodyMedium, color = CrisisColors.textSecondary)
            }
            Row {
                Text(text = event.region, style = MaterialTheme.typography.bodySmall, color = CrisisColors.textMuted)
                Spacer(modifier = Modifier.weight(1f))
                val formatter = DateFormat.getDateTimeInstance(DateFormat.MEDIUM, DateFormat.SHORT)
                Text(
                    text = formatter.format(Date(event.occurredAt.toEpochMilliseconds())),
                    style = MaterialTheme.typography.bodySmall,
                    color = CrisisColors.textMuted
                )
            }
            Row(horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                Text(
                    text = categoryLabel(event),
                    style = MaterialTheme.typography.labelLarge,
                    modifier = Modifier
                        .background(categoryTint(event).copy(alpha = 0.2f), shape = androidx.compose.foundation.shape.RoundedCornerShape(20.dp))
                        .padding(horizontal = 8.dp, vertical = 4.dp)
                )
                Text(
                    text = event.sourceName ?: event.source.label,
                    style = MaterialTheme.typography.bodySmall,
                    color = CrisisColors.textSecondary
                )
            }
        }
    }
}

@Composable
private fun severityBadge(score: Double): String {
    return when {
        score < 4 -> stringResource(R.string.crisis_badge_info)
        score < 6 -> stringResource(R.string.crisis_badge_moderate)
        else -> stringResource(R.string.crisis_badge_high)
    }
}

@Composable
private fun severityTint(score: Double): androidx.compose.ui.graphics.Color {
    return when {
        score < 4 -> CrisisColors.accentInfo
        score < 6 -> CrisisColors.accent
        else -> CrisisColors.accentStrong
    }
}

@Composable
private fun categoryLabel(event: CrisisEvent): String {
    return when (event.category) {
        de.vibecode.crisis.core.model.CrisisCategory.FINANCIAL -> stringResource(R.string.crisis_category_financial)
        de.vibecode.crisis.core.model.CrisisCategory.GEOPOLITICAL -> stringResource(R.string.crisis_category_geopolitical)
    }
}

@Composable
private fun categoryTint(event: CrisisEvent): androidx.compose.ui.graphics.Color {
    return when (event.category) {
        de.vibecode.crisis.core.model.CrisisCategory.FINANCIAL -> CrisisColors.accent
        de.vibecode.crisis.core.model.CrisisCategory.GEOPOLITICAL -> CrisisColors.accentInfo
    }
}
