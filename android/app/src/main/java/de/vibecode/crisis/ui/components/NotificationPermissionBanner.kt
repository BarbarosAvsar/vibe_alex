package de.vibecode.crisis.ui.components

import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.width
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.NotificationsOff
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import de.vibecode.crisis.NotificationAuthorizationState
import de.vibecode.crisis.R
import de.vibecode.crisis.ui.theme.CrisisColors
import androidx.compose.ui.res.stringResource

@Composable
fun NotificationPermissionBanner(
    status: NotificationAuthorizationState,
    onAction: () -> Unit
) {
    GlassCard(
        modifier = Modifier.clickable { onAction() }
    ) {
        Row {
            Icon(
                imageVector = Icons.Default.NotificationsOff,
                contentDescription = null,
                tint = CrisisColors.accentStrong
            )
            Spacer(modifier = Modifier.width(12.dp))
            androidx.compose.foundation.layout.Column {
                Text(text = statusTitle(status), style = MaterialTheme.typography.titleMedium)
                Text(text = statusMessage(status), style = MaterialTheme.typography.bodySmall, color = CrisisColors.textMuted)
                Text(
                    text = statusAction(status),
                    style = MaterialTheme.typography.labelLarge,
                    color = CrisisColors.accent
                )
            }
        }
    }
}

@Composable
private fun statusTitle(status: NotificationAuthorizationState): String {
    return when (status) {
        NotificationAuthorizationState.DENIED -> stringResource(R.string.notification_banner_denied)
        NotificationAuthorizationState.NOT_DETERMINED -> stringResource(R.string.notification_banner_missing)
        NotificationAuthorizationState.AUTHORIZED -> stringResource(R.string.settings_notifications_label)
        NotificationAuthorizationState.UNKNOWN -> stringResource(R.string.settings_notifications_label)
    }
}

@Composable
private fun statusMessage(status: NotificationAuthorizationState): String {
    return when (status) {
        NotificationAuthorizationState.DENIED -> stringResource(R.string.notification_banner_message_denied)
        NotificationAuthorizationState.NOT_DETERMINED -> stringResource(R.string.notification_banner_message_missing)
        NotificationAuthorizationState.AUTHORIZED -> ""
        NotificationAuthorizationState.UNKNOWN -> ""
    }
}

@Composable
private fun statusAction(status: NotificationAuthorizationState): String {
    return when (status) {
        NotificationAuthorizationState.DENIED -> stringResource(R.string.notification_banner_action_settings)
        NotificationAuthorizationState.NOT_DETERMINED -> stringResource(R.string.notifications_action_enable)
        NotificationAuthorizationState.AUTHORIZED -> ""
        NotificationAuthorizationState.UNKNOWN -> stringResource(R.string.notifications_action_enable)
    }
}
