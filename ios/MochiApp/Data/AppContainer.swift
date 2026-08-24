import FirebaseAuth
import FirebaseFirestore
import FirebaseFunctions
import FirebaseStorage

/// Manual DI container, same "no framework yet" call android/.../data/AppContainer.kt made —
/// `shared` is nil whenever `FirebaseEnvironment.configureIfPossible()` couldn't run (no
/// GoogleService-Info.plist in the bundle yet), so every screen that wants real data must check for
/// nil and fall back to its existing MockData presentation rather than force-unwrapping.
final class AppContainer {
    static let shared: AppContainer? = {
        guard FirebaseEnvironment.configureIfPossible() else { return nil }
        return AppContainer()
    }()

    let auth: Auth
    let firestore: Firestore
    let functions: Functions
    let storage: Storage

    let userRepository: UserRepository
    let authRepository: AuthRepository
    let themeRepository: ThemeRepository
    let likeRepository: LikeRepository
    let followRepository: FollowRepository
    let reportRepository: ReportRepository
    let createRepository: CreateRepository
    let storageRepository: StorageRepository

    private init() {
        auth = Auth.auth()
        firestore = Firestore.firestore()
        functions = Functions.functions()
        storage = Storage.storage()

        userRepository = UserRepository(firestore: firestore)
        authRepository = AuthRepository(auth: auth, functions: functions, userRepository: userRepository)
        themeRepository = ThemeRepository(firestore: firestore)
        likeRepository = LikeRepository(firestore: firestore)
        followRepository = FollowRepository(firestore: firestore)
        reportRepository = ReportRepository(firestore: firestore)
        createRepository = CreateRepository(firestore: firestore)
        storageRepository = StorageRepository(storage: storage)
    }
}
