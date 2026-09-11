package com.lpav.market.core.model

import kotlinx.serialization.Serializable

@Serializable
data class OnboardingProfile(
    val userId: String = "",
    val clusterInterestsHash: String? = null,
    val interestsTags: List<String> = emptyList(),
    val preferredDestinations: List<String> = emptyList(),
    val targetBudgetRange: String? = null,
    val travelStyle: String? = null,
    val tripDuration: String? = null,
    val travelersCount: Int = 1,
    val specialRequirements: List<String> = emptyList()
)
