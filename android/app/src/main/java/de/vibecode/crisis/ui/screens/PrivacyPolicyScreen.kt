package de.vibecode.crisis.ui.screens

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.verticalScroll
import androidx.compose.material3.Button
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.material3.TopAppBar
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.unit.dp
import de.vibecode.crisis.R
import de.vibecode.crisis.ui.components.GlassCard
import de.vibecode.crisis.ui.components.LogoMark
import de.vibecode.crisis.ui.theme.CrisisColors

@Composable
@OptIn(ExperimentalMaterial3Api::class)
fun PrivacyPolicyScreen(onClose: () -> Unit) {
    Column {
        TopAppBar(
            title = { Text(text = stringResource(R.string.privacy_policy_title)) },
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
            Text(
                text = stringResource(R.string.privacy_policy_intro),
                style = MaterialTheme.typography.bodyMedium,
                color = CrisisColors.textSecondary
            )
            privacySections().forEach { section ->
                GlassCard {
                    Column(verticalArrangement = Arrangement.spacedBy(8.dp)) {
                        Text(text = section.title, style = MaterialTheme.typography.titleMedium)
                        Text(text = section.body, style = MaterialTheme.typography.bodySmall, color = CrisisColors.textMuted)
                    }
                }
            }
        }
    }
}

private data class PrivacySection(val title: String, val body: String)

@Composable
private fun privacySections(): List<PrivacySection> {
    return listOf(
        PrivacySection(
            title = stringResource(R.string.privacy_section_controller_title),
            body = stringResource(R.string.privacy_section_controller_body)
        ),
        PrivacySection(
            title = stringResource(R.string.privacy_section_collection_title),
            body = stringResource(R.string.privacy_section_collection_body)
        ),
        PrivacySection(
            title = stringResource(R.string.privacy_section_contact_title),
            body = stringResource(R.string.privacy_section_contact_body)
        ),
        PrivacySection(
            title = stringResource(R.string.privacy_section_notifications_title),
            body = stringResource(R.string.privacy_section_notifications_body)
        ),
        PrivacySection(
            title = stringResource(R.string.privacy_section_tracking_title),
            body = stringResource(R.string.privacy_section_tracking_body)
        ),
        PrivacySection(
            title = stringResource(R.string.privacy_section_rights_title),
            body = stringResource(R.string.privacy_section_rights_body)
        )
    )
}
