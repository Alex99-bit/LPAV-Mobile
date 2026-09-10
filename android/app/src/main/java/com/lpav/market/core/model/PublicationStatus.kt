package com.lpav.market.core.model

import kotlinx.serialization.Serializable
import kotlinx.serialization.SerialName

@Serializable
enum class PublicationStatus {
    @SerialName("draft")
    DRAFT,
    @SerialName("pending")
    PENDING,
    @SerialName("active")
    ACTIVE,
    @SerialName("inactive")
    INACTIVE,
    @SerialName("rejected")
    REJECTED
}
