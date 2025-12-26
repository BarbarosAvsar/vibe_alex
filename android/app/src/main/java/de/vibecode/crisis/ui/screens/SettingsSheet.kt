package de.vibecode.crisis.ui.screens

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.Button
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.SingleChoiceSegmentedButtonRow
import androidx.compose.material3.SegmentedButton
import androidx.compose.material3.Switch
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.unit.dp
import de.vibecode.crisis.AppLanguage
import de.vibecode.crisis.NotificationAuthorizationState
import de.vibecode.crisis.R
import de.vibecode.crisis.core.model.CrisisThresholdProfile
import de.vibecode.crisis.core.model.CrisisWatchlists
import de.vibecode.crisis.core.model.DisplayCurrency
import de.vibecode.crisis.ui.appLanguageLabel
import de.vibecode.crisis.ui.displayCurrencyLabel
import de.vibecode.crisis.ui.watchlistCountryLabel
import de.vibecode.crisis.ui.components.GlassCard
import de.vibecode.crisis.ui.theme.CrisisColors

@Composable
@OptIn(ExperimentalMaterial3Api::class)
fun SettingsSheet(
    selectedCurrency: DisplayCurrency,
    selectedLanguage: AppLanguage,
    notificationStatus: NotificationAuthorizationState,
    thresholdProfile: CrisisThresholdProfile,
    geopoliticalWatchlist: Set<String>,
    financialWatchlist: Set<String>,
    onCurrencySelected: (DisplayCurrency) -> Unit,
    onLanguageSelected: (AppLanguage) -> Unit,
    onNotificationAction: (NotificationAuthorizationState) -> Unit,
    onThresholdProfileSelected: (CrisisThresholdProfile) -> Unit,
    onGeopoliticalWatchlistChanged: (Set<String>) -> Unit,
    onFinancialWatchlistChanged: (Set<String>) -> Unit,
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
                            Text(text = displayCurrencyLabel(currency))
                        }
                    }
                }
                Text(
                    text = stringResource(R.string.settings_currency_hint),
                    style = MaterialTheme.typography.bodySmall,
                    color = CrisisColors.textSecondary
                )
                Text(text = stringResource(R.string.settings_language_label), style = MaterialTheme.typography.labelLarge)
                SingleChoiceSegmentedButtonRow {
                    AppLanguage.entries.forEach { language ->
                        SegmentedButton(
                            selected = selectedLanguage == language,
                            onClick = { onLanguageSelected(language) },
                            shape = androidx.compose.foundation.shape.RoundedCornerShape(50)
                        ) {
                            Text(text = appLanguageLabel(language))
                        }
                    }
                }
                Text(
                    text = stringResource(R.string.settings_language_hint),
                    style = MaterialTheme.typography.bodySmall,
                    color = CrisisColors.textSecondary
                )
            }
        }

        GlassCard {
            Column(verticalArrangement = Arrangement.spacedBy(12.dp)) {
                Text(text = stringResource(R.string.settings_watchlist_section), style = MaterialTheme.typography.titleMedium)
                Text(text = stringResource(R.string.settings_watchlist_geopolitical), style = MaterialTheme.typography.labelLarge)
                CrisisWatchlists.geopolitical.forEach { country ->
                    val enabled = geopoliticalWatchlist.contains(country.code)
                    Row {
                        Text(text = watchlistCountryLabel(country.code), style = MaterialTheme.typography.bodyMedium)
                        Spacer(modifier = Modifier.weight(1f))
                        Switch(
                            checked = enabled,
                            onCheckedChange = { checked ->
                                val updated = if (checked) geopoliticalWatchlist + country.code else geopoliticalWatchlist - country.code
                                onGeopoliticalWatchlistChanged(updated)
                            }
                        )
                    }
                }
                Text(text = stringResource(R.string.settings_watchlist_financial), style = MaterialTheme.typography.labelLarge)
                CrisisWatchlists.financial.forEach { country ->
                    val enabled = financialWatchlist.contains(country.code)
                    Row {
                        Text(text = watchlistCountryLabel(country.code), style = MaterialTheme.typography.bodyMedium)
                        Spacer(modifier = Modifier.weight(1f))
                        Switch(
                            checked = enabled,
                            onCheckedChange = { checked ->
                                val updated = if (checked) financialWatchlist + country.code else financialWatchlist - country.code
                                onFinancialWatchlistChanged(updated)
                            }
                        )
                    }
                }
            }
        }

        GlassCard {
            Column(verticalArrangement = Arrangement.spacedBy(12.dp)) {
                Text(text = stringResource(R.string.settings_thresholds_section), style = MaterialTheme.typography.titleMedium)
                Text(text = stringResource(R.string.settings_thresholds_label), style = MaterialTheme.typography.labelLarge)
                SingleChoiceSegmentedButtonRow {
                    CrisisThresholdProfile.entries.forEach { profile ->
                        SegmentedButton(
                            selected = thresholdProfile == profile,
                            onClick = { onThresholdProfileSelected(profile) },
                            shape = androidx.compose.foundation.shape.RoundedCornerShape(50)
                        ) {
                            Text(text = thresholdLabel(profile))
                        }
                    }
                }
                Text(
                    text = stringResource(R.string.settings_thresholds_hint),
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
private fun thresholdLabel(profile: CrisisThresholdProfile): String {
    return when (profile) {
        CrisisThresholdProfile.STANDARD -> stringResource(R.string.settings_thresholds_standard)
        CrisisThresholdProfile.SENSITIVE -> stringResource(R.string.settings_thresholds_sensitive)
        CrisisThresholdProfile.CONSERVATIVE -> stringResource(R.string.settings_thresholds_conservative)
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
