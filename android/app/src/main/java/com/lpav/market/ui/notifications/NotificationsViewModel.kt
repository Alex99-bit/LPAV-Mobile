package com.lpav.market.ui.notifications

import android.app.Application
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.lpav.market.core.model.Notification
import com.lpav.market.core.network.SupabaseModule
import io.github.jan.supabase.gotrue.auth
import io.github.jan.supabase.postgrest.from
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch
import javax.inject.Inject

data class NotificationsUiState(
    val notifications: List<Notification> = emptyList(),
    val isLoading: Boolean = false,
    val errorMessage: String? = null
)

@HiltViewModel
class NotificationsViewModel @Inject constructor() : ViewModel() {

    private val _uiState = MutableStateFlow(NotificationsUiState())
    val uiState: StateFlow<NotificationsUiState> = _uiState.asStateFlow()

    init {
        loadNotifications()
    }

    fun loadNotifications() {
        viewModelScope.launch {
            _uiState.value = _uiState.value.copy(isLoading = true, errorMessage = null)
            try {
                val userId = SupabaseModule.client.auth.currentUserOrNull()?.id ?: return@launch
                val notifications = SupabaseModule.client.from("notifications")
                    .select {
                        filter { eq("user_id", userId) }
                        order("created_at", io.github.jan.supabase.postgrest.query.Order.DESCENDING)
                    }
                    .decodeList<Notification>()
                _uiState.value = _uiState.value.copy(notifications = notifications, isLoading = false)
            } catch (e: Exception) {
                _uiState.value = _uiState.value.copy(
                    isLoading = false,
                    errorMessage = "Error al cargar notificaciones"
                )
            }
        }
    }

    fun markAsRead(notificationId: String) {
        viewModelScope.launch {
            try {
                SupabaseModule.client.from("notifications")
                    .update(mapOf("read" to true)) {
                        filter { eq("id", notificationId) }
                    }
                loadNotifications()
            } catch (_: Exception) {}
        }
    }

    fun markAllAsRead() {
        viewModelScope.launch {
            try {
                val userId = SupabaseModule.client.auth.currentUserOrNull()?.id ?: return@launch
                SupabaseModule.client.from("notifications")
                    .update(mapOf("read" to true)) {
                        filter {
                            eq("user_id", userId)
                            eq("read", false)
                        }
                    }
                loadNotifications()
            } catch (_: Exception) {}
        }
    }
}
