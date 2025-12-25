package de.vibecode.crisis.ui.components

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.BoxScope
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.Surface
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.blur
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.dp
import de.vibecode.crisis.ui.theme.CrisisColors

@Composable
fun LiquidGlassBackground(content: @Composable BoxScope.() -> Unit) {
    Box(modifier = Modifier.fillMaxSize()) {
        Box(
            modifier = Modifier
                .fillMaxSize()
                .background(
                    Brush.linearGradient(
                        colors = listOf(
                            CrisisColors.background.copy(alpha = 0.98f),
                            CrisisColors.background.copy(alpha = 0.92f),
                            CrisisColors.background.copy(alpha = 0.88f)
                        )
                    )
                )
        )
        Box(
            modifier = Modifier
                .fillMaxSize()
                .background(
                    Brush.radialGradient(
                        colors = listOf(CrisisColors.accentInfo.copy(alpha = 0.18f), Color.Transparent),
                        radius = 520f
                    )
                )
                .blur(90.dp)
        )
        Box(
            modifier = Modifier
                .fillMaxSize()
                .background(
                    Brush.radialGradient(
                        colors = listOf(CrisisColors.accentStrong.copy(alpha = 0.22f), Color.Transparent),
                        radius = 640f
                    )
                )
                .blur(110.dp)
        )
        Box(
            modifier = Modifier
                .fillMaxSize()
                .background(
                    Brush.radialGradient(
                        colors = listOf(CrisisColors.accent.copy(alpha = 0.16f), Color.Transparent),
                        radius = 720f
                    )
                )
                .blur(120.dp)
        )
        content()
    }
}

@Composable
fun GlassCard(
    modifier: Modifier = Modifier,
    content: @Composable BoxScope.() -> Unit
) {
    Surface(
        modifier = modifier
            .clip(RoundedCornerShape(24.dp)),
        color = CrisisColors.surface,
        shadowElevation = 12.dp
    ) {
        Box(
            modifier = Modifier
                .background(
                    Brush.linearGradient(
                        colors = listOf(
                            Color.White.copy(alpha = 0.16f),
                            Color.White.copy(alpha = 0.04f)
                        )
                    )
                )
                .background(
                    Brush.linearGradient(
                        colors = listOf(
                            CrisisColors.accent.copy(alpha = 0.12f),
                            CrisisColors.accentInfo.copy(alpha = 0.08f)
                        )
                    )
                )
                .padding(20.dp)
        ) {
            content()
        }
    }
}
