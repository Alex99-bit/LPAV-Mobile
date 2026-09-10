package com.lpav.market.ui.wallet

import android.app.Application
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.lpav.market.core.model.UserWallet
import com.lpav.market.core.model.WalletTransaction
import com.lpav.market.core.network.SupabaseModule
import io.github.jan.supabase.gotrue.auth
import io.github.jan.supabase.postgrest.from
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch
import javax.inject.Inject

data class WalletUiState(
    val wallet: UserWallet? = null,
    val transactions: List<WalletTransaction> = emptyList(),
    val isLoading: Boolean = false,
    val errorMessage: String? = null
)

@HiltViewModel
class WalletViewModel @Inject constructor() : ViewModel() {

    private val _uiState = MutableStateFlow(WalletUiState())
    val uiState: StateFlow<WalletUiState> = _uiState.asStateFlow()

    init {
        loadWallet()
    }

    fun loadWallet() {
        viewModelScope.launch {
            _uiState.value = _uiState.value.copy(isLoading = true, errorMessage = null)
            try {
                val userId = SupabaseModule.client.auth.currentUserOrNull()?.id ?: return@launch

                val wallets = SupabaseModule.client.from("user_wallets")
                    .select { filter { eq("user_id", userId) } }
                    .decodeList<UserWallet>()

                if (wallets.isNotEmpty()) {
                    val wallet = wallets.first()
                    val transactions = SupabaseModule.client.from("wallet_transactions")
                        .select {
                            filter { eq("wallet_id", wallet.id) }
                            order("created_at", io.github.jan.supabase.postgrest.query.Order.DESCENDING)
                        }
                        .decodeList<WalletTransaction>()

                    _uiState.value = _uiState.value.copy(
                        wallet = wallet,
                        transactions = transactions,
                        isLoading = false
                    )
                } else {
                    _uiState.value = _uiState.value.copy(isLoading = false)
                }
            } catch (e: Exception) {
                _uiState.value = _uiState.value.copy(
                    isLoading = false,
                    errorMessage = "Error al cargar billetera: ${e.message}"
                )
            }
        }
    }
}
