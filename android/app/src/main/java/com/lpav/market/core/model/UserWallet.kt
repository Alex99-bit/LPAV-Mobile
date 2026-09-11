package com.lpav.market.core.model

import kotlinx.serialization.Serializable

@Serializable
data class UserWallet(
    val walletId: String = "",
    val userId: String = "",
    val pointsBalance: Int = 0,
    val pointsEarned: Int = 0,
    val pointsSpent: Int = 0,
    val tier: String = "basic",
    val createdAt: String? = null,
    val updatedAt: String? = null
)
