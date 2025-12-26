package de.vibecode.crisis.ui.components

import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.layout.height
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.ArrowDownward
import androidx.compose.material.icons.filled.ArrowUpward
import androidx.compose.material3.HorizontalDivider
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.unit.dp
import de.vibecode.crisis.R
import de.vibecode.crisis.core.model.CurrencyConverter
import de.vibecode.crisis.core.model.DisplayCurrency
import de.vibecode.crisis.core.model.MetalAsset
import de.vibecode.crisis.ui.metalInsightLabel
import de.vibecode.crisis.ui.theme.CrisisColors
import java.text.DateFormat
import java.text.NumberFormat
import java.util.Date
import java.util.Locale

@Composable
fun MetalCard(
    asset: MetalAsset,
    displayCurrency: DisplayCurrency,
    converter: CurrencyConverter
) {
    val convertedPrice = converter.convert(asset.price, asset.currency, displayCurrency)
    val priceFormatter = NumberFormat.getCurrencyInstance(Locale.getDefault()).apply {
        currency = java.util.Currency.getInstance(displayCurrency.code)
    }
    val changeColor = if (asset.dailyChangePercentage >= 0) Color(0xFF1B8F3A) else Color(0xFFB3261E)
    val changeLabel = stringResource(R.string.metal_insight_24h)

    GlassCard {
        Column {
            Row(verticalAlignment = Alignment.CenterVertically) {
                Column {
                    Text(text = asset.name, style = MaterialTheme.typography.titleMedium)
                    Text(text = asset.symbol, style = MaterialTheme.typography.bodySmall, color = CrisisColors.textSecondary)
                }
                Spacer(modifier = Modifier.weight(1f))
                Text(text = priceFormatter.format(convertedPrice), style = MaterialTheme.typography.titleLarge)
            }
            Spacer(modifier = Modifier.height(6.dp))
            Row(verticalAlignment = Alignment.CenterVertically) {
                Icon(
                    imageVector = if (asset.dailyChangePercentage >= 0) Icons.Default.ArrowUpward else Icons.Default.ArrowDownward,
                    contentDescription = null,
                    tint = changeColor
                )
                Spacer(modifier = Modifier.width(4.dp))
                Text(
                    text = String.format(Locale.getDefault(), "%.2f%% %s", asset.dailyChangePercentage, changeLabel),
                    style = MaterialTheme.typography.bodySmall,
                    color = changeColor
                )
                Spacer(modifier = Modifier.weight(1f))
                val timeFormatter = DateFormat.getTimeInstance(DateFormat.SHORT)
                Text(
                    text = timeFormatter.format(Date(asset.lastUpdated.toEpochMilliseconds())),
                    style = MaterialTheme.typography.bodySmall,
                    color = CrisisColors.textMuted
                )
            }
            Spacer(modifier = Modifier.height(6.dp))
            HorizontalDivider(color = CrisisColors.border)
            Spacer(modifier = Modifier.height(6.dp))
            Column(verticalArrangement = androidx.compose.foundation.layout.Arrangement.spacedBy(8.dp)) {
                asset.insights.chunked(2).forEach { rowItems ->
                    Row(modifier = Modifier.fillMaxWidth()) {
                        rowItems.forEach { insight ->
                            Row(modifier = Modifier.weight(1f), verticalAlignment = Alignment.CenterVertically) {
                                Text(text = metalInsightLabel(insight), style = MaterialTheme.typography.bodySmall)
                                Spacer(modifier = Modifier.weight(1f))
                                Text(text = insight.value, style = MaterialTheme.typography.labelLarge)
                            }
                            Spacer(modifier = Modifier.width(8.dp))
                        }
                    }
                }
            }
            Spacer(modifier = Modifier.height(6.dp))
            Text(
                text = stringResource(R.string.metal_source_label, asset.dataSource.label),
                style = MaterialTheme.typography.bodySmall,
                color = CrisisColors.textMuted
            )
        }
    }
}
