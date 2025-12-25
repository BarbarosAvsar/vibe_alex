package de.vibecode.crisis.ui.components

import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.height
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import de.vibecode.crisis.R
import de.vibecode.crisis.ui.theme.CrisisColors

@Composable
fun DashboardSection(
    title: String,
    subtitle: String = "",
    content: @Composable () -> Unit
) {
    Column {
        Text(text = title, style = MaterialTheme.typography.titleMedium)
        if (subtitle.isNotEmpty()) {
            Text(text = subtitle, style = MaterialTheme.typography.bodySmall, color = CrisisColors.textSecondary)
            Spacer(modifier = Modifier.height(8.dp))
        } else {
            Spacer(modifier = Modifier.height(4.dp))
        }
        content()
    }
}
