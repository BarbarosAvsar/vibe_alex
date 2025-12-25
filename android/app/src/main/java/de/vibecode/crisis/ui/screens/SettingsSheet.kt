package de.vibecode.crisis.ui.screens

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.weight
import androidx.compose.material3.Button
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.SingleChoiceSegmentedButtonRow
import androidx.compose.material3.SegmentedButton
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.unit.dp
import de.vibecode.crisis.NotificationAuthorizationState
import de.vibecode.crisis.R
import de.vibecode.crisis.core.model.DisplayCurrency
import de.vibecode.crisis.ui.components.GlassCard
import de.vibecode.crisis.ui.theme.CrisisColors

@Composable
@OptIn(ExperimentalMaterial3Api::class)
fun SettingsSheet(
    selectedCurrency: DisplayCurrency,
    notificationStatus: NotificationAuthorizationState,
    onCurrencySelected: (DisplayCurrency) -> Unit,
    onNotificationAction: (NotificationAuthorizationState) -> Unit,
    onOpenPrivacyPolicy: () -> Unit,
    onClose: () -> Unit
) {
    Column(
        modifier = Modifier
            .fillMaxWidth()
            .padding(16.dp),
        verticalArrangement = Arrangement.spacedBy(16.dp)
    ) {
        Text(text = stringResource(R.string.settings_title), style = MaterialTheme.typography.titleLarge)

        GlassCard {
            Column(verticalArrangement = Arrangement.spacedBy(12.dp)) {
                Text(text = stringResource(R.string.settings_section_general), style = MaterialTheme.typography.titleMedium)
                Text(text = stringResource(R.string.settings_currency_label), style = MaterialTheme.typography.labelLarge)
                SingleChoiceSegmentedButtonRow {
                    DisplayCurrency.entries.forEach { currency ->
                        SegmentedButton(
                            selected = selectedCurrency == currency,
                            onClick = { onCurrencySelected(currency) },
                            shape = androidx.compose.foundation.shape.RoundedCornerShape(50)
                        ) {
                            Text(text = currency.title)
                        }
                    }
                }
                Text(
                    text = stringResource(R.string.settings_currency_hint),
                    style = MaterialTheme.typography.bodySmall,
                    color = CrisisColors.textSecondary
                )
            }
        }

        GlassCard {
            Column(verticalArrangement = Arrangement.spacedBy(12.dp)) {
                Text(text = stringResource(R.string.settings_notifications_section), style = MaterialTheme.typography.titleMedium)
                Row {
                    Text(text = stringResource(R.string.settings_notifications_label), style = MaterialTheme.typography.labelLarge)
                    Spacer(modifier = Modifier.weight(1f))
                    Text(text = statusValue(notificationStatus), style = MaterialTheme.typography.bodySmall, color = CrisisColors.textSecondary)
                }
                Text(text = statusDescription(notificationStatus), style = MaterialTheme.typography.bodySmall, color = CrisisColors.textSecondary)
                Button(onClick = { onNotificationAction(notificationStatus) }, modifier = Modifier.fillMaxWidth()) {
                    Text(text = statusAction(notificationStatus))
                }
            }
        }

        GlassCard {
            Column(verticalArrangement = Arrangement.spacedBy(12.dp)) {
                Text(text = stringResource(R.string.settings_privacy_section), style = MaterialTheme.typography.titleMedium)
                Button(onClick = onOpenPrivacyPolicy, modifier = Modifier.fillMaxWidth()) {
                    Text(text = stringResource(R.string.settings_privacy_policy))
                }
                Text(text = stringResource(R.string.settings_privacy_note), style = MaterialTheme.typography.bodySmall, color = CrisisColors.textSecondary)
                Text(text = stringResource(R.string.settings_transparency_note), style = MaterialTheme.typography.bodySmall, color = CrisisColors.textSecondary)
                Text(text = stringResource(R.string.settings_contact_note), style = MaterialTheme.typography.bodySmall, color = CrisisColors.textSecondary)
            }
        }

        Button(onClick = onClose, modifier = Modifier.fillMaxWidth()) {
            Text(text = stringResource(R.string.settings_done))
        }
    }
}

@Composable
private fun statusValue(status: NotificationAuthorizationState): String {
    return when (status) {
        NotificationAuthorizationState.AUTHORIZED -> stringResource(R.string.notifications_status_active)
        NotificationAuthorizationState.DENIED -> stringResource(R.string.notifications_status_denied)
        NotificationAuthorizationState.NOT_DETERMINED -> stringResource(R.string.notifications_status_unknown)
        NotificationAuthorizationState.UNKNOWN -> stringResource(R.string.notifications_status_unknown)
    }
}

@Composable
private fun statusDescription(status: NotificationAuthorizationState): String {
    return when (status) {
        NotificationAuthorizationState.AUTHORIZED -> stringResource(R.string.notifications_description_active)
        NotificationAuthorizationState.DENIED -> stringResource(R.string.notifications_description_denied)
        NotificationAuthorizationState.NOT_DETERMINED -> stringResource(R.string.notifications_description_undetermined)
        NotificationAuthorizationState.UNKNOWN -> stringResource(R.string.notifications_description_undetermined)
    }
}

@Composable
private fun statusAction(status: NotificationAuthorizationState): String {
    return when (status) {
        NotificationAuthorizationState.AUTHORIZED -> stringResource(R.string.notifications_action_open_settings)
        NotificationAuthorizationState.DENIED -> stringResource(R.string.notifications_action_open_settings)
        NotificationAuthorizationState.NOT_DETERMINED -> stringResource(R.string.notifications_action_enable)
        NotificationAuthorizationState.UNKNOWN -> stringResource(R.string.notifications_action_enable)
    }
}
