package com.mochi.keyboard.data

import androidx.compose.runtime.Composable
import androidx.compose.ui.platform.LocalContext
import androidx.lifecycle.ViewModel
import androidx.lifecycle.ViewModelProvider
import androidx.lifecycle.viewmodel.CreationExtras
import com.mochi.keyboard.MochiApplication
import com.mochi.keyboard.features.auth.AuthViewModel
import com.mochi.keyboard.features.home.HomeViewModel

/** One factory for every ViewModel, since there's no DI framework wiring `@Inject` constructors —
 * add a branch here whenever a new screen gets a ViewModel. */
class ViewModelFactory(private val container: AppContainer) : ViewModelProvider.Factory {
    @Suppress("UNCHECKED_CAST")
    override fun <T : ViewModel> create(modelClass: Class<T>, extras: CreationExtras): T =
        when (modelClass) {
            HomeViewModel::class.java -> HomeViewModel(container.themeRepository) as T
            AuthViewModel::class.java -> AuthViewModel(container.authRepository) as T
            else -> throw IllegalArgumentException("Unknown ViewModel class: ${modelClass.name}")
        }
}

@Composable
fun rememberMochiViewModelFactory(): ViewModelFactory {
    val application = LocalContext.current.applicationContext as MochiApplication
    return ViewModelFactory(application.container)
}
