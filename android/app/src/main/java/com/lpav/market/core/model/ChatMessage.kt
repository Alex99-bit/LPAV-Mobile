package com.lpav.market.core.model

import kotlinx.serialization.Serializable

@Serializable
data class ChatMessage(
    val messageId: String = "",
    val conversationId: String = "",
    val senderId: String = "",
    val senderName: String? = null,
    val senderAvatar: String? = null,
    val messageText: String = "",
    val isSystem: Boolean = false,
    val isAiGenerated: Boolean = false,
    val isCensored: Boolean = false,
    val attachments: List<String> = emptyList(),
    val createdAt: String? = null,
    val readAt: String? = null
)

@Serializable
data class Conversation(
    val conversationId: String = "",
    val leadId: String? = null,
    val travelerUserId: String = "",
    val assignedAgentId: String? = null,
    val status: String = "open",
    val lastMessage: String? = null,
    val lastMessageAt: String? = null,
    val unreadCount: Int = 0,
    val travelerName: String? = null,
    val travelerAvatar: String? = null,
    val createdAt: String? = null
)
