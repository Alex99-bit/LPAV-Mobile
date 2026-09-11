package com.lpav.market.core.model

import kotlinx.serialization.Serializable

@Serializable
data class TravelPackage(
    val packageId: String = "",
    val tenantId: String? = null,
    val title: String = "",
    val region: String = "",
    val price: Double = 0.0,
    val currency: String = "USD",
    val description: String? = null,
    val itinerary: String? = null,
    val urlFlyerStorage: String? = null,
    val urlThumbnailStorage: String? = null,
    val hasCoordinator: Boolean = false,
    val publicationStatus: String = "borrador",
    val departureDate: String? = null,
    val returnDate: String? = null,
    val maxTravelers: Int = 0,
    val availableSlots: Int = 0,
    val rating: Double = 0.0,
    val reviewCount: Int = 0,
    val tags: List<String> = emptyList(),
    val includesList: List<String> = emptyList(),
    val excludesList: List<String> = emptyList(),
    val createdAt: String? = null,
    val updatedAt: String? = null,
    val isInWishlist: Boolean = false,
    val isInCart: Boolean = false
)
