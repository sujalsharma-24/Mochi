plugins {
    id("com.android.application") version "8.6.1" apply false
    id("org.jetbrains.kotlin.android") version "2.0.21" apply false
    id("org.jetbrains.kotlin.plugin.compose") version "2.0.21" apply false
    // Reads android/app/google-services.json (the real Firebase project) and validates its
    // package_name entries against applicationId at build time.
    id("com.google.gms.google-services") version "4.4.2" apply false
}
