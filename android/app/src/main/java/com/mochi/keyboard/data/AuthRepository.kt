package com.mochi.keyboard.data

import android.app.Activity
import androidx.credentials.CredentialManager
import androidx.credentials.GetCredentialRequest
import com.google.android.libraries.identity.googleid.GetGoogleIdOption
import com.google.android.libraries.identity.googleid.GoogleIdTokenCredential
import com.google.firebase.auth.AuthResult
import com.google.firebase.auth.FirebaseAuth
import com.google.firebase.auth.FirebaseUser
import com.google.firebase.auth.GoogleAuthProvider
import com.google.firebase.functions.FirebaseFunctions
import kotlinx.coroutines.channels.awaitClose
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.callbackFlow
import kotlinx.coroutines.tasks.await

class AuthRepository(
    private val auth: FirebaseAuth,
    private val functions: FirebaseFunctions,
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
     * the provider auto-creates it) - also appears as the "client_type": 3 entry in
     * google-services.json, alongside the "client_type": 1 entry that pairs this app's debug SHA-1
     * with the Google provider (also registered in Firebase Console).
     */
    private val googleWebClientId =
        "675511778611-8e648arujt5i1vuksg0087kdu8vqavj5.apps.googleusercontent.com"

    suspend fun signInWithGoogle(activity: Activity) {
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
     * Sends the OTP via the sendPhoneOtp callable, which generates the code and sends it as a
     * plain Twilio SMS server-side (not Twilio Verify - see functions/src/otp.ts for why) - no
     * Twilio credential is ever embedded in the client. Code expiry/attempt-limiting live in
     * Firestore's otpRequests collection, not on the client.
     */
    suspend fun sendPhoneOtp(phoneNumber: String) {
        functions.getHttpsCallable("sendPhoneOtp")
            .call(mapOf("phoneNumber" to phoneNumber))
            .await()
    }

    /**
     * verifyPhoneOtp checks the code against the hash stored in otpRequests, then mints a Firebase
     * custom token server-side (creating the Firebase Auth user on first use, same "sign-in and
     * sign-up are the same call" pattern as Google below) and returns it for
     * signInWithCustomToken - Twilio never talks to Firebase Auth directly, this callable is the
     * bridge. isNewUser comes from the callable itself since signInWithCustomToken's AuthResult
     * doesn't populate additionalUserInfo.isNewUser the way a normal client-side provider sign-in
     * does.
     */
    suspend fun verifyPhoneOtp(phoneNumber: String, code: String) {
        val result = functions.getHttpsCallable("verifyPhoneOtp")
            .call(mapOf("phoneNumber" to phoneNumber, "code" to code))
            .await()
        @Suppress("UNCHECKED_CAST")
        val data = result.getData() as Map<String, Any?>
        val token = data["token"] as String
        val isNewUser = data["isNewUser"] as? Boolean ?: false

        auth.signInWithCustomToken(token).await()
        if (isNewUser) {
            val uid = auth.currentUser?.uid ?: error("Sign-in succeeded but no user id was returned")
            userRepository.createUserProfile(uid)
        }
    }

    /**
     * Google sign-in and sign-up are the same call (Firebase creates the user on first use) -
     * unlike signUpWithEmail, a repeat login must NOT re-run createUserProfile, since that would
     * reset an existing user's counters back to 0 every time they sign in. Phone OTP has the same
     * isNewUser-gated shape but goes through verifyPhoneOtp above instead, since it doesn't have an
     * AuthResult to read additionalUserInfo from until after signInWithCustomToken succeeds.
     */
    private suspend fun createProfileIfNewUser(result: AuthResult) {
        if (result.additionalUserInfo?.isNewUser == true) {
            val uid = result.user?.uid ?: error("Sign-in succeeded but no user id was returned")
            userRepository.createUserProfile(uid)
        }
    }

    fun signOut() = auth.signOut()
}
