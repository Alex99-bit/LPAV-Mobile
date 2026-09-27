package com.lpav.market.ui.checkout

import android.app.Application
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.lpav.market.core.model.CartItem
import com.lpav.market.core.model.TransactionOrder
import com.lpav.market.core.network.SupabaseModule
import com.lpav.market.core.storage.CartStorage
import com.lpav.market.util.Constants
import dagger.hilt.android.lifecycle.HiltViewModel
import io.github.jan.supabase.functions.functions
import io.github.jan.supabase.gotrue.auth
import io.github.jan.supabase.postgrest.from
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch
import javax.inject.Inject

data class CheckoutUiState(
    val items: List<CartItem> = emptyList(),
    val subtotal: Double = 0.0,
    val iva: Double = 0.0,
    val total: Double = 0.0,
    val depositAmount: Double = 0.0,
    val payFull: Boolean = true,
    val travelDate: String = "",
    val notes: String = "",
    val isLoading: Boolean = false,
    val isProcessing: Boolean = false,
    val errorMessage: String? = null,
    val success: Boolean = false,
    val clientSecret: String? = null
)

@HiltViewModel
class CheckoutViewModel @Inject constructor(
    private val cartStorage: CartStorage
) : ViewModel() {

    private val _uiState = MutableStateFlow(CheckoutUiState())
    val uiState: StateFlow<CheckoutUiState> = _uiState.asStateFlow()

    init {
        loadCheckoutData()
    }

    private fun loadCheckoutData() {
        viewModelScope.launch {
            _uiState.value = _uiState.value.copy(isLoading = true)
            try {
                val items = cartStorage.getCartItems()
                val subtotal = items.sumOf { it.basePrice * it.quantity }
                val iva = subtotal * Constants.IVA_RATE
                val total = subtotal + iva

                _uiState.value = _uiState.value.copy(
                    items = items,
                    subtotal = subtotal,
                    iva = iva,
                    total = total,
                    depositAmount = total * Constants.DEPOSIT_RATIO,
                    isLoading = false
                )
            } catch (e: Exception) {
                _uiState.value = _uiState.value.copy(
                    isLoading = false,
                    errorMessage = "Error al cargar datos de pago"
                )
            }
        }
    }

    fun togglePayFull() {
        val newPayFull = !_uiState.value.payFull
        val total = _uiState.value.subtotal + _uiState.value.iva
        _uiState.value = _uiState.value.copy(
            payFull = newPayFull,
            depositAmount = if (newPayFull) total else total * Constants.DEPOSIT_RATIO
        )
    }

    fun updateTravelDate(date: String) {
        _uiState.value = _uiState.value.copy(travelDate = date)
    }

    fun updateNotes(notes: String) {
        _uiState.value = _uiState.value.copy(notes = notes)
    }

    fun processCheckout(stripePaymentMethodId: String? = null) {
        if (_uiState.value.items.isEmpty()) {
            _uiState.value = _uiState.value.copy(errorMessage = "El carrito está vacío")
            return
        }

        viewModelScope.launch {
            _uiState.value = _uiState.value.copy(isProcessing = true, errorMessage = null)
            try {
                val userId = SupabaseModule.client.auth.currentUserOrNull()?.id
                    ?: throw Exception("No autenticado")

                val orderItems = _uiState.value.items.map { cartItem ->
                    com.lpav.market.core.model.OrderItem(
                        packageId = cartItem.packageId,
                        title = cartItem.packageTitle,
                        quantity = cartItem.quantity,
                        unitPrice = cartItem.basePrice,
                        urlThumbnail = cartItem.packageImage
                    )
                }

                val order = TransactionOrder(
                    orderId = "",
                    userId = userId,
                    totalAmount = _uiState.value.subtotal + _uiState.value.iva,
                    remainingBalance = _uiState.value.depositAmount,
                    items = orderItems,
                    paymentStatus = "pending",
                    fulfillmentStatus = "pending"
                )

                SupabaseModule.client.functions.invoke("create-checkout")

                cartStorage.clearCart()
                _uiState.value = _uiState.value.copy(
                    isProcessing = false,
                    success = true
                )
            } catch (e: Exception) {
                _uiState.value = _uiState.value.copy(
                    isProcessing = false,
                    errorMessage = "Error al procesar pago: ${e.message}"
                )
            }
        }
    }

    fun clearError() {
        _uiState.value = _uiState.value.copy(errorMessage = null)
    }
}
