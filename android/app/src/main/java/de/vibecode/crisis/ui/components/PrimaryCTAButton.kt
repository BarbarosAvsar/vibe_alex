package de.vibecode.crisis.ui.components

import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.ArrowForward
import androidx.compose.material.icons.filled.Send
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.unit.dp
import de.vibecode.crisis.ui.theme.CrisisColors

@Composable
fun PrimaryCTAButton(
    title: String,
    subtitle: String,
    onClick: () -> Unit
) {
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .background(
                brush = Brush.linearGradient(
                    colors = listOf(CrisisColors.accentStrong, CrisisColors.accentStrong.copy(alpha = 0.92f))
                ),
                shape = RoundedCornerShape(20.dp)
            )
            .clickable { onClick() }
            .padding(16.dp),
        verticalAlignment = Alignment.CenterVertically,
        horizontalArrangement = Arrangement.SpaceBetween
    ) {
        Row(verticalAlignment = Alignment.CenterVertically) {
            Icon(
                imageVector = Icons.Default.Send,
                contentDescription = null,
                tint = CrisisColors.textOnAccent,
                modifier = Modifier
                    .size(36.dp)
                    .background(CrisisColors.surface, shape = RoundedCornerShape(12.dp))
                    .padding(8.dp)
            )
            Spacer(modifier = Modifier.size(12.dp))
            Column {
                Text(text = title, style = MaterialTheme.typography.titleMedium, color = CrisisColors.textOnAccent)
                Text(text = subtitle, style = MaterialTheme.typography.bodySmall, color = CrisisColors.textOnAccent.copy(alpha = 0.8f))
            }
        }
        Icon(
            imageVector = Icons.Default.ArrowForward,
            contentDescription = null,
            tint = CrisisColors.textOnAccent.copy(alpha = 0.8f)
        )
    }
}
