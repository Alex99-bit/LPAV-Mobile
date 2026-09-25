package com.lpav.market.ui.packagedetail

import android.app.Application
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.lpav.market.core.model.TravelPackage
import com.lpav.market.core.model.CartItem
import com.lpav.market.core.network.SupabaseModule
import com.lpav.market.core.storage.CartStorage
import com.google.gson.Gson
import com.google.gson.reflect.TypeToken
import dagger.hilt.android.lifecycle.HiltViewModel
import io.github.jan.supabase.postgrest.from
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch
import java.util.UUID
import javax.inject.Inject

data class ItineraryItem(
    val day: Int,
    val title: String,
    val description: String,
    val activities: List<String>
)

data class PackageDetailUiState(
    val travelPackage: TravelPackage? = null,
    val itinerary: List<ItineraryItem> = emptyList(),
    val isLoading: Boolean = false,
    val errorMessage: String? = null,
    val addedToCart: Boolean = false,
    val quantity: Int = 1
)

@HiltViewModel
class PackageDetailViewModel @Inject constructor(
    private val cartStorage: CartStorage
) : ViewModel() {

    private val _uiState = MutableStateFlow(PackageDetailUiState())
    val uiState: StateFlow<PackageDetailUiState> = _uiState.asStateFlow()

    private val gson = Gson()

    fun loadPackage(packageId: String) {
        viewModelScope.launch {
            _uiState.value = _uiState.value.copy(isLoading = true, errorMessage = null)
            try {
                val pkg = SupabaseModule.client.from("travel_packages")
                    .select { filter { eq("package_id", packageId) } }
                    .decodeList<TravelPackage>()
                    .firstOrNull()

                val itinerary = parseItinerary(pkg?.itinerary ?: "[]")

                _uiState.value = _uiState.value.copy(
                    travelPackage = pkg,
                    itinerary = itinerary,
                    isLoading = false
                )
            } catch (e: Exception) {
                _uiState.value = _uiState.value.copy(
                    isLoading = false,
                    errorMessage = "Error al cargar paquete: ${e.message}"
                )
            }
        }
    }

    fun updateQuantity(quantity: Int) {
        if (quantity >= 1) {
            _uiState.value = _uiState.value.copy(quantity = quantity)
        }
    }

    fun addToCart() {
        val pkg = _uiState.value.travelPackage ?: return
        viewModelScope.launch {
            try {
                val item = CartItem(
                    id = UUID.randomUUID().toString(),
                    userId = "",
                    packageId = pkg.packageId,
                    packageTitle = pkg.title,
                    packageImage = pkg.urlThumbnailStorage,
                    destination = pkg.region,
                    quantity = _uiState.value.quantity,
                    basePrice = pkg.price
                )
                cartStorage.addToCart(item)
                _uiState.value = _uiState.value.copy(addedToCart = true)
            } catch (e: Exception) {
                _uiState.value = _uiState.value.copy(
                    errorMessage = "Error al agregar al carrito"
                )
            }
        }
    }

    private fun parseItinerary(json: String): List<ItineraryItem> {
        return try {
            val type = object : TypeToken<List<ItineraryItem>>() {}.type
            gson.fromJson(json, type) ?: emptyList()
        } catch (_: Exception) {
            emptyList()
        }
    }
}
