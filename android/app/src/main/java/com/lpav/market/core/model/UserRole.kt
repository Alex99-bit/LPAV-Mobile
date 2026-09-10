package com.lpav.market.core.model

import kotlinx.serialization.Serializable
import kotlinx.serialization.SerialName

@Serializable
enum class UserRole {
    @SerialName("traveler")
    TRAVELER,
    @SerialName("agency")
    AGENCY,
    @SerialName("admin")
    ADMIN
}
