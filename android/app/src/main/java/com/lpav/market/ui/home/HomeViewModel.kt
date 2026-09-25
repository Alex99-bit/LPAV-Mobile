package com.lpav.market.ui.home

import android.app.Application
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.lpav.market.core.auth.AuthManager
import com.lpav.market.core.model.TravelPackage
import com.lpav.market.core.network.SupabaseModule
import dagger.hilt.android.lifecycle.HiltViewModel
import io.github.jan.supabase.postgrest.from
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch
import javax.inject.Inject

data class HomeUiState(
    val packages: List<TravelPackage> = emptyList(),
    val filteredPackages: List<TravelPackage> = emptyList(),
    val isLoading: Boolean = false,
    val errorMessage: String? = null,
    val searchQuery: String = "",
    val selectedCountry: String? = null,
    val minPrice: Double? = null,
    val maxPrice: Double? = null,
    val featuredOnly: Boolean = false
)

@HiltViewModel
class HomeViewModel @Inject constructor(
    private val authManager: AuthManager,
    application: Application
) : ViewModel() {

    private val _uiState = MutableStateFlow(HomeUiState())
    val uiState: StateFlow<HomeUiState> = _uiState.asStateFlow()

    init {
        loadPackages()
    }

    fun loadPackages() {
        viewModelScope.launch {
            _uiState.value = _uiState.value.copy(isLoading = true, errorMessage = null)
            try {
                val packages = SupabaseModule.client.from("travel_packages")
                    .select {
                        filter { eq("publication_status", "published") }
                    }
                    .decodeList<TravelPackage>()
                _uiState.value = _uiState.value.copy(
                    packages = packages,
                    isLoading = false
                )
                applyFilters()
            } catch (e: Exception) {
                _uiState.value = _uiState.value.copy(
                    isLoading = false,
                    errorMessage = "Error al cargar paquetes: ${e.message}"
                )
            }
        }
    }

    fun updateSearchQuery(query: String) {
        _uiState.value = _uiState.value.copy(searchQuery = query)
        applyFilters()
    }

    fun updateCountryFilter(country: String?) {
        _uiState.value = _uiState.value.copy(selectedCountry = country)
        applyFilters()
    }

    fun updatePriceRange(min: Double?, max: Double?) {
        _uiState.value = _uiState.value.copy(minPrice = min, maxPrice = max)
        applyFilters()
    }

    fun toggleFeaturedOnly() {
        _uiState.value = _uiState.value.copy(featuredOnly = !_uiState.value.featuredOnly)
        applyFilters()
    }

    fun clearFilters() {
        _uiState.value = _uiState.value.copy(
            searchQuery = "",
            selectedCountry = null,
            minPrice = null,
            maxPrice = null,
            featuredOnly = false
        )
        applyFilters()
    }

    private fun applyFilters() {
        val state = _uiState.value
        var filtered = state.packages.toList()

        if (state.searchQuery.isNotBlank()) {
            val query = state.searchQuery.lowercase()
            filtered = filtered.filter {
                it.title.lowercase().contains(query) ||
                    it.region.lowercase().contains(query) ||
                    (it.description?.lowercase()?.contains(query) == true)
            }
        }

        state.selectedCountry?.let { country ->
            filtered = filtered.filter { it.region.equals(country, ignoreCase = true) }
        }

        state.minPrice?.let { min ->
            filtered = filtered.filter { it.price >= min }
        }

        state.maxPrice?.let { max ->
            filtered = filtered.filter { it.price <= max }
        }

        if (state.featuredOnly) {
            filtered = filtered.filter { it.publicationStatus == "published" }
        }

        _uiState.value = _uiState.value.copy(filteredPackages = filtered)
    }

    fun logout() {
        viewModelScope.launch {
            authManager.signOut()
        }
    }
}
