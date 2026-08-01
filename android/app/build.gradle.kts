plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
    id("org.jetbrains.kotlin.plugin.compose")
    id("com.google.gms.google-services")
}

android {
    // Internal source-code package (Kotlin `package` declarations, R class) - independent of
    // applicationId below, doesn't need to match the Firebase-registered package name.
    namespace = "com.mochi.keyboard"
    compileSdk = 35

    defaultConfig {
        // Must exactly match a package_name entry in google-services.json (currently
        // "com.Adam.Mochi" - a placeholder from whoever first registered the Firebase Android
        // app) or the google-services plugin fails the build with "No matching client found."
        applicationId = "com.Adam.Mochi"
        minSdk = 26
        targetSdk = 35
        versionCode = 1
        versionName = "1.0.0"
    }

    buildFeatures {
        compose = true
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = "17"
    }
}

dependencies {
    implementation(platform("androidx.compose:compose-bom:2024.10.01"))
    implementation("androidx.compose.ui:ui")
    implementation("androidx.compose.ui:ui-tooling-preview")
    implementation("androidx.compose.material3:material3")
    implementation("androidx.compose.material:material-icons-extended")
    implementation("androidx.activity:activity-compose:1.9.3")
    implementation("androidx.core:core-ktx:1.13.1")
    implementation("androidx.lifecycle:lifecycle-runtime-ktx:2.8.6")
    implementation("androidx.navigation:navigation-compose:2.8.4")

    // Foundation phase: Firebase Auth + Firestore, talking to the Local Emulator Suite (no real
    // Firebase project exists yet — see docs/project-memory/project_mochi_accounts.md). No
    // google-services plugin/json needed for emulator-only use; FirebaseApp is initialized by hand
    // in MochiApplication instead.
    implementation(platform("com.google.firebase:firebase-bom:33.7.0"))
    implementation("com.google.firebase:firebase-auth-ktx")
    implementation("com.google.firebase:firebase-firestore-ktx")
    implementation("org.jetbrains.kotlinx:kotlinx-coroutines-play-services:1.9.0")

    // Google Sign-In via Credential Manager (current recommended API, replaces the deprecated
    // GoogleSignInClient/GoogleSignInOptions family).
    implementation("androidx.credentials:credentials:1.3.0")
    implementation("androidx.credentials:credentials-play-services-auth:1.3.0")
    implementation("com.google.android.libraries.identity.googleid:googleid:1.1.1")

    // First ViewModel layer in the codebase (previously every screen was pure Composable state).
    implementation("androidx.lifecycle:lifecycle-viewmodel-compose:2.8.6")
    implementation("androidx.lifecycle:lifecycle-runtime-compose:2.8.6")

    debugImplementation("androidx.compose.ui:ui-tooling")
}
