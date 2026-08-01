package com.mochi.keyboard.data

import android.app.Activity
import androidx.credentials.CredentialManager
import androidx.credentials.GetCredentialRequest
import com.google.android.libraries.identity.googleid.GetGoogleIdOption
import com.google.android.libraries.identity.googleid.GoogleIdTokenCredential
import com.google.firebase.FirebaseException
import com.google.firebase.auth.AuthResult
import com.google.firebase.auth.FirebaseAuth
import com.google.firebase.auth.FirebaseUser
import com.google.firebase.auth.GoogleAuthProvider
import com.google.firebase.auth.PhoneAuthCredential
import com.google.firebase.auth.PhoneAuthOptions
import com.google.firebase.auth.PhoneAuthProvider
import kotlinx.coroutines.channels.awaitClose
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.callbackFlow
import kotlinx.coroutines.tasks.await
import java.util.concurrent.TimeUnit

class AuthRepository(
    private val auth: FirebaseAuth,
    private val userRepository: UserRepository
) {

    val currentUser: FirebaseUser? get() = auth.currentUser

    val authState: Flow<FirebaseUser?> = callbackFlow {
        val listener = FirebaseAuth.AuthStateListener { trySend(it.currentUser) }
        auth.addAuthStateListener(listener)
        awaitClose { auth.removeAuthStateListener(listener) }
    }

    suspend fun signUpWithEmail(email: String, password: String) {
        val result = auth.createUserWithEmailAndPassword(email, password).await()
        val uid = result.user?.uid ?: error("Sign-up succeeded but no user id was returned")
        userRepository.createUserProfile(uid)
    }

    suspend fun signInWithEmail(email: String, password: String) {
        auth.signInWithEmailAndPassword(email, password).await()
    }

    suspend fun sendPasswordReset(email: String) {
        auth.sendPasswordResetEmail(email).await()
    }

    /**
     * Web Client ID from Firebase Console -> Authentication -> Sign-in method -> Google (enabling
     * the provider auto-creates it) - also appears as a "client_type": 3 entry in a re-downloaded
     * google-services.json. Currently a placeholder because oauth_client is empty in the checked-in
     * file (Google provider not enabled yet); signInWithGoogle() fails fast with a clear message
     * instead of a raw SDK exception until this is replaced with the real value.
     */
    private val googleWebClientId = "REPLACE_WITH_FIREBASE_WEB_CLIENT_ID"

    suspend fun signInWithGoogle(activity: Activity) {
        check(googleWebClientId != "REPLACE_WITH_FIREBASE_WEB_CLIENT_ID") {
            "Google Sign-In isn't configured yet - enable the Google provider in Firebase Console " +
                "and paste the Web Client ID into AuthRepository.googleWebClientId."
        }

        val googleIdOption = GetGoogleIdOption.Builder()
            .setFilterByAuthorizedAccounts(false)
            .setServerClientId(googleWebClientId)
            .build()
        val request = GetCredentialRequest.Builder()
            .addCredentialOption(googleIdOption)
            .build()

        val credentialManager = CredentialManager.create(activity)
        val response = credentialManager.getCredential(activity, request)
        val googleIdTokenCredential = GoogleIdTokenCredential.createFrom(response.credential.data)
        val firebaseCredential = GoogleAuthProvider.getCredential(googleIdTokenCredential.idToken, null)

        val result = auth.signInWithCredential(firebaseCredential).await()
        createProfileIfNewUser(result)
    }

    /**
     * Two-step phone flow: this starts verification and reports back via callbacks (Firebase's own
     * API shape, not a suspend function - onCodeSent is the common path, onVerificationCompleted
     * only fires on devices that can auto-retrieve the SMS without the user typing anything).
     * Against the Firebase Auth Emulator this all works with no real SMS or billing plan.
     */
    fun sendPhoneVerificationCode(
        phoneNumber: String,
        activity: Activity,
        onCodeSent: (String) -> Unit,
        onAutoVerified: (PhoneAuthCredential) -> Unit,
        onError: (Exception) -> Unit
    ) {
        val options = PhoneAuthOptions.newBuilder(auth)
            .setPhoneNumber(phoneNumber)
            .setTimeout(60L, TimeUnit.SECONDS)
            .setActivity(activity)
            .setCallbacks(object : PhoneAuthProvider.OnVerificationStateChangedCallbacks() {
                override fun onVerificationCompleted(credential: PhoneAuthCredential) {
                    onAutoVerified(credential)
                }

                override fun onVerificationFailed(e: FirebaseException) {
                    onError(e)
                }

                override fun onCodeSent(verificationId: String, token: PhoneAuthProvider.ForceResendingToken) {
                    onCodeSent(verificationId)
                }
            })
            .build()
        PhoneAuthProvider.verifyPhoneNumber(options)
    }

    fun phoneCredential(verificationId: String, code: String): PhoneAuthCredential =
        PhoneAuthProvider.getCredential(verificationId, code)

    suspend fun signInWithPhoneCredential(credential: PhoneAuthCredential) {
        val result = auth.signInWithCredential(credential).await()
        createProfileIfNewUser(result)
    }

    /**
     * Google/Phone sign-in and sign-up are the same call (Firebase creates the user on first use) -
     * unlike signUpWithEmail, a repeat login must NOT re-run createUserProfile, since that would
     * reset an existing user's counters back to 0 every time they sign in.
     */
    private suspend fun createProfileIfNewUser(result: AuthResult) {
        if (result.additionalUserInfo?.isNewUser == true) {
            val uid = result.user?.uid ?: error("Sign-in succeeded but no user id was returned")
            userRepository.createUserProfile(uid)
        }
    }

    fun signOut() = auth.signOut()
}
