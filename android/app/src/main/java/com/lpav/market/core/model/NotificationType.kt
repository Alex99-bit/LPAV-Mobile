package com.lpav.market.core.model

import kotlinx.serialization.Serializable
import kotlinx.serialization.SerialName

@Serializable
enum class NotificationType {
    @SerialName("order_update")
    ORDER_UPDATE,
    @SerialName("payment_update")
    PAYMENT_UPDATE,
    @SerialName("chat_message")
    CHAT_MESSAGE,
    @SerialName("promotion")
    PROMOTION,
    @SerialName("system")
    SYSTEM
}
