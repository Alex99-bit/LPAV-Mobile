package com.lpav.market.ui.cart

import android.app.Application
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.lpav.market.core.model.CartItem
import com.lpav.market.core.storage.CartStorage
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch
import javax.inject.Inject

data class CartUiState(
    val items: List<CartItem> = emptyList(),
    val subtotal: Double = 0.0,
    val iva: Double = 0.0,
    val total: Double = 0.0,
    val isLoading: Boolean = false,
    val errorMessage: String? = null
)

@HiltViewModel
class CartViewModel @Inject constructor(
    private val cartStorage: CartStorage
) : ViewModel() {

    private val _uiState = MutableStateFlow(CartUiState())
    val uiState: StateFlow<CartUiState> = _uiState.asStateFlow()

    init {
        loadCart()
    }

    fun loadCart() {
        viewModelScope.launch {
            _uiState.value = _uiState.value.copy(isLoading = true)
            try {
                val items = cartStorage.getCartItems()
                calculateTotals(items)
                _uiState.value = _uiState.value.copy(items = items, isLoading = false)
            } catch (e: Exception) {
                _uiState.value = _uiState.value.copy(
                    isLoading = false,
                    errorMessage = "Error al cargar carrito"
                )
            }
        }
    }

    fun updateQuantity(packageId: String, quantity: Int) {
        viewModelScope.launch {
            cartStorage.updateQuantity(packageId, quantity)
            loadCart()
        }
    }

    fun removeItem(packageId: String) {
        viewModelScope.launch {
            cartStorage.removeFromCart(packageId)
            loadCart()
        }
    }

    fun clearCart() {
        viewModelScope.launch {
            cartStorage.clearCart()
            _uiState.value = CartUiState()
        }
    }

    private fun calculateTotals(items: List<CartItem>) {
        val subtotal = items.sumOf { it.basePrice * it.quantity }
        val iva = subtotal * 0.16
        val total = subtotal + iva
        _uiState.value = _uiState.value.copy(
            subtotal = subtotal,
            iva = iva,
            total = total
        )
    }
}
