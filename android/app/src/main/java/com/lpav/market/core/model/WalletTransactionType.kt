package com.lpav.market.core.model

import kotlinx.serialization.Serializable
import kotlinx.serialization.SerialName

@Serializable
enum class WalletTransactionType {
    @SerialName("points_earned")
    POINTS_EARNED,
    @SerialName("points_redeemed")
    POINTS_REDEEMED,
    @SerialName("refund")
    REFUND,
    @SerialName("deposit_payment")
    DEPOSIT_PAYMENT,
    @SerialName("full_payment")
    FULL_PAYMENT
}
