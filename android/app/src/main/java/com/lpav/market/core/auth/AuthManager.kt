package com.lpav.market.core.auth

import android.app.Activity
import com.google.gson.Gson
import com.lpav.market.core.model.Profile
import com.lpav.market.core.network.SupabaseModule
import io.github.jan.supabase.gotrue.auth
import io.github.jan.supabase.gotrue.providers.builtin.Email
import io.github.jan.supabase.postgrest.from
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.update
import javax.inject.Inject
import javax.inject.Singleton

@Singleton
class AuthManager @Inject constructor() {
    private val _currentUser = MutableStateFlow<io.github.jan.supabase.gotrue.user.UserInfo?>(null)
    val currentUser: StateFlow<io.github.jan.supabase.gotrue.user.UserInfo?> = _currentUser.asStateFlow()

    private val _profile = MutableStateFlow<Profile?>(null)
    val profile: StateFlow<Profile?> = _profile.asStateFlow()

    private val _isLoading = MutableStateFlow(false)
    val isLoading: StateFlow<Boolean> = _isLoading.asStateFlow()

    private val _errorMessage = MutableStateFlow<String?>(null)
    val errorMessage: StateFlow<String?> = _errorMessage.asStateFlow()

    private val gson = Gson()

    val isAgency: Boolean get() = _profile.value?.roleName == "agency"
    val isTraveler: Boolean get() = _profile.value?.roleName == "traveler"
    val isAdmin: Boolean get() = _profile.value?.roleName == "admin"
    val isLoggedIn: Boolean get() = _currentUser.value != null

    suspend fun signIn(email: String, password: String): Result<Unit> {
        _isLoading.value = true
        _errorMessage.value = null
        return try {
            SupabaseModule.client.auth.signInWith(Email) {
                this.email = email
                this.password = password
            }
            val user = SupabaseModule.client.auth.currentUserOrNull()
            _currentUser.value = user
            user?.let { fetchProfile() }
            Result.success(Unit)
        } catch (e: Exception) {
            _errorMessage.value = e.message ?: "Error al iniciar sesión"
            Result.failure(e)
        } finally {
            _isLoading.value = false
        }
    }

    suspend fun signUp(
        email: String,
        password: String,
        fullName: String,
        isAgency: Boolean
    ): Result<Unit> {
        _isLoading.value = true
        _errorMessage.value = null
        return try {
            SupabaseModule.client.auth.signUpWith(Email) {
                this.email = email
                this.password = password
            }
            val user = SupabaseModule.client.auth.currentUserOrNull()
            _currentUser.value = user
            user?.let {
                val profile = Profile(
                    id = it.id,
                    fullName = fullName,
                    email = email,
                    roleName = if (isAgency) "agency" else "traveler"
                )
                SupabaseModule.client.from("profiles").upsert(profile)
                _profile.value = profile
            }
            Result.success(Unit)
        } catch (e: Exception) {
            _errorMessage.value = e.message ?: "Error al registrarse"
            Result.failure(e)
        } finally {
            _isLoading.value = false
        }
    }

    suspend fun signInWithGoogle(activity: Activity): Result<Unit> {
        _isLoading.value = true
        _errorMessage.value = null
        return try {
            SupabaseModule.client.auth.signInWith(io.github.jan.supabase.gotrue.providers.Google)
            val user = SupabaseModule.client.auth.currentUserOrNull()
            _currentUser.value = user
            user?.let { fetchProfile() }
            Result.success(Unit)
        } catch (e: Exception) {
            _errorMessage.value = e.message ?: "Error al iniciar sesión con Google"
            Result.failure(e)
        } finally {
            _isLoading.value = false
        }
    }

    suspend fun signOut(): Result<Unit> {
        return try {
            SupabaseModule.client.auth.signOut()
            _currentUser.value = null
            _profile.value = null
            Result.success(Unit)
        } catch (e: Exception) {
            _errorMessage.value = e.message ?: "Error al cerrar sesión"
            Result.failure(e)
        }
    }

    suspend fun resetPassword(email: String): Result<Unit> {
        _isLoading.value = true
        _errorMessage.value = null
        return try {
            SupabaseModule.client.auth.resetPasswordForEmail(email)
            Result.success(Unit)
        } catch (e: Exception) {
            _errorMessage.value = e.message ?: "Error al restablecer contraseña"
            Result.failure(e)
        } finally {
            _isLoading.value = false
        }
    }

    suspend fun fetchProfile() {
        val userId = _currentUser.value?.id ?: return
        try {
            val result = SupabaseModule.client.from("profiles")
                .select { filter { eq("user_id", userId) } }
                .decodeList<Profile>()
            if (result.isNotEmpty()) {
                _profile.value = result.first()
            }
        } catch (e: Exception) {
            _errorMessage.value = "Error al cargar perfil"
        }
    }

    suspend fun updateProfile(profile: Profile): Result<Unit> {
        return try {
            SupabaseModule.client.from("profiles")
                .upsert(profile)
            _profile.value = profile
            Result.success(Unit)
        } catch (e: Exception) {
            _errorMessage.value = "Error al actualizar perfil"
            Result.failure(e)
        }
    }

    fun clearError() {
        _errorMessage.value = null
    }

    suspend fun restoreSession() {
        try {
            val session = SupabaseModule.client.auth.currentSessionOrNull()
            if (session != null) {
                val user = SupabaseModule.client.auth.currentUserOrNull()
                _currentUser.value = user
                user?.let { fetchProfile() }
            }
        } catch (_: Exception) {
            _currentUser.value = null
            _profile.value = null
        }
    }
}
