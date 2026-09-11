package com.lpav.market.core.model

import kotlinx.serialization.Serializable

@Serializable
data class Profile(
    val id: String = "",
    val tenantId: String? = null,
    val roleName: String = "traveler",
    val fullName: String = "",
    val email: String = "",
    val avatarUrl: String? = null,
    val phone: String? = null,
    val preferredLanguage: String = "es",
    val preferredCurrency: String = "USD",
    val isOnboardingCompleted: Boolean = false,
    val isVerified: Boolean = false,
    val createdAt: String? = null
)
