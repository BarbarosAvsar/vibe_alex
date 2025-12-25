package de.vibecode.crisis.ui.screens

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.text.KeyboardOptions
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.CheckCircle
import androidx.compose.material.icons.filled.Info
import androidx.compose.material3.AlertDialog
import androidx.compose.material3.Button
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.OutlinedTextField
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.material3.TopAppBar
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.rememberCoroutineScope
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.text.input.ImeAction
import androidx.compose.ui.text.input.KeyboardType
import androidx.compose.ui.unit.dp
import androidx.lifecycle.viewmodel.compose.viewModel
import de.vibecode.crisis.R
import de.vibecode.crisis.ui.components.GlassCard
import de.vibecode.crisis.ui.components.LogoMark
import de.vibecode.crisis.ui.components.SettingsButton
import de.vibecode.crisis.ui.theme.CrisisColors
import kotlinx.coroutines.launch

@Composable
fun ConsultationScreen(
    onOpenSettings: () -> Unit,
    viewModel: ConsultationViewModel = viewModel()
) {
    var alert by remember { mutableStateOf<SubmissionResult?>(null) }
    var attemptedSubmit by remember { mutableStateOf(false) }
    val scope = rememberCoroutineScope()

    Column {
        TopAppBar(
            title = { Text(text = stringResource(R.string.consultation_title)) },
            navigationIcon = { LogoMark() },
            actions = { SettingsButton(onOpenSettings) }
        )

        Column(
            modifier = Modifier
                .verticalScroll(rememberScrollState())
                .padding(16.dp),
            verticalArrangement = Arrangement.spacedBy(20.dp)
        ) {
            GlassCard {
                Column(verticalArrangement = Arrangement.spacedBy(8.dp)) {
                    Text(text = stringResource(R.string.consultation_section_expectations), style = MaterialTheme.typography.titleMedium)
                    ExpectationItem(text = stringResource(R.string.consultation_expectation_1))
                    ExpectationItem(text = stringResource(R.string.consultation_expectation_2))
                    ExpectationItem(text = stringResource(R.string.consultation_expectation_3))
                    ExpectationItem(text = stringResource(R.string.consultation_expectation_4))
                }
            }

            GlassCard {
                Column(verticalArrangement = Arrangement.spacedBy(12.dp)) {
                    Text(text = stringResource(R.string.consultation_section_contact), style = MaterialTheme.typography.titleMedium)
                    OutlinedTextField(
                        value = viewModel.name,
                        onValueChange = viewModel::updateName,
                        label = { Text(stringResource(R.string.consultation_name)) },
                        keyboardOptions = KeyboardOptions(imeAction = ImeAction.Next),
                        modifier = Modifier.fillMaxWidth()
                    )
                    OutlinedTextField(
                        value = viewModel.email,
                        onValueChange = viewModel::updateEmail,
                        label = { Text(stringResource(R.string.consultation_email)) },
                        keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Email, imeAction = ImeAction.Next),
                        modifier = Modifier.fillMaxWidth()
                    )
                    OutlinedTextField(
                        value = viewModel.phone,
                        onValueChange = viewModel::updatePhone,
                        label = { Text(stringResource(R.string.consultation_phone)) },
                        keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Phone, imeAction = ImeAction.Next),
                        modifier = Modifier.fillMaxWidth()
                    )
                }
            }

            GlassCard {
                Column(verticalArrangement = Arrangement.spacedBy(12.dp)) {
                    Text(text = stringResource(R.string.consultation_section_message), style = MaterialTheme.typography.titleMedium)
                    OutlinedTextField(
                        value = viewModel.message,
                        onValueChange = viewModel::updateMessage,
                        label = { Text(stringResource(R.string.consultation_message_hint)) },
                        keyboardOptions = KeyboardOptions(keyboardType = KeyboardType.Text),
                        modifier = Modifier
                            .fillMaxWidth()
                            .height(160.dp),
                        minLines = 5
                    )
                }
            }

            val error = viewModel.errorMessage ?: if (attemptedSubmit) viewModel.validationError else null
            if (error != null) {
                Text(text = error, style = MaterialTheme.typography.bodySmall, color = CrisisColors.accentStrong)
            }

            Button(
                onClick = {
                    attemptedSubmit = true
                    scope.launch {
                        alert = viewModel.submit()
                    }
                },
                modifier = Modifier.fillMaxWidth(),
                enabled = !viewModel.isSubmitting
            ) {
                Text(text = if (viewModel.isSubmitting) "..." else stringResource(R.string.consultation_submit))
            }

            Text(
                text = stringResource(R.string.consultation_privacy_note),
                style = MaterialTheme.typography.bodySmall,
                color = CrisisColors.textSecondary
            )

            GlassCard {
                Column(verticalArrangement = Arrangement.spacedBy(10.dp)) {
                    Text(text = stringResource(R.string.consultation_section_more_info), style = MaterialTheme.typography.titleMedium)
                    InfoCard(
                        title = stringResource(R.string.consultation_info_1_title),
                        text = stringResource(R.string.consultation_info_1_text)
                    )
                    InfoCard(
                        title = stringResource(R.string.consultation_info_2_title),
                        text = stringResource(R.string.consultation_info_2_text)
                    )
                }
            }
        }
    }

    when (val result = alert) {
        SubmissionResult.Success -> {
            AlertDialog(
                onDismissRequest = { alert = null },
                confirmButton = {
                    TextButton(onClick = { alert = null }) {
                        Text(text = "Okay")
                    }
                },
                title = { Text(stringResource(R.string.consultation_submit_success_title)) },
                text = { Text(stringResource(R.string.consultation_submit_success_message)) }
            )
        }
        is SubmissionResult.Failure -> {
            AlertDialog(
                onDismissRequest = { alert = null },
                confirmButton = {
                    TextButton(onClick = { alert = null }) {
                        Text(text = "Okay")
                    }
                },
                title = { Text(stringResource(R.string.consultation_submit_failure_title)) },
                text = { Text(result.message) }
            )
        }
        null -> Unit
    }
}

@Composable
private fun ExpectationItem(text: String) {
    Row(verticalAlignment = Alignment.CenterVertically) {
        androidx.compose.material3.Icon(imageVector = Icons.Default.CheckCircle, contentDescription = null, tint = CrisisColors.accent)
        Spacer(modifier = Modifier.width(8.dp))
        Text(text = text, style = MaterialTheme.typography.bodyMedium)
    }
}

@Composable
private fun InfoCard(title: String, text: String) {
    Column(verticalArrangement = Arrangement.spacedBy(4.dp)) {
        Row(verticalAlignment = Alignment.CenterVertically) {
            androidx.compose.material3.Icon(imageVector = Icons.Default.Info, contentDescription = null, tint = CrisisColors.accentInfo)
            Spacer(modifier = Modifier.width(8.dp))
            Text(text = title, style = MaterialTheme.typography.labelLarge)
        }
        Text(text = text, style = MaterialTheme.typography.bodySmall, color = CrisisColors.textMuted)
    }
}
