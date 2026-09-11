package com.lpav.market.ui.components

import androidx.compose.material3.MaterialTheme
import androidx.compose.runtime.Composable
import androidx.compose.ui.graphics.Color
import com.lpav.market.ui.theme.Amber500
import com.lpav.market.ui.theme.Blue500
import com.lpav.market.ui.theme.Emerald500
import com.lpav.market.ui.theme.Red500
import com.lpav.market.ui.theme.Slate400

@Composable
fun StatusBadge(status: String) {
    val (bg, text) = when (status.lowercase()) {
        "nuevo", "new" -> Blue500 to Color.White
        "en_progreso", "in_progress", "abierto", "open" -> Amber500 to Color.White
        "calificado", "qualified", "publicado", "published" -> Emerald500 to Color.White
        "cerrado", "closed", "perdido", "lost", "cancelado", "cancelled" -> Red500 to Color.White
        "pendiente", "pending" -> Slate400 to Color.White
        "borrador", "draft" -> Slate400 to Color.White
        else -> MaterialTheme.colorScheme.outline to MaterialTheme.colorScheme.onSurface
    }

    LpavBadge(
        text = status.replace("_", " ").replaceFirstChar { it.uppercase() },
        backgroundColor = bg,
        contentColor = text
    )
}
