package com.lpav.market.ui.profile

import android.app.Application
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.lpav.market.core.model.AgencyTenant
import com.lpav.market.core.model.TravelPackage
import com.lpav.market.core.model.PackageReview
import com.lpav.market.core.network.SupabaseModule
import dagger.hilt.android.lifecycle.HiltViewModel
import io.github.jan.supabase.postgrest.from
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch
import javax.inject.Inject

data class AgencyProfileUiState(
    val agency: AgencyTenant? = null,
    val packages: List<TravelPackage> = emptyList(),
    val reviews: List<PackageReview> = emptyList(),
    val isLoading: Boolean = false,
    val errorMessage: String? = null
)

@HiltViewModel
class AgencyProfileViewModel @Inject constructor() : ViewModel() {

    private val _uiState = MutableStateFlow(AgencyProfileUiState())
    val uiState: StateFlow<AgencyProfileUiState> = _uiState.asStateFlow()

    fun loadAgency(agencyId: String) {
        viewModelScope.launch {
            _uiState.value = _uiState.value.copy(isLoading = true, errorMessage = null)
            try {
                val agencies = SupabaseModule.client.from("agency_tenants")
                    .select { filter { eq("id", agencyId) } }
                    .decodeList<AgencyTenant>()

                val agency = agencies.firstOrNull()

                val packages = SupabaseModule.client.from("travel_packages")
                    .select {
                        filter {
                            eq("agency_id", agencyId)
                            eq("status", "active")
                        }
                    }
                    .decodeList<TravelPackage>()

                _uiState.value = _uiState.value.copy(
                    agency = agency,
                    packages = packages,
                    isLoading = false
                )
            } catch (e: Exception) {
                _uiState.value = _uiState.value.copy(
                    isLoading = false,
                    errorMessage = "Error al cargar perfil: ${e.message}"
                )
            }
        }
    }
}
