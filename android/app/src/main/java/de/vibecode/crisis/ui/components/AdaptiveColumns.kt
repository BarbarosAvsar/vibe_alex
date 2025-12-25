package de.vibecode.crisis.ui.components

import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.width
import androidx.compose.material3.windowsizeclass.WindowSizeClass
import androidx.compose.material3.windowsizeclass.WindowWidthSizeClass
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp

@Composable
fun AdaptiveColumns(
    windowSizeClass: WindowSizeClass,
    first: @Composable () -> Unit,
    second: @Composable () -> Unit
) {
    if (windowSizeClass.widthSizeClass == WindowWidthSizeClass.Expanded) {
        Row {
            Column(modifier = Modifier.weight(1f)) {
                first()
            }
            Spacer(modifier = Modifier.width(24.dp))
            Column(modifier = Modifier.weight(1f)) {
                second()
            }
        }
    } else {
        Column {
            first()
            Spacer(modifier = Modifier.height(24.dp))
            second()
        }
    }
}
