package com.lpav.market.core.model

import kotlinx.serialization.Serializable

@Serializable
data class TransactionOrder(
    val orderId: String = "",
    val tenantId: String? = null,
    val userId: String = "",
    val totalAmount: Double = 0.0,
    val remainingBalance: Double = 0.0,
    val currency: String = "USD",
    val platformCommissionFee: Double = 0.0,
    val paymentStatus: String = "pending",
    val fulfillmentStatus: String = "pending",
    val stripeSessionId: String? = null,
    val pointsUsed: Int = 0,
    val items: List<OrderItem> = emptyList(),
    val createdAt: String? = null,
    val updatedAt: String? = null,
    val travelerName: String? = null,
    val travelerEmail: String? = null
)

@Serializable
data class OrderItem(
    val packageId: String = "",
    val title: String = "",
    val quantity: Int = 1,
    val unitPrice: Double = 0.0,
    val urlThumbnail: String? = null
)
