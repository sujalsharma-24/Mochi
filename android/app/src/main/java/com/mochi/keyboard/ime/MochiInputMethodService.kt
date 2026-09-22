package com.mochi.keyboard.ime

import android.inputmethodservice.InputMethodService
import android.media.AudioManager
import android.view.HapticFeedbackConstants
import android.view.Gravity
import android.view.View
import android.view.ViewGroup
import android.view.inputmethod.EditorInfo
import android.view.inputmethod.InputMethodManager
import android.widget.FrameLayout
import com.mochi.keyboard.data.AppliedThemeRepository
import com.mochi.keyboard.data.FontStyleRepository
import com.mochi.keyboard.data.RenderableTheme
import com.mochi.keyboard.data.SettingsRepository
import com.mochi.keyboard.ime.render.BuiltInThemes
import com.mochi.keyboard.ime.render.FontStyleCatalog
import com.mochi.keyboard.ime.render.InputConnectionTextDocument
import com.mochi.keyboard.ime.render.KeyboardInputEngine
import com.mochi.keyboard.ime.render.KeyboardSurfaceView
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.SupervisorJob
import kotlinx.coroutines.cancel
import kotlinx.coroutines.flow.launchIn
import kotlinx.coroutines.flow.onEach

/**
 * The live keyboard, now driven by the token-based renderer under `ime/render/` — ported from
 * iOS's `MochiKeyboardTheme` + `KeyboardSurfaceView` system (see `docs/keyboard-theme-system.md`)
 * so Android's built-in themes carry real background art, per-key illustrations, contrast-tuned
 * key styles, and the same typing behaviour (3-state shift, double-space period, long-press
 * accents), instead of one hand-coded flat-color look.
 *
 * The older ad-hoc [KeyboardVisualTheme] system (including the uncommitted "Bubble Tea" nine-slice
 * theme) is left untouched in its own files — not deleted, just no longer the live rendering path —
 * so that work isn't lost while a decision on folding it into this system is still open.
 *
 * Not wired up yet, tracked as follow-up slices: real predictive suggestions and the emoji plane.
 */
class MochiInputMethodService : InputMethodService() {

    private var theme = BuiltInThemes.default
    private lateinit var inputEngine: KeyboardInputEngine
    private lateinit var surface: KeyboardSurfaceView
    private var currentEditorInfo: EditorInfo? = null

    /** Same DataStore SettingsRepository the Settings screen writes to - the IME runs in the same
     * process as the app, so a plain read here sees the same store, no cross-process bridge needed. */
    private val settingsRepository by lazy { SettingsRepository(applicationContext) }
    private val fontStyleRepository by lazy { FontStyleRepository(applicationContext) }
    private val appliedThemeRepository by lazy { AppliedThemeRepository(applicationContext) }
    private val audioManager by lazy { getSystemService(AUDIO_SERVICE) as AudioManager }
    private var serviceScope: CoroutineScope? = null
    private var hapticFeedbackEnabled = true
    private var keyClickSoundEnabled = false

    override fun onCreate() {
        super.onCreate()
        val scope = CoroutineScope(SupervisorJob() + Dispatchers.Main)
        serviceScope = scope
        settingsRepository.hapticFeedbackEnabled.onEach { hapticFeedbackEnabled = it }.launchIn(scope)
        settingsRepository.keyClickSoundEnabled.onEach { keyClickSoundEnabled = it }.launchIn(scope)

        inputEngine = KeyboardInputEngine(
            InputConnectionTextDocument({ currentInputConnection }, { currentEditorInfo })
        )
        inputEngine.onNextKeyboard = { switchToNextInputMethod(false) }
        fontStyleRepository.appliedStyleId.onEach { styleId ->
            inputEngine.appliedStyle = FontStyleCatalog.style(styleId)
        }.launchIn(scope)
        // Android's IME runs in-process (unlike iOS's App-Group hand-off to a separate extension
        // process), so this can react live — no re-sync-on-launch dance needed, see
        // AppliedThemeRepository's own note.
        appliedThemeRepository.appliedThemeId.onEach { id ->
            theme = id?.let { RenderableTheme.renderDocument(it) } ?: BuiltInThemes.default
            if (::surface.isInitialized) surface.applyTheme(theme)
        }.launchIn(scope)
    }

    override fun onDestroy() {
        super.onDestroy()
        serviceScope?.cancel()
        serviceScope = null
    }

    override fun onStartInputView(info: EditorInfo?, restarting: Boolean) {
        super.onStartInputView(info, restarting)
        currentEditorInfo = info
        inputEngine.refreshContextualState()
    }

    override fun onCreateInputView(): View {
        currentEditorInfo = currentInputEditorInfo

        surface = KeyboardSurfaceView(this, theme, includesNextKeyboardKey()).apply {
            onAction = { action -> inputEngine.handle(action) }
            onInsertText = { text -> inputEngine.insert(text) }
            performHapticOnDown = {
                if (hapticFeedbackEnabled) performHapticFeedback(HapticFeedbackConstants.KEYBOARD_TAP)
                if (keyClickSoundEnabled) audioManager.playSoundEffect(AudioManager.FX_KEYPRESS_STANDARD)
            }
        }
        inputEngine.onStateChange = { state -> surface.shiftState = state }
        inputEngine.onPlaneChange = { plane -> surface.setPlane(plane) }

        // No suggestion strip: it was a static, non-functional placeholder, and dropping it lets
        // the surface's background art fill the whole keyboard instead of losing a row to a fake
        // row of words. A real predictive-completions bar is a follow-up slice, not this one.
        return FrameLayout(this).apply {
            addView(surface, FrameLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.WRAP_CONTENT).apply {
                gravity = Gravity.BOTTOM
            })
        }
    }

    /** Whether the system reports more than one input method enabled — required by Android's own
     * equivalent of Apple's globe-key guideline: don't show a "next keyboard" affordance when
     * there's nothing to switch to. */
    private fun includesNextKeyboardKey(): Boolean {
        val imm = getSystemService(INPUT_METHOD_SERVICE) as InputMethodManager
        val token = window?.window?.attributes?.token ?: return false
        return imm.shouldOfferSwitchingToNextInputMethod(token)
    }
}
