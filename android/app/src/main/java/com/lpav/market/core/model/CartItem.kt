package com.lpav.market.core.model

import kotlinx.serialization.Serializable
import kotlinx.serialization.SerialName

@Serializable
data class CartItem(
    @SerialName("id") val id: String,
    @SerialName("user_id") val userId: String,
    @SerialName("package_id") val packageId: String,
    @SerialName("package_title") val packageTitle: String = "",
    @SerialName("package_image") val packageImage: String? = null,
    @SerialName("destination") val destination: String = "",
    @SerialName("quantity") val quantity: Int = 1,
    @SerialName("base_price") val basePrice: Double,
    @SerialName("travel_date") val travelDate: String = "",
    @SerialName("created_at") val createdAt: String = ""
)
