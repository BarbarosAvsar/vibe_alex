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

private val Warm = Color(0xFFE3B66A)
private val WarmStrong = Color(0xFFC6903A)
private val Cool = Color(0xFF86B7C6)
private val BaseBackground = Color(0xFFF9F3F7)
private val SurfaceBase = Color(0xFFF7F5F8)
private val TextBase = Color(0xFF2E2A2E)

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
    val surface = SurfaceBase.copy(alpha = 0.72f)
    val border = TextBase.copy(alpha = 0.12f)

    val accent = Warm
    val accentStrong = WarmStrong
    val accentInfo = Cool

    val textPrimary = TextBase
    val textSecondary = TextBase.copy(alpha = 0.8f)
    val textMuted = TextBase.copy(alpha = 0.6f)
    val textOnAccent = TextBase
}

@Composable
fun CrisisTheme(content: @Composable () -> Unit) {
    val colors = lightColorScheme(
        primary = WarmStrong,
        secondary = Warm,
        tertiary = Cool,
        background = BaseBackground,
        surface = SurfaceBase,
        onPrimary = TextBase,
        onSecondary = TextBase,
        onBackground = TextBase,
        onSurface = TextBase
    )

    MaterialTheme(
        colorScheme = colors,
        typography = CrisisTypography,
        content = content
    )
}
