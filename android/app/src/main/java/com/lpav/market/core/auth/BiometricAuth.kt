package com.lpav.market.core.auth

import android.app.Activity
import androidx.biometric.BiometricManager
import androidx.biometric.BiometricPrompt
import androidx.core.content.ContextCompat
import androidx.fragment.app.FragmentActivity
import kotlinx.coroutines.suspendCancellableCoroutine
import javax.inject.Inject
import javax.inject.Singleton
import kotlin.coroutines.resume

enum class BiometricStatus {
    SUCCESS, NOT_AVAILABLE, NOT_ENROLLED, ERROR, UNKNOWN
}

@Singleton
class BiometricAuth @Inject constructor() {

    fun canUseBiometrics(activity: Activity): BiometricStatus {
        return when (BiometricManager.from(activity).canAuthenticate(BiometricManager.Authenticators.BIOMETRIC_STRONG)) {
            BiometricManager.BIOMETRIC_SUCCESS -> BiometricStatus.SUCCESS
            BiometricManager.BIOMETRIC_ERROR_NO_HARDWARE -> BiometricStatus.NOT_AVAILABLE
            BiometricManager.BIOMETRIC_ERROR_HW_UNAVAILABLE -> BiometricStatus.NOT_AVAILABLE
            BiometricManager.BIOMETRIC_ERROR_NONE_ENROLLED -> BiometricStatus.NOT_ENROLLED
            else -> BiometricStatus.NOT_AVAILABLE
        }
    }

    suspend fun authenticate(
        activity: FragmentActivity,
        title: String = "Desbloquear LPAV",
        subtitle: String = "Usa tu huella para acceder"
    ): BiometricStatus = suspendCancellableCoroutine { continuation ->
        val executor = ContextCompat.getMainExecutor(activity)

        val promptInfo = BiometricPrompt.PromptInfo.Builder()
            .setTitle(title)
            .setSubtitle(subtitle)
            .setNegativeButtonText("Cancelar")
            .build()

        val biometricPrompt = BiometricPrompt(activity, executor, object : BiometricPrompt.AuthenticationCallback() {
            override fun onAuthenticationSucceeded(result: BiometricPrompt.AuthenticationResult) {
                if (continuation.isActive) continuation.resume(BiometricStatus.SUCCESS)
            }

            override fun onAuthenticationError(errorCode: Int, errString: CharSequence) {
                if (continuation.isActive) {
                    continuation.resume(
                        when (errorCode) {
                            BiometricPrompt.ERROR_NEGATIVE_BUTTON -> BiometricStatus.ERROR
                            else -> BiometricStatus.ERROR
                        }
                    )
                }
            }

            override fun onAuthenticationFailed() {
            }
        })

        biometricPrompt.authenticate(promptInfo)

        continuation.invokeOnCancellation {
            biometricPrompt.cancelAuthentication()
        }
    }
}
