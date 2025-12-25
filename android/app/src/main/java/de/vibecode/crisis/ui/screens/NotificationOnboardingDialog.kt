package de.vibecode.crisis.ui.screens

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Lock
import androidx.compose.material.icons.filled.Notifications
import androidx.compose.material.icons.filled.VerifiedUser
import androidx.compose.material3.Button
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Surface
import androidx.compose.material3.Switch
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.unit.dp
import androidx.compose.ui.window.Dialog
import de.vibecode.crisis.NotificationAuthorizationState
import de.vibecode.crisis.R
import de.vibecode.crisis.ui.components.GlassCard
import de.vibecode.crisis.ui.theme.CrisisColors

@Composable
fun NotificationOnboardingDialog(
    status: NotificationAuthorizationState,
    onDismiss: () -> Unit,
    onEnable: () -> Unit
) {
    var wantsAlerts by remember { mutableStateOf(true) }
    var errorMessage by remember { mutableStateOf<String?>(null) }
    val toggleErrorText = stringResource(R.string.notification_onboarding_error_toggle)

    Dialog(onDismissRequest = onDismiss) {
        Surface(
            shape = androidx.compose.foundation.shape.RoundedCornerShape(24.dp),
            tonalElevation = 4.dp
        ) {
            Column(
                modifier = Modifier
                    .padding(20.dp)
                    .verticalScroll(rememberScrollState()),
                verticalArrangement = Arrangement.spacedBy(16.dp)
            ) {
                Column(horizontalAlignment = Alignment.CenterHorizontally) {
                    Icon(imageVector = Icons.Default.Notifications, contentDescription = null, tint = CrisisColors.accentStrong)
                    Text(text = stringResource(R.string.notification_onboarding_headline), style = MaterialTheme.typography.titleLarge)
                    Text(
                        text = stringResource(R.string.notification_onboarding_body),
                        style = MaterialTheme.typography.bodySmall,
                        color = CrisisColors.textSecondary
                    )
                    statusHint(status)?.let { hint ->
                        Text(text = hint, style = MaterialTheme.typography.bodySmall, color = CrisisColors.textSecondary)
                    }
                }

                GlassCard {
                    Row(verticalAlignment = Alignment.CenterVertically) {
                        Column(modifier = Modifier.weight(1f)) {
                            Text(text = stringResource(R.string.notification_onboarding_toggle_title), style = MaterialTheme.typography.titleMedium)
                            Text(
                                text = stringResource(R.string.notification_onboarding_toggle_hint),
                                style = MaterialTheme.typography.bodySmall,
                                color = CrisisColors.textMuted
                            )
                        }
                        Switch(checked = wantsAlerts, onCheckedChange = { wantsAlerts = it })
                    }
                }

                Column(verticalArrangement = Arrangement.spacedBy(6.dp)) {
                    Row(verticalAlignment = Alignment.CenterVertically) {
                        Icon(imageVector = Icons.Default.Lock, contentDescription = null, tint = CrisisColors.textMuted)
                        Spacer(modifier = Modifier.width(8.dp))
                        Text(text = stringResource(R.string.notification_onboarding_device_hint), style = MaterialTheme.typography.bodySmall)
                    }
                    Row(verticalAlignment = Alignment.CenterVertically) {
                        Icon(imageVector = Icons.Default.VerifiedUser, contentDescription = null, tint = CrisisColors.textMuted)
                        Spacer(modifier = Modifier.width(8.dp))
                        Text(text = stringResource(R.string.notification_onboarding_privacy_hint), style = MaterialTheme.typography.bodySmall)
                    }
                }

                errorMessage?.let {
                    Text(text = it, style = MaterialTheme.typography.bodySmall, color = CrisisColors.accentStrong)
                }

                Button(
                    onClick = {
                        if (!wantsAlerts) {
                            errorMessage = toggleErrorText
                            return@Button
                        }
                        onEnable()
                    },
                    modifier = Modifier.fillMaxWidth()
                ) {
                    Text(text = stringResource(R.string.notification_onboarding_enable))
                }

                Button(
                    onClick = onDismiss,
                    modifier = Modifier.fillMaxWidth()
                ) {
                    Text(text = stringResource(R.string.notification_onboarding_later))
                }
            }
        }
    }
}

@Composable
private fun statusHint(status: NotificationAuthorizationState): String? {
    return when (status) {
        NotificationAuthorizationState.DENIED -> stringResource(R.string.notification_onboarding_error_settings)
        NotificationAuthorizationState.NOT_DETERMINED -> null
        NotificationAuthorizationState.AUTHORIZED -> null
        NotificationAuthorizationState.UNKNOWN -> null
    }
}
