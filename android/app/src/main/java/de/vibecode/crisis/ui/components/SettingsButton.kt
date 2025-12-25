package de.vibecode.crisis.ui.components

import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Settings
import androidx.compose.material3.Icon
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import de.vibecode.crisis.ui.theme.CrisisColors

@Composable
fun SettingsButton(onClick: () -> Unit) {
    Box(
        modifier = Modifier
            .background(CrisisColors.surface, shape = RoundedCornerShape(10.dp))
            .clickable { onClick() }
            .padding(8.dp)
    ) {
        Icon(imageVector = Icons.Default.Settings, contentDescription = null, tint = CrisisColors.textPrimary)
    }
}
