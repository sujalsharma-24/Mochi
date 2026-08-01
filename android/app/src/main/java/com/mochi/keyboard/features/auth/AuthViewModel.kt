package com.mochi.keyboard.features.auth

import android.app.Activity
import androidx.credentials.exceptions.GetCredentialCancellationException
import androidx.credentials.exceptions.NoCredentialException
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.google.firebase.auth.FirebaseAuthInvalidCredentialsException
import com.google.firebase.auth.FirebaseAuthInvalidUserException
import com.google.firebase.auth.FirebaseAuthUserCollisionException
import com.google.firebase.auth.FirebaseAuthWeakPasswordException
import com.mochi.keyboard.data.AuthRepository
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch

data class AuthUiState(
    val isLoading: Boolean = false,
    val errorMessage: String? = null,
    val resetEmailSent: Boolean = false,
    // null = show the phone-number field; non-null = a code was sent, show the OTP-entry field.
    val phoneVerificationId: String? = null
)

class AuthViewModel(private val authRepository: AuthRepository) : ViewModel() {

    private val _uiState = MutableStateFlow(AuthUiState())
    val uiState: StateFlow<AuthUiState> = _uiState.asStateFlow()

    fun signUp(email: String, password: String, onSuccess: () -> Unit) =
        runAuthAction(onSuccess) { authRepository.signUpWithEmail(email, password) }

    fun signIn(email: String, password: String, onSuccess: () -> Unit) =
        runAuthAction(onSuccess) { authRepository.signInWithEmail(email, password) }

    fun signInWithGoogle(activity: Activity, onSuccess: () -> Unit) =
        runAuthAction(onSuccess) { authRepository.signInWithGoogle(activity) }

    fun sendPhoneCode(phoneNumber: String, activity: Activity, onAutoVerifiedSuccess: () -> Unit) {
        _uiState.value = _uiState.value.copy(isLoading = true, errorMessage = null)
        authRepository.sendPhoneVerificationCode(
            phoneNumber = phoneNumber,
            activity = activity,
            onCodeSent = { verificationId ->
                _uiState.value = _uiState.value.copy(isLoading = false, phoneVerificationId = verificationId)
            },
            onAutoVerified = { credential ->
                // Rare fast-path: some devices auto-retrieve the SMS without the user typing a
                // code at all. Same runAuthAction pattern, just triggered from a callback instead
                // of a button tap.
                viewModelScope.launch {
                    runCatching { authRepository.signInWithPhoneCredential(credential) }
                        .onSuccess {
                            _uiState.value = _uiState.value.copy(isLoading = false)
                            onAutoVerifiedSuccess()
                        }
                        .onFailure { e ->
                            _uiState.value = _uiState.value.copy(isLoading = false, errorMessage = mapAuthError(e))
                        }
                }
            },
            onError = { e ->
                _uiState.value = _uiState.value.copy(isLoading = false, errorMessage = mapAuthError(e))
            }
        )
    }

    fun verifyPhoneCode(code: String, onSuccess: () -> Unit) {
        val verificationId = _uiState.value.phoneVerificationId ?: return
        val credential = authRepository.phoneCredential(verificationId, code)
        runAuthAction(onSuccess) { authRepository.signInWithPhoneCredential(credential) }
    }

    fun resetPhoneFlow() {
        _uiState.value = _uiState.value.copy(phoneVerificationId = null, errorMessage = null)
    }

    fun sendPasswordReset(email: String) {
        viewModelScope.launch {
            _uiState.value = _uiState.value.copy(isLoading = true, errorMessage = null)
            runCatching { authRepository.sendPasswordReset(email) }
                .onSuccess { _uiState.value = _uiState.value.copy(isLoading = false, resetEmailSent = true) }
                .onFailure { e -> _uiState.value = _uiState.value.copy(isLoading = false, errorMessage = mapAuthError(e)) }
        }
    }

    fun showNotice(message: String) {
        _uiState.value = _uiState.value.copy(errorMessage = message)
    }

    fun clearMessages() {
        _uiState.value = _uiState.value.copy(errorMessage = null, resetEmailSent = false)
    }

    private fun runAuthAction(onSuccess: () -> Unit, block: suspend () -> Unit) {
        viewModelScope.launch {
            _uiState.value = _uiState.value.copy(isLoading = true, errorMessage = null)
            runCatching { block() }
                .onSuccess {
                    _uiState.value = _uiState.value.copy(isLoading = false)
                    onSuccess()
                }
                .onFailure { e ->
                    _uiState.value = _uiState.value.copy(isLoading = false, errorMessage = mapAuthError(e))
                }
        }
    }

    private fun mapAuthError(e: Throwable): String = when (e) {
        is FirebaseAuthWeakPasswordException -> "Password is too weak - use at least 6 characters."
        is FirebaseAuthInvalidCredentialsException -> "That email or password doesn't look right."
        is FirebaseAuthUserCollisionException -> "An account with that email already exists."
        is FirebaseAuthInvalidUserException -> "No account found for that email."
        is GetCredentialCancellationException -> "Sign-in canceled."
        is NoCredentialException -> "No Google account found on this device."
        else -> e.message ?: "Something went wrong. Please try again."
    }
}
