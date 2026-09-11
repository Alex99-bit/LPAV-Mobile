package com.lpav.market.core.model

import kotlinx.serialization.Serializable

@Serializable
data class CRMLead(
    val leadId: String = "",
    val tenantId: String? = null,
    val travelerUserId: String? = null,
    val packageId: String? = null,
    val assignedTo: String? = null,
    val status: String = "nuevo",
    val source: String = "marketplace",
    val priority: String = "media",
    val estimatedBudget: Double? = null,
    val currency: String = "USD",
    val conversationId: String? = null,
    val notes: String? = null,
    val aiQualificationProgress: Int = 0,
    val aiQualificationCompleted: Boolean = false,
    val aiQualificationResult: String? = null,
    val travelerName: String? = null,
    val travelerEmail: String? = null,
    val createdAt: String? = null,
    val updatedAt: String? = null,
    val packageTitle: String? = null
)
