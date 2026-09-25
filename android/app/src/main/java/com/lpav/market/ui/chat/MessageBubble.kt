package com.lpav.market.ui.chat

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.widthIn
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.font.FontStyle
import androidx.compose.ui.unit.dp
import com.lpav.market.core.model.ChatMessage
import com.lpav.market.ui.theme.Emerald50
import com.lpav.market.ui.theme.Emerald500
import com.lpav.market.ui.theme.Slate100
import com.lpav.market.ui.theme.Slate800

@Composable
fun MessageBubble(
    message: ChatMessage,
    isCurrentUser: Boolean
) {
    val alignment = if (isCurrentUser) Alignment.End else Alignment.Start
    val bubbleColor = if (isCurrentUser) Emerald500 else MaterialTheme.colorScheme.surfaceVariant
    val contentColor = if (isCurrentUser) androidx.compose.ui.graphics.Color.White
    else MaterialTheme.colorScheme.onSurfaceVariant
    val bubbleShape = if (isCurrentUser) {
        MaterialTheme.shapes.large.copy(
            bottomEnd = androidx.compose.foundation.shape.CornerSize(4.dp)
        )
    } else {
        MaterialTheme.shapes.large.copy(
            bottomStart = androidx.compose.foundation.shape.CornerSize(4.dp)
        )
    }

    Column(
        modifier = Modifier.fillMaxWidth(),
        horizontalAlignment = alignment
    ) {
        if (message.isSystem || message.isAiGenerated) {
            Surface(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(vertical = 4.dp),
                color = Emerald50
            ) {
                Text(
                    text = message.messageText,
                    style = MaterialTheme.typography.bodySmall,
                    fontStyle = FontStyle.Italic,
                    color = Emerald500,
                    modifier = Modifier.padding(12.dp)
                )
            }
        } else {
            Surface(
                shape = bubbleShape,
                color = bubbleColor,
                shadowElevation = 1.dp
            ) {
                Text(
                    text = message.messageText,
                    modifier = Modifier
                        .padding(12.dp)
                        .widthIn(max = 280.dp),
                    color = contentColor,
                    style = MaterialTheme.typography.bodyMedium
                )
            }
        }

        if (message.createdAt != null) {
            Text(
                text = formatChatTime(message.createdAt),
                style = MaterialTheme.typography.labelSmall,
                color = MaterialTheme.colorScheme.onSurfaceVariant.copy(alpha = 0.5f),
                modifier = Modifier.padding(
                    start = if (isCurrentUser) 0.dp else 12.dp,
                    end = if (isCurrentUser) 12.dp else 0.dp,
                    top = 2.dp
                )
            )
        }
    }
}

private fun formatChatTime(isoTimestamp: String?): String {
    if (isoTimestamp == null) return ""
    return try {
        val instant = java.time.Instant.parse(isoTimestamp)
        val localTime = java.time.LocalDateTime.ofInstant(instant, java.time.ZoneId.systemDefault())
        val formatter = java.time.format.DateTimeFormatter.ofPattern("HH:mm")
        localTime.format(formatter)
    } catch (e: Exception) {
        ""
    }
}
