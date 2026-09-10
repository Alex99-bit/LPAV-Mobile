package com.lpav.market.core.model

import kotlinx.serialization.Serializable
import kotlinx.serialization.SerialName

@Serializable
data class WalletTransaction(
    @SerialName("id") val id: String,
    @SerialName("wallet_id") val walletId: String,
    @SerialName("order_id") val orderId: String? = null,
    @SerialName("type") val type: WalletTransactionType,
    @SerialName("amount") val amount: Double,
    @SerialName("points") val points: Int = 0,
    @SerialName("description") val description: String = "",
    @SerialName("created_at") val createdAt: String = ""
)
