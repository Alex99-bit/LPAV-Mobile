package com.lpav.market.core.model

import kotlinx.serialization.Serializable
import kotlinx.serialization.SerialName

@Serializable
data class UserWallet(
    @SerialName("id") val id: String,
    @SerialName("user_id") val userId: String,
    @SerialName("points_balance") val pointsBalance: Int = 0,
    @SerialName("currency") val currency: Currency = Currency.USD,
    @SerialName("created_at") val createdAt: String = "",
    @SerialName("updated_at") val updatedAt: String = ""
)
