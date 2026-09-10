package com.lpav.market.core.model

import kotlinx.serialization.Serializable
import kotlinx.serialization.SerialName

@Serializable
data class TransactionOrder(
    @SerialName("id") val id: String,
    @SerialName("user_id") val userId: String,
    @SerialName("package_id") val packageId: String,
    @SerialName("package_title") val packageTitle: String = "",
    @SerialName("agency_id") val agencyId: String = "",
    @SerialName("quantity") val quantity: Int = 1,
    @SerialName("base_price") val basePrice: Double,
    @SerialName("subtotal") val subtotal: Double,
    @SerialName("iva") val iva: Double,
    @SerialName("total") val total: Double,
    @SerialName("deposit_amount") val depositAmount: Double = 0.0,
    @SerialName("points_used") val pointsUsed: Int = 0,
    @SerialName("points_discount") val pointsDiscount: Double = 0.0,
    @SerialName("currency") val currency: Currency = Currency.USD,
    @SerialName("payment_status") val paymentStatus: PaymentStatus = PaymentStatus.PENDING,
    @SerialName("stripe_payment_intent_id") val stripePaymentIntentId: String? = null,
    @SerialName("travel_date") val travelDate: String = "",
    @SerialName("participants") val participants: Int = 1,
    @SerialName("notes") val notes: String = "",
    @SerialName("created_at") val createdAt: String = "",
    @SerialName("updated_at") val updatedAt: String = ""
)
