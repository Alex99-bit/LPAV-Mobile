package com.lpav.market.core.model

import kotlinx.serialization.Serializable
import kotlinx.serialization.SerialName

@Serializable
data class PackageReview(
    @SerialName("id") val id: String,
    @SerialName("package_id") val packageId: String,
    @SerialName("user_id") val userId: String,
    @SerialName("user_name") val userName: String = "",
    @SerialName("user_avatar_url") val userAvatarUrl: String? = null,
    @SerialName("rating") val rating: Int,
    @SerialName("comment") val comment: String = "",
    @SerialName("created_at") val createdAt: String = ""
)
