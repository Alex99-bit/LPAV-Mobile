package com.lpav.market.core.model

import kotlinx.serialization.Serializable
import kotlinx.serialization.SerialName

@Serializable
enum class PaymentStatus {
    @SerialName("pending")
    PENDING,
    @SerialName("deposit_paid")
    DEPOSIT_PAID,
    @SerialName("paid")
    PAID,
    @SerialName("partially_refunded")
    PARTIALLY_REFUNDED,
    @SerialName("refunded")
    REFUNDED,
    @SerialName("cancelled")
    CANCELLED,
    @SerialName("installment")
    INSTALLMENT
}
