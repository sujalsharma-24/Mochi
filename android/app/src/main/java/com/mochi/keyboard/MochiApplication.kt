package com.mochi.keyboard

import android.app.Application
import com.google.firebase.Firebase
import com.google.firebase.appcheck.appCheck
import com.google.firebase.appcheck.debug.DebugAppCheckProviderFactory
import com.google.firebase.appcheck.playintegrity.PlayIntegrityAppCheckProviderFactory
import com.google.firebase.auth.FirebaseAuth
import com.google.firebase.firestore.FirebaseFirestore
import com.google.firebase.firestore.FirebaseFirestoreSettings
import com.google.firebase.firestore.MemoryCacheSettings
import com.google.firebase.functions.FirebaseFunctions
import com.google.firebase.storage.FirebaseStorage
import com.mochi.keyboard.data.AppContainer

/**
 * The real Firebase project now exists (android/app/google-services.json, project "mochi-940bd")
 * - the google-services Gradle plugin auto-initializes the default FirebaseApp from it via a
 * ContentProvider before this runs, so no manual FirebaseOptions/initializeApp call is needed
 * (that was only for the "demo-" emulator-only project used before this file existed).
 *
 * USE_LOCAL_EMULATOR still routes Auth/Firestore to the Firebase Local Emulator Suite for
 * day-to-day dev, so test accounts and seed data don't land in the real project. Flip to false to
 * test against the live cloud project directly. Host is 127.0.0.1, not 10.0.2.2: the primary test
 * device for this project is a physical phone reached via `adb reverse` (see android/README.md),
 * not an AVD emulator.
 */
class MochiApplication : Application() {

    lateinit var container: AppContainer
        private set

    override fun onCreate() {
        super.onCreate()

        // Every build on this project so far is a debug-signed sideload (gradlew installDebug via
        // adb, see android/README.md) - Play Integrity attestation fails for those (it expects a
        // Play-Store-signed/distributed install), so Debug is the only provider that actually works
        // today. Flip to false once real release-signed builds go through Play Store testing tracks.
        Firebase.appCheck.installAppCheckProviderFactory(
            if (USE_DEBUG_APP_CHECK) {
                DebugAppCheckProviderFactory.getInstance()
            } else {
                PlayIntegrityAppCheckProviderFactory.getInstance()
            }
        )

        val auth = FirebaseAuth.getInstance()
        val firestore = FirebaseFirestore.getInstance()
        val functions = FirebaseFunctions.getInstance()
        val storage = FirebaseStorage.getInstance()

        if (USE_LOCAL_EMULATOR) {
            auth.useEmulator(EMULATOR_HOST, AUTH_EMULATOR_PORT)
            firestore.firestoreSettings = FirebaseFirestoreSettings.Builder()
                .setHost("$EMULATOR_HOST:$FIRESTORE_EMULATOR_PORT")
                .setSslEnabled(false)
                .setLocalCacheSettings(MemoryCacheSettings.newBuilder().build())
                .build()
            functions.useEmulator(EMULATOR_HOST, FUNCTIONS_EMULATOR_PORT)
            storage.useEmulator(EMULATOR_HOST, STORAGE_EMULATOR_PORT)
        }

        container = AppContainer(context = this, auth = auth, firestore = firestore, functions = functions, storage = storage)
    }

    private companion object {
        const val USE_LOCAL_EMULATOR = true
        const val EMULATOR_HOST = "127.0.0.1"
        const val AUTH_EMULATOR_PORT = 9099
        const val FIRESTORE_EMULATOR_PORT = 8080
        const val FUNCTIONS_EMULATOR_PORT = 5001
        const val STORAGE_EMULATOR_PORT = 9199
        const val USE_DEBUG_APP_CHECK = true
    }
}
