package com.lpav.market.core.model

import kotlinx.serialization.Serializable
import kotlinx.serialization.SerialName

@Serializable
data class AgencyTenant(
    @SerialName("id") val id: String,
    @SerialName("user_id") val userId: String,
    @SerialName("agency_name") val agencyName: String,
    @SerialName("description") val description: String = "",
    @SerialName("logo_url") val logoUrl: String? = null,
    @SerialName("banner_url") val bannerUrl: String? = null,
    @SerialName("phone") val phone: String = "",
    @SerialName("email") val email: String = "",
    @SerialName("website") val website: String = "",
    @SerialName("address") val address: String = "",
    @SerialName("rating_avg") val ratingAvg: Double = 0.0,
    @SerialName("rating_count") val ratingCount: Int = 0,
    @SerialName("plan") val plan: PlanType = PlanType.FREE,
    @SerialName("verified") val verified: Boolean = false,
    @SerialName("created_at") val createdAt: String = ""
)
