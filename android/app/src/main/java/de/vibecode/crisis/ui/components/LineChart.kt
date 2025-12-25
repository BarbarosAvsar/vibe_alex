package de.vibecode.crisis.ui.components

import androidx.compose.foundation.Canvas
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.Path
import androidx.compose.ui.graphics.StrokeCap
import androidx.compose.ui.graphics.StrokeJoin
import androidx.compose.ui.graphics.drawscope.Stroke
import androidx.compose.ui.unit.dp

@Composable
fun LineChart(
    series: List<LineSeries>,
    modifier: Modifier = Modifier,
    showTodayMarker: Boolean = false,
    todayX: Float? = null
) {
    if (series.isEmpty()) return

    val allPoints = series.flatMap { it.points }
    if (allPoints.isEmpty()) return

    val minX = allPoints.minOf { it.x }
    val maxX = allPoints.maxOf { it.x }
    val minY = allPoints.minOf { it.y }
    val maxY = allPoints.maxOf { it.y }

    Canvas(modifier = modifier.fillMaxWidth().height(260.dp)) {
        val width = size.width
        val height = size.height

        fun mapX(x: Float): Float {
            return if (maxX - minX == 0f) 0f else (x - minX) / (maxX - minX) * width
        }

        fun mapY(y: Float): Float {
            return if (maxY - minY == 0f) height / 2f else height - (y - minY) / (maxY - minY) * height
        }

        series.forEach { line ->
            if (line.points.size < 2) return@forEach
            val path = Path()
            line.points.forEachIndexed { index, point ->
                val offset = Offset(mapX(point.x), mapY(point.y))
                if (index == 0) {
                    path.moveTo(offset.x, offset.y)
                } else {
                    path.lineTo(offset.x, offset.y)
                }
            }

            if (line.fill) {
                val area = Path()
                line.points.forEachIndexed { index, point ->
                    val offset = Offset(mapX(point.x), mapY(point.y))
                    if (index == 0) {
                        area.moveTo(offset.x, height)
                        area.lineTo(offset.x, offset.y)
                    } else {
                        area.lineTo(offset.x, offset.y)
                    }
                }
                val last = line.points.last()
                area.lineTo(mapX(last.x), height)
                area.close()
                drawPath(area, color = line.color.copy(alpha = line.fillAlpha))
            }

            drawPath(
                path = path,
                color = line.color,
                style = Stroke(width = line.strokeWidth, cap = StrokeCap.Round, join = StrokeJoin.Round)
            )
        }

        if (showTodayMarker && todayX != null) {
            val x = mapX(todayX)
            drawLine(
                color = Color.White.copy(alpha = 0.45f),
                start = Offset(x, 0f),
                end = Offset(x, height),
                strokeWidth = 2f
            )
        }
    }
}

data class LineSeries(
    val points: List<ChartPoint>,
    val color: Color,
    val strokeWidth: Float = 4f,
    val fill: Boolean = false,
    val fillAlpha: Float = 0.18f
)

data class ChartPoint(val x: Float, val y: Float)
