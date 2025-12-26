package de.vibecode.crisis.ui.theme

import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Typography
import androidx.compose.material3.lightColorScheme
import androidx.compose.runtime.Composable
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.TextStyle
import androidx.compose.ui.text.font.Font
import androidx.compose.ui.text.font.FontFamily
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.sp
import de.vibecode.crisis.R

private val Warm = Color(0xFFC7E8E3)
private val WarmStrong = Warm
private val Cool = Color(0xFF0F1C3D)
private val BaseBackground = Color(0xFFE8B9C8)
private val SurfaceBase = Warm.copy(alpha = 0.35f)
private val TextBase = Cool

private val DisplayFont = FontFamily(
    Font(R.font.playfair_display_variable, FontWeight.Normal),
    Font(R.font.playfair_display_variable, FontWeight.SemiBold)
)

private val BodyFont = FontFamily(
    Font(R.font.manrope_variable, FontWeight.Normal),
    Font(R.font.manrope_variable, FontWeight.Medium),
    Font(R.font.manrope_variable, FontWeight.SemiBold)
)

private val CrisisTypography = Typography(
    displayLarge = TextStyle(fontFamily = DisplayFont, fontWeight = FontWeight.SemiBold, fontSize = 34.sp),
    displayMedium = TextStyle(fontFamily = DisplayFont, fontWeight = FontWeight.SemiBold, fontSize = 28.sp),
    titleLarge = TextStyle(fontFamily = DisplayFont, fontWeight = FontWeight.SemiBold, fontSize = 22.sp),
    titleMedium = TextStyle(fontFamily = DisplayFont, fontWeight = FontWeight.SemiBold, fontSize = 18.sp),
    bodyLarge = TextStyle(fontFamily = BodyFont, fontWeight = FontWeight.Normal, fontSize = 16.sp),
    bodyMedium = TextStyle(fontFamily = BodyFont, fontWeight = FontWeight.Normal, fontSize = 14.sp),
    bodySmall = TextStyle(fontFamily = BodyFont, fontWeight = FontWeight.Normal, fontSize = 12.sp),
    labelLarge = TextStyle(fontFamily = BodyFont, fontWeight = FontWeight.SemiBold, fontSize = 13.sp),
    labelMedium = TextStyle(fontFamily = BodyFont, fontWeight = FontWeight.Medium, fontSize = 12.sp)
)

object CrisisColors {
    val background = BaseBackground
    val surface = SurfaceBase
    val border = Cool.copy(alpha = 0.2f)

    val accent = Warm
    val accentStrong = WarmStrong.copy(alpha = 0.9f)
    val accentInfo = Warm

    val textPrimary = TextBase
    val textSecondary = TextBase.copy(alpha = 0.8f)
    val textMuted = Cool.copy(alpha = 0.6f)
    val textOnAccent = Cool
}

@Composable
fun CrisisTheme(content: @Composable () -> Unit) {
    val colors = lightColorScheme(
        primary = WarmStrong,
        secondary = Warm,
        tertiary = Warm,
        background = BaseBackground,
        surface = SurfaceBase,
        onPrimary = Cool,
        onSecondary = Cool,
        onBackground = TextBase,
        onSurface = TextBase
    )

    MaterialTheme(
        colorScheme = colors,
        typography = CrisisTypography,
        content = content
    )
}
