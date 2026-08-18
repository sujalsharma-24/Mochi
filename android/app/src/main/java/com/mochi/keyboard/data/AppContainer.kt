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
    val wallpaperRepository: WallpaperRepository = WallpaperRepository(firestore)
    val wallpaperLibraryRepository: WallpaperLibraryRepository = WallpaperLibraryRepository(context)
    val likeRepository: LikeRepository = LikeRepository(firestore)
    val followRepository: FollowRepository = FollowRepository(firestore)
    val blockRepository: BlockRepository = BlockRepository(firestore)
    val reportRepository: ReportRepository = ReportRepository(firestore)
    val createRepository: CreateRepository = CreateRepository(firestore)
    val storageRepository: StorageRepository = StorageRepository(storage)
    val settingsRepository: SettingsRepository = SettingsRepository(context)
    val searchHistoryRepository: SearchHistoryRepository = SearchHistoryRepository(context)
    val billingRepository: BillingRepository = BillingRepository(context).apply {
        configure(appUserId = auth.currentUser?.uid)
    }
}
