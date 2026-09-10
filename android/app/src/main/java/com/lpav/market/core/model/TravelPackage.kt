package com.lpav.market.core.model

import kotlinx.serialization.Serializable
import kotlinx.serialization.SerialName

@Serializable
data class TravelPackage(
    @SerialName("id") val id: String,
    @SerialName("agency_id") val agencyId: String,
    @SerialName("title") val title: String,
    @SerialName("description") val description: String,
    @SerialName("destination") val destination: String,
    @SerialName("country") val country: String,
    @SerialName("duration_days") val durationDays: Int,
    @SerialName("duration_nights") val durationNights: Int,
    @SerialName("base_price") val basePrice: Double,
    @SerialName("currency") val currency: Currency = Currency.USD,
    @SerialName("discount_percent") val discountPercent: Double = 0.0,
    @SerialName("max_participants") val maxParticipants: Int,
    @SerialName("current_participants") val currentParticipants: Int = 0,
    @SerialName("inclusions") val inclusions: List<String> = emptyList(),
    @SerialName("exclusions") val exclusions: List<String> = emptyList(),
    @SerialName("itinerary") val itinerary: String = "[]",
    @SerialName("images") val images: List<String> = emptyList(),
    @SerialName("status") val status: PublicationStatus = PublicationStatus.ACTIVE,
    @SerialName("featured") val featured: Boolean = false,
    @SerialName("rating_avg") val ratingAvg: Double = 0.0,
    @SerialName("rating_count") val ratingCount: Int = 0,
    @SerialName("created_at") val createdAt: String = "",
    @SerialName("updated_at") val updatedAt: String = "",
    @SerialName("agency_name") val agencyName: String? = null,
    @SerialName("agency_avatar_url") val agencyAvatarUrl: String? = null
)
