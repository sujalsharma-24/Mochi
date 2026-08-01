package com.mochi.keyboard.data

import com.google.firebase.auth.FirebaseAuth
import com.google.firebase.firestore.FirebaseFirestore

/** Manual DI container — no framework (Hilt/Koin) yet; small enough app that it isn't worth the
 * setup ceremony today. Revisit if the repository count grows enough to make this wiring painful. */
class AppContainer(auth: FirebaseAuth, firestore: FirebaseFirestore) {
    val userRepository: UserRepository = UserRepository(firestore)
    val authRepository: AuthRepository = AuthRepository(auth, userRepository)
    val themeRepository: ThemeRepository = ThemeRepository(firestore)
}
