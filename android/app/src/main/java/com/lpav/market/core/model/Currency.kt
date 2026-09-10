package com.lpav.market.core.model

import kotlinx.serialization.Serializable
import kotlinx.serialization.SerialName

@Serializable
enum class Currency {
    @SerialName("USD")
    USD,
    @SerialName("VES")
    VES,
    @SerialName("EUR")
    EUR
}
