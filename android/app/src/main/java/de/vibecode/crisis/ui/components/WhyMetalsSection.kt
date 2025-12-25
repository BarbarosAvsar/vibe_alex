package de.vibecode.crisis.ui.components

import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.width
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.CheckCircle
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.unit.dp
import de.vibecode.crisis.R
import de.vibecode.crisis.ui.theme.CrisisColors

@Composable
fun WhyMetalsSection() {
    GlassCard {
        Column {
            Text(text = stringResource(R.string.why_metals_title), style = MaterialTheme.typography.titleMedium)
            Spacer(modifier = Modifier.height(12.dp))
            BulletItem(text = stringResource(R.string.why_metals_bullet_1))
            BulletItem(text = stringResource(R.string.why_metals_bullet_2))
            BulletItem(text = stringResource(R.string.why_metals_bullet_3))
            BulletItem(text = stringResource(R.string.why_metals_bullet_4))
            BulletItem(text = stringResource(R.string.why_metals_bullet_5))
        }
    }
}

@Composable
private fun BulletItem(text: String, icon: ImageVector = Icons.Default.CheckCircle) {
    Row {
        androidx.compose.material3.Icon(
            imageVector = icon,
            contentDescription = null,
            tint = CrisisColors.accent
        )
        Spacer(modifier = Modifier.width(8.dp))
        Text(text = text, style = MaterialTheme.typography.bodyMedium)
    }
    Spacer(modifier = Modifier.height(10.dp))
}
