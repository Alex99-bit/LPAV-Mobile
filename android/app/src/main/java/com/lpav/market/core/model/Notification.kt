package com.lpav.market.core.model

import kotlinx.serialization.Serializable

@Serializable
data class Notification(
    val notificationId: String = "",
    val userId: String = "",
    val type: String = "info",
    val title: String = "",
    val message: String = "",
    val metadata: Map<String, String> = emptyMap(),
    val read: Boolean = false,
    val createdAt: String? = null
)
