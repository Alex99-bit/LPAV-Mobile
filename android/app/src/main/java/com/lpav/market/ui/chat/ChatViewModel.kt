package com.lpav.market.ui.chat

import android.app.Application
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.lpav.market.core.model.ChatMessage
import com.lpav.market.core.model.ChatMessageType
import com.lpav.market.core.network.SupabaseModule
import io.github.jan.supabase.gotrue.auth
import io.github.jan.supabase.postgrest.from
import io.github.jan.supabase.realtime.channel
import io.github.jan.supabase.realtime.postgresListDataFlow
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch
import java.util.UUID
import javax.inject.Inject

data class ChatUiState(
    val messages: List<ChatMessage> = emptyList(),
    val isLoading: Boolean = false,
    val errorMessage: String? = null,
    val inputText: String = ""
)

@HiltViewModel
class ChatViewModel @Inject constructor() : ViewModel() {

    private val _uiState = MutableStateFlow(ChatUiState())
    val uiState: StateFlow<ChatUiState> = _uiState.asStateFlow()

    private var conversationId: String = ""

    fun initConversation(id: String) {
        conversationId = id
        loadMessages()
        subscribeToMessages()
    }

    private fun loadMessages() {
        viewModelScope.launch {
            _uiState.value = _uiState.value.copy(isLoading = true)
            try {
                val messages = SupabaseModule.client.from("chat_messages")
                    .select {
                        filter { eq("conversation_id", conversationId) }
                        order("created_at", io.github.jan.supabase.postgrest.query.Order.ASCENDING)
                    }
                    .decodeList<ChatMessage>()
                _uiState.value = _uiState.value.copy(messages = messages, isLoading = false)
            } catch (e: Exception) {
                _uiState.value = _uiState.value.copy(
                    isLoading = false,
                    errorMessage = "Error al cargar mensajes"
                )
            }
        }
    }

    private fun subscribeToMessages() {
        viewModelScope.launch {
            try {
                val channel = SupabaseModule.client.channel("chat:$conversationId")
                val messageFlow = channel.postgresListDataFlow("chat_messages") {
                    filter {
                        eq("conversation_id", conversationId)
                    }
                }
                channel.subscribe()
                messageFlow.collect { messages ->
                    _uiState.value = _uiState.value.copy(messages = messages)
                }
            } catch (_: Exception) {}
        }
    }

    fun updateInput(text: String) {
        _uiState.value = _uiState.value.copy(inputText = text)
    }

    fun getCurrentUserId(): String {
        return SupabaseModule.client.auth.currentUserOrNull()?.id ?: ""
    }

    fun sendMessage() {
        val text = _uiState.value.inputText.trim()
        if (text.isEmpty()) return

        viewModelScope.launch {
            try {
                val userId = SupabaseModule.client.auth.currentUserOrNull()?.id ?: return@launch
                val message = ChatMessage(
                    id = UUID.randomUUID().toString(),
                    conversationId = conversationId,
                    senderId = userId,
                    content = text,
                    messageType = ChatMessageType.TEXT
                )
                SupabaseModule.client.from("chat_messages").insert(message)
                _uiState.value = _uiState.value.copy(inputText = "")
            } catch (e: Exception) {
                _uiState.value = _uiState.value.copy(
                    errorMessage = "Error al enviar mensaje"
                )
            }
        }
    }
}
