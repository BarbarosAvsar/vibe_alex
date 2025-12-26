package de.vibecode.crisis.ui.components

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.WifiOff
import androidx.compose.material3.Button
import androidx.compose.material3.CircularProgressIndicator
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.res.stringResource
import androidx.compose.ui.unit.dp
import de.vibecode.crisis.R
import de.vibecode.crisis.core.model.AsyncState
import de.vibecode.crisis.ui.theme.CrisisColors

@Composable
fun <T> AsyncStateView(
    state: AsyncState<T>,
    onRetry: () -> Unit,
    content: @Composable (T) -> Unit
) {
    when (state) {
        is AsyncState.Idle, is AsyncState.Loading -> {
            Column(
                modifier = Modifier.fillMaxWidth().padding(32.dp),
                verticalArrangement = Arrangement.Center,
                horizontalAlignment = Alignment.CenterHorizontally
            ) {
                CircularProgressIndicator(color = CrisisColors.accent)
                Text(text = stringResource(R.string.async_loading), style = MaterialTheme.typography.bodyMedium)
            }
        }
        is AsyncState.Failed -> {
            Column(
                modifier = Modifier.fillMaxWidth().padding(32.dp),
                verticalArrangement = Arrangement.spacedBy(12.dp),
                horizontalAlignment = Alignment.CenterHorizontally
            ) {
                Icon(imageVector = Icons.Default.WifiOff, contentDescription = null, tint = CrisisColors.accentStrong)
                Text(text = state.message, style = MaterialTheme.typography.bodyMedium)
                Button(onClick = onRetry) {
                    Text(text = stringResource(R.string.async_retry))
                }
            }
        }
        is AsyncState.Loaded -> content(state.value)
    }
}
