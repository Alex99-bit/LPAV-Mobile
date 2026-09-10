package com.lpav.market.core.model

import kotlinx.serialization.Serializable
import kotlinx.serialization.SerialName

@Serializable
data class ChatMessage(
    @SerialName("id") val id: String,
    @SerialName("conversation_id") val conversationId: String,
    @SerialName("sender_id") val senderId: String,
    @SerialName("sender_name") val senderName: String = "",
    @SerialName("sender_avatar_url") val senderAvatarUrl: String? = null,
    @SerialName("content") val content: String,
    @SerialName("message_type") val messageType: ChatMessageType = ChatMessageType.TEXT,
    @SerialName("read") val read: Boolean = false,
    @SerialName("created_at") val createdAt: String = "",
    @SerialName("updated_at") val updatedAt: String = ""
)
