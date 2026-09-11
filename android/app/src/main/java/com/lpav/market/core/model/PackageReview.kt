package com.lpav.market.core.model

import kotlinx.serialization.Serializable

@Serializable
data class PackageReview(
    val reviewId: String = "",
    val packageId: String = "",
    val userId: String = "",
    val rating: Int = 0,
    val comment: String? = null,
    val reviewerName: String? = null,
    val reviewerAvatar: String? = null,
    val createdAt: String? = null
)
