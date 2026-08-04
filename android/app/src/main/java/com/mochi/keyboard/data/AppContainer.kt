package com.mochi.keyboard.data

import android.content.Context
import com.google.firebase.auth.FirebaseAuth
import com.google.firebase.firestore.FirebaseFirestore
import com.google.firebase.functions.FirebaseFunctions
import com.google.firebase.storage.FirebaseStorage

/** Manual DI container — no framework (Hilt/Koin) yet; small enough app that it isn't worth the
 * setup ceremony today. Revisit if the repository count grows enough to make this wiring painful. */
class AppContainer(
    context: Context,
    auth: FirebaseAuth,
    firestore: FirebaseFirestore,
    functions: FirebaseFunctions,
    storage: FirebaseStorage = FirebaseStorage.getInstance()
) {
    val userRepository: UserRepository = UserRepository(firestore)
    val authRepository: AuthRepository = AuthRepository(auth, functions, userRepository)
    val themeRepository: ThemeRepository = ThemeRepository(firestore)
    val likeRepository: LikeRepository = LikeRepository(firestore)
    val followRepository: FollowRepository = FollowRepository(firestore)
    val createRepository: CreateRepository = CreateRepository(firestore)
    // Always the real Storage bucket, even when USE_LOCAL_EMULATOR routes Auth/Firestore to the
    // Local Emulator Suite - MochiApplication doesn't wire a Storage emulator connection (dev
    // workflow only starts Auth+Firestore emulators today), so uploads made during local dev land
    // in the live bucket. Fine for now (small dev-only files), but worth revisiting if that becomes
    // noisy - add `storage.useEmulator(...)` alongside the Auth/Firestore emulator setup then.
    val storageRepository: StorageRepository = StorageRepository(storage)
    val settingsRepository: SettingsRepository = SettingsRepository(context)
    val billingRepository: BillingRepository = BillingRepository(context).apply {
        configure(appUserId = auth.currentUser?.uid)
    }
}
