package com.lpav.market.core.model

import kotlinx.serialization.Serializable
import kotlinx.serialization.SerialName

@Serializable
enum class PlanType {
    @SerialName("free")
    FREE,
    @SerialName("basic")
    BASIC,
    @SerialName("premium")
    PREMIUM
}
