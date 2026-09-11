package com.lpav.market.ui.theme

import android.app.Activity
import android.os.Build
import androidx.compose.foundation.isSystemInDarkTheme
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.darkColorScheme
import androidx.compose.material3.dynamicDarkColorScheme
import androidx.compose.material3.dynamicLightColorScheme
import androidx.compose.material3.lightColorScheme
import androidx.compose.runtime.Composable
import androidx.compose.runtime.SideEffect
import androidx.compose.ui.graphics.toArgb
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.platform.LocalView
import androidx.core.view.WindowCompat

private val LightColorScheme = lightColorScheme(
    primary = Emerald500,
    onPrimary = Slate50,
    primaryContainer = Emerald100,
    onPrimaryContainer = Emerald700,
    secondary = Blue700,
    onSecondary = Slate50,
    secondaryContainer = Blue100,
    onSecondaryContainer = Blue700,
    tertiary = Amber500,
    onTertiary = Slate50,
    background = Slate50,
    onBackground = Slate900,
    surface = Slate50,
    onSurface = Slate800,
    surfaceVariant = Slate100,
    onSurfaceVariant = Slate500,
    outline = Slate300,
    outlineVariant = Slate200,
    error = Red600,
    onError = Slate50,
    errorContainer = Color(0xFFFFDAD6),
    onErrorContainer = Color(0xFF93000A)
)

private val DarkColorScheme = darkColorScheme(
    primary = Emerald500,
    onPrimary = Slate900,
    primaryContainer = Emerald700,
    onPrimaryContainer = Emerald100,
    secondary = Blue500,
    onSecondary = Slate900,
    secondaryContainer = Blue700,
    onSecondaryContainer = Blue100,
    tertiary = Amber500,
    onTertiary = Slate900,
    background = DarkBackground,
    onBackground = Slate100,
    surface = DarkSurface,
    onSurface = Slate100,
    surfaceVariant = DarkSurfaceVariant,
    onSurfaceVariant = Slate400,
    outline = Slate600,
    outlineVariant = Slate700,
    error = Red500,
    onError = Slate900,
    errorContainer = Color(0xFF93000A),
    onErrorContainer = Color(0xFFFFDAD6)
)

@Composable
fun LpavTheme(
    darkTheme: Boolean = isSystemInDarkTheme(),
    dynamicColor: Boolean = true,
    content: @Composable () -> Unit
) {
    val colorScheme = when {
        dynamicColor && Build.VERSION.SDK_INT >= Build.VERSION_CODES.S -> {
            val context = LocalContext.current
            if (darkTheme) dynamicDarkColorScheme(context) else dynamicLightColorScheme(context)
        }
        darkTheme -> DarkColorScheme
        else -> LightColorScheme
    }

    val view = LocalView.current
    if (!view.isInEditMode) {
        SideEffect {
            val window = (view.context as Activity).window
            window.statusBarColor = colorScheme.primary.toArgb()
            WindowCompat.getInsetsController(window, view).isAppearanceLightStatusBars = !darkTheme
        }
    }

    MaterialTheme(
        colorScheme = colorScheme,
        typography = LpavTypography,
        shapes = LpavShapes,
        content = content
    )
}
