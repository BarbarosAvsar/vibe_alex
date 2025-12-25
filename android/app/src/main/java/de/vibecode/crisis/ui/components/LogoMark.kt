package de.vibecode.crisis.ui.components

import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.graphics.Color
import de.vibecode.crisis.ui.theme.CrisisColors

@Composable
fun LogoMark() {
    Text(
        text = "CRISIS 2050",
        style = MaterialTheme.typography.titleMedium,
        color = CrisisColors.textPrimary
    )
}
