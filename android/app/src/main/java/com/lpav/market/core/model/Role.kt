package com.lpav.market.core.model

import kotlinx.serialization.Serializable

@Serializable
data class Role(
    val roleId: String = "",
    val tenantId: String = "",
    val roleName: String = "",
    val canManageCatalog: Boolean = false,
    val canViewGlobalLeads: Boolean = false,
    val canManageFinance: Boolean = false,
    val canManageChat: Boolean = false,
    val canManageLogistics: Boolean = false,
    val canManageSettings: Boolean = false,
    val canManageTeam: Boolean = false
)
