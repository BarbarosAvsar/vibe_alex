package de.vibecode.crisis.ui.components

import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.width
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.WifiOff
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.unit.dp
import de.vibecode.crisis.R
import de.vibecode.crisis.SyncNotice
import de.vibecode.crisis.ui.theme.CrisisColors
import java.text.DateFormat
import java.util.Date

@Composable
fun SyncStatusBanner(notice: SyncNotice) {
    GlassCard {
        Row {
            Icon(
                imageVector = Icons.Default.WifiOff,
                contentDescription = null,
                tint = CrisisColors.accentStrong
            )
            Spacer(modifier = Modifier.width(12.dp))
            androidx.compose.foundation.layout.Column {
                Text(text = stringResource(R.string.offline_banner_title), style = MaterialTheme.typography.titleMedium)
                val lastSyncText = notice.lastSuccessfulSync?.let {
                    val formatter = DateFormat.getDateTimeInstance(DateFormat.MEDIUM, DateFormat.SHORT)
                    stringResource(R.string.sync_last_successful, formatter.format(Date(it.toEpochMilliseconds())))
                } ?: stringResource(R.string.sync_never_successful)
                Text(text = lastSyncText, style = MaterialTheme.typography.bodySmall, color = CrisisColors.textSecondary)
                Text(text = notice.errorDescription, style = MaterialTheme.typography.bodySmall, color = CrisisColors.textMuted)
            }
        }
    }
}
