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
    // null = show the phone-number field; non-null = the OTP was sent to this number via Twilio,
    // show the code-entry field (also doubles as "which number to verify against").
    val otpPhoneNumber: String? = null
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

    fun sendPhoneCode(phoneNumber: String) {
        viewModelScope.launch {
            _uiState.value = _uiState.value.copy(isLoading = true, errorMessage = null)
            runCatching { authRepository.sendPhoneOtp(phoneNumber) }
                .onSuccess {
                    _uiState.value = _uiState.value.copy(isLoading = false, otpPhoneNumber = phoneNumber)
                }
                .onFailure { e ->
                    _uiState.value = _uiState.value.copy(isLoading = false, errorMessage = mapAuthError(e))
                }
        }
    }

    fun verifyPhoneCode(code: String, onSuccess: () -> Unit) {
        val phoneNumber = _uiState.value.otpPhoneNumber ?: return
        runAuthAction(onSuccess) { authRepository.verifyPhoneOtp(phoneNumber, code) }
    }

    fun resetPhoneFlow() {
        _uiState.value = _uiState.value.copy(otpPhoneNumber = null, errorMessage = null)
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
        // FirebaseFunctionsException.message for the phone-OTP callables is already
        // display-ready text from the callable's own HttpsError (e.g. "That code is incorrect or
        // expired."), so it falls through to the same default as everything else.
        else -> e.message ?: "Something went wrong. Please try again."
    }
}
