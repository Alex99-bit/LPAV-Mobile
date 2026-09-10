package com.lpav.market.core.model

import kotlinx.serialization.Serializable
import kotlinx.serialization.SerialName

@Serializable
data class Notification(
    @SerialName("id") val id: String,
    @SerialName("user_id") val userId: String,
    @SerialName("title") val title: String,
    @SerialName("message") val message: String,
    @SerialName("type") val type: NotificationType = NotificationType.SYSTEM,
    @SerialName("read") val read: Boolean = false,
    @SerialName("data") val data: String? = null,
    @SerialName("created_at") val createdAt: String = ""
)
