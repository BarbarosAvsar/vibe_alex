package de.vibecode.crisis.ui.screens

import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.verticalScroll
import androidx.compose.material3.Button
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.material3.TopAppBar
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.LocalUriHandler
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.unit.dp
import de.vibecode.crisis.R
import de.vibecode.crisis.core.model.CrisisEvent
import de.vibecode.crisis.ui.components.GlassCard
import de.vibecode.crisis.ui.components.LogoMark
import de.vibecode.crisis.ui.theme.CrisisColors
import java.text.DateFormat
import java.util.Date

@Composable
@OptIn(ExperimentalMaterial3Api::class)
fun CrisisDetailScreen(
    event: CrisisEvent?,
    relatedEvents: List<CrisisEvent>,
    onClose: () -> Unit
) {
    Column {
        TopAppBar(
            title = { Text(text = stringResource(R.string.crisis_detail_title)) },
            navigationIcon = { LogoMark() },
            actions = {
                Button(onClick = onClose) {
                    Text(text = stringResource(R.string.settings_done))
                }
            }
        )

        Column(
            modifier = Modifier
                .verticalScroll(rememberScrollState())
                .padding(16.dp),
            verticalArrangement = Arrangement.spacedBy(16.dp)
        ) {
            if (event == null) {
                Text(text = stringResource(R.string.crisis_detail_missing), color = CrisisColors.textSecondary)
                return
            }

            GlassCard {
                Column(verticalArrangement = Arrangement.spacedBy(8.dp)) {
                    Text(text = event.title, style = MaterialTheme.typography.titleLarge)
                    Text(text = event.region, style = MaterialTheme.typography.bodyMedium, color = CrisisColors.textSecondary)
                    Text(
                        text = categoryLabel(event),
                        style = MaterialTheme.typography.labelLarge,
                        modifier = Modifier
                            .background(categoryTint(event).copy(alpha = 0.2f), shape = androidx.compose.foundation.shape.RoundedCornerShape(20.dp))
                            .padding(horizontal = 10.dp, vertical = 4.dp)
                    )
                    event.summary?.let {
                        Text(text = it, style = MaterialTheme.typography.bodyMedium, color = CrisisColors.textSecondary)
                    }
                    val formatter = DateFormat.getDateTimeInstance(DateFormat.MEDIUM, DateFormat.SHORT)
                    Text(
                        text = stringResource(
                            R.string.crisis_detail_time,
                            formatter.format(Date(event.occurredAt.toEpochMilliseconds()))
                        ),
                        style = MaterialTheme.typography.bodySmall,
                        color = CrisisColors.textMuted
                    )
                    event.sourceName?.let {
                        Text(
                            text = stringResource(R.string.crisis_detail_source, it),
                            style = MaterialTheme.typography.bodySmall,
                            color = CrisisColors.textMuted
                        )
                    }
                    event.detailUrl?.let { url ->
                        val uriHandler = LocalUriHandler.current
                        Text(
                            text = stringResource(R.string.crisis_detail_open_source),
                            style = MaterialTheme.typography.bodySmall,
                            color = CrisisColors.accentStrong,
                            modifier = Modifier
                                .background(CrisisColors.surface, shape = androidx.compose.foundation.shape.RoundedCornerShape(12.dp))
                                .padding(horizontal = 12.dp, vertical = 6.dp)
                                .clickable { uriHandler.openUri(url) }
                        )
                    }
                }
            }

            GlassCard {
                Column(verticalArrangement = Arrangement.spacedBy(12.dp)) {
                    Text(text = stringResource(R.string.crisis_detail_timeline_title), style = MaterialTheme.typography.titleMedium)
                    relatedEvents.take(6).forEach { item ->
                        TimelineItem(item)
                    }
                }
            }
        }
    }
}

@Composable
private fun TimelineItem(event: CrisisEvent) {
    val formatter = DateFormat.getDateTimeInstance(DateFormat.MEDIUM, DateFormat.SHORT)
    Row(verticalAlignment = Alignment.CenterVertically) {
        Spacer(
            modifier = Modifier
                .size(10.dp)
                .background(CrisisColors.accentStrong, shape = androidx.compose.foundation.shape.RoundedCornerShape(50))
        )
        Spacer(modifier = Modifier.width(12.dp))
        Column {
            Text(text = event.title, style = MaterialTheme.typography.bodyMedium)
            Text(
                text = formatter.format(Date(event.occurredAt.toEpochMilliseconds())),
                style = MaterialTheme.typography.bodySmall,
                color = CrisisColors.textMuted
            )
        }
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
private fun categoryTint(event: CrisisEvent): Color {
    return when (event.category) {
        de.vibecode.crisis.core.model.CrisisCategory.FINANCIAL -> CrisisColors.accent
        de.vibecode.crisis.core.model.CrisisCategory.GEOPOLITICAL -> CrisisColors.accentInfo
    }
}
