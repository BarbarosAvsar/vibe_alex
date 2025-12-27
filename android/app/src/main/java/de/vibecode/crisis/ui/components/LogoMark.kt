package de.vibecode.crisis.ui.components

import androidx.compose.foundation.Image
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.size
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.unit.dp
import de.vibecode.crisis.R
import de.vibecode.crisis.ui.theme.CrisisColors

@Composable
fun LogoMark() {
    Row(
        verticalAlignment = Alignment.CenterVertically,
        horizontalArrangement = Arrangement.spacedBy(8.dp)
    ) {
        Image(
            painter = painterResource(id = R.drawable.ic_launcher_foreground),
            contentDescription = stringResource(R.string.logo_content_description),
            modifier = Modifier.size(24.dp)
        )
        Text(
            text = "CRISIS 2050",
            style = MaterialTheme.typography.titleMedium,
            color = CrisisColors.textPrimary
        )
    }
}
