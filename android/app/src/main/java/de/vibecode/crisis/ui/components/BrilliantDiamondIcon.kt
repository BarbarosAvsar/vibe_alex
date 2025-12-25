package de.vibecode.crisis.ui.components

import androidx.compose.foundation.Canvas
import androidx.compose.foundation.layout.size
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.graphics.Path
import androidx.compose.ui.graphics.StrokeCap
import androidx.compose.ui.graphics.drawscope.Stroke
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp
import de.vibecode.crisis.ui.theme.CrisisColors

@Composable
fun BrilliantDiamondIcon(size: Dp) {
    Canvas(modifier = Modifier.size(size)) {
        val s = size.minDimension
        val top = Offset(s * 0.5f, s * 0.06f)
        val leftTop = Offset(s * 0.18f, s * 0.32f)
        val rightTop = Offset(s * 0.82f, s * 0.32f)
        val left = Offset(s * 0.06f, s * 0.36f)
        val right = Offset(s * 0.94f, s * 0.36f)
        val bottom = Offset(s * 0.5f, s * 0.96f)
        val mid = Offset(s * 0.5f, s * 0.6f)

        val outline = Path().apply {
            moveTo(top.x, top.y)
            lineTo(leftTop.x, leftTop.y)
            lineTo(left.x, left.y)
            lineTo(bottom.x, bottom.y)
            lineTo(right.x, right.y)
            lineTo(rightTop.x, rightTop.y)
            close()
        }

        drawPath(outline, color = CrisisColors.accent)
        drawPath(outline, color = CrisisColors.accentInfo, style = Stroke(width = 1.2f))

        val facets = Path().apply {
            moveTo(top.x, top.y)
            lineTo(mid.x, mid.y)
            moveTo(left.x, left.y)
            lineTo(mid.x, mid.y)
            lineTo(right.x, right.y)
            moveTo(leftTop.x, leftTop.y)
            lineTo(Offset(s * 0.5f, s * 0.34f).x, Offset(s * 0.5f, s * 0.34f).y)
            lineTo(rightTop.x, rightTop.y)
        }
        drawPath(facets, color = androidx.compose.ui.graphics.Color.White.copy(alpha = 0.55f), style = Stroke(width = 1f, cap = StrokeCap.Round))
    }
}
