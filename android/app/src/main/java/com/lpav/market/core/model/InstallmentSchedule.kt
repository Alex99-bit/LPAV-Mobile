package com.lpav.market.core.model

import kotlinx.serialization.Serializable
import kotlinx.serialization.SerialName

@Serializable
data class InstallmentSchedule(
    @SerialName("id") val id: String,
    @SerialName("order_id") val orderId: String,
    @SerialName("installment_number") val installmentNumber: Int,
    @SerialName("amount") val amount: Double,
    @SerialName("due_date") val dueDate: String,
    @SerialName("paid") val paid: Boolean = false,
    @SerialName("paid_at") val paidAt: String? = null,
    @SerialName("created_at") val createdAt: String = ""
)
