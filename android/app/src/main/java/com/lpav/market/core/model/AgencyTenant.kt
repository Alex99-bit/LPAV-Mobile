package com.lpav.market.core.model

import kotlinx.serialization.Serializable

@Serializable
data class AgencyTenant(
    val tenantId: String = "",
    val tenantName: String = "",
    val slug: String = "",
    val logoUrl: String? = null,
    val bannerUrl: String? = null,
    val description: String? = null,
    val website: String? = null,
    val email: String? = null,
    val phone: String? = null,
    val subscriptionTier: String = "free",
    val subscriptionStatus: String = "active",
    val verified: Boolean = false,
    val rating: Double = 0.0,
    val totalPackages: Int = 0,
    val createdBy: String? = null,
    val createdAt: String? = null
)
