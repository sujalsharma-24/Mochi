package com.mochi.keyboard.ime.render

import android.view.inputmethod.EditorInfo
import android.view.inputmethod.InputConnection

/** The document the keyboard is typing into — an abstraction over [InputConnection] so the input
 * logic can be driven by a plain string in a future in-app test bench, mirroring iOS's
 * `TextDocumentAdapter`. */
interface TextDocumentAdapter {
    fun textBeforeCursor(maxLength: Int = 32): String?
    val autoCapitalize: Boolean
    fun insertText(text: String)
    fun deleteBackward()
}

/** Adapter over a plain in-memory buffer, for an in-app live keyboard preview (Theme Detail) that
 * has no real text field to type into — mirrors iOS's `BufferTextDocument`. Deletes by whole code
 * point, not UTF-16 unit, so backspacing over a styled Unicode replacement or an emoji removes it in
 * one press instead of leaving a stray low surrogate behind. */
class BufferTextDocument : TextDocumentAdapter {
    var text: String = ""
        private set
    var onChange: ((String) -> Unit)? = null

    override fun textBeforeCursor(maxLength: Int): String? = text.takeLast(maxLength)
    override val autoCapitalize: Boolean = true

    override fun insertText(text: String) {
        this.text += text
        onChange?.invoke(this.text)
    }

    override fun deleteBackward() {
        if (text.isEmpty()) return
        val charCount = Character.charCount(text.codePointBefore(text.length))
        text = text.substring(0, text.length - charCount)
        onChange?.invoke(text)
    }
}

/** Adapter over the real host document. */
class InputConnectionTextDocument(
    private val connectionProvider: () -> InputConnection?,
    private val editorInfoProvider: () -> EditorInfo?
) : TextDocumentAdapter {
    override fun textBeforeCursor(maxLength: Int): String? =
        connectionProvider()?.getTextBeforeCursor(maxLength, 0)?.toString()

    override val autoCapitalize: Boolean
        get() {
            val info = editorInfoProvider() ?: return true
            val variation = info.inputType and android.text.InputType.TYPE_MASK_VARIATION
            val isPasswordOrUri = variation == android.text.InputType.TYPE_TEXT_VARIATION_PASSWORD ||
                variation == android.text.InputType.TYPE_TEXT_VARIATION_VISIBLE_PASSWORD ||
                variation == android.text.InputType.TYPE_TEXT_VARIATION_WEB_PASSWORD ||
                variation == android.text.InputType.TYPE_TEXT_VARIATION_URI ||
                (info.inputType and android.text.InputType.TYPE_MASK_CLASS) == android.text.InputType.TYPE_CLASS_NUMBER
            return !isPasswordOrUri
        }

    override fun insertText(text: String) {
        connectionProvider()?.commitText(text, 1)
    }

    override fun deleteBackward() {
        connectionProvider()?.deleteSurroundingText(1, 0)
    }
}

/** All the typing behaviour: shift, caps lock, auto-capitalisation, and the double-space period —
 * ported from iOS's `KeyboardInputEngine`. Holds no views, so `MochiInputMethodService` and a future
 * in-app test bench both drive it and render its output, which is what keeps the two from
 * disagreeing about what shift does. */
class KeyboardInputEngine(var document: TextDocumentAdapter? = null) {
    var onStateChange: ((ShiftState) -> Unit)? = null
    var onPlaneChange: ((KeyboardPlane) -> Unit)? = null
    var onNextKeyboard: (() -> Unit)? = null

    /** The applied Mochi "font" — a Unicode lookalike transform (see [FontStyleCatalog]), or null
     * for plain text. Typed letters/digits are emitted through this; everything read back out of
     * the document is normalised to plain text first, so autocap/the double-space period keep
     * working while a style is on. */
    var appliedStyle: FontStyle? = null

    var shiftState: ShiftState = ShiftState.ONE_SHOT
        private set

    private var lastShiftTapTime = 0L
    private var lastSpaceTime = 0L

    /** The active document context, read back as plain ASCII regardless of the applied style. */
    private val plainContext: String
        get() = FontStyleCatalog.normalize(document?.textBeforeCursor())

    private fun styled(text: String): String = appliedStyle?.styled(text) ?: text

    fun handle(action: KeyAction) {
        when (action) {
            is KeyAction.Insert -> insert(if (shiftState.isUppercase) action.text.uppercase() else action.text.lowercase())
            KeyAction.Space -> insertSpace()
            KeyAction.NewLine -> {
                document?.insertText("\n")
                refreshContextualState()
            }
            KeyAction.Backspace -> {
                document?.deleteBackward()
                refreshContextualState()
            }
            KeyAction.Shift -> handleShiftTap()
            is KeyAction.SwitchPlane -> onPlaneChange?.invoke(action.plane)
            KeyAction.NextKeyboard -> onNextKeyboard?.invoke()
            KeyAction.Spacer -> {}
        }
    }

    /** Inserts literal text — a letter or an accent from the long-press callout — through the
     * applied style, if any. */
    fun insert(text: String) {
        document?.insertText(styled(text))
        shiftState = shiftState.afterCharacterInput()
        emitState()
    }

    /** Space, with the double-space-to-period shortcut. Only fires when the character before the
     * two spaces is a letter or digit, so "hello  " gets a period but ".  " does not become "..  ". */
    private fun insertSpace() {
        val now = System.currentTimeMillis()
        val context = plainContext

        if (now - lastSpaceTime < 600 &&
            context.endsWith(" ") && !context.endsWith("  ") &&
            context.dropLast(1).lastOrNull()?.let { it.isLetterOrDigit() } == true
        ) {
            document?.deleteBackward()
            document?.insertText(". ")
            lastSpaceTime = 0
            refreshContextualState()
            return
        }

        document?.insertText(" ")
        lastSpaceTime = now
        refreshContextualState()
    }

    /** Single tap toggles shift; a second tap within the double-tap window locks it. */
    private fun handleShiftTap() {
        val now = System.currentTimeMillis()
        if (now - lastShiftTapTime < 300) {
            shiftState = ShiftState.LOCKED
            lastShiftTapTime = 0
            emitState()
            return
        }
        lastShiftTapTime = now
        shiftState = shiftState.afterShiftTap()
        emitState()
    }

    fun refreshContextualState() {
        updateShiftForContext()
        emitState()
    }

    /** Auto-capitalises at the start of the document and after sentence-ending punctuation. Respects
     * the host field's input type, so a password or URL field never gets surprise capitals. */
    private fun updateShiftForContext() {
        if (shiftState == ShiftState.LOCKED) return
        val doc = document
        if (doc != null && !doc.autoCapitalize) {
            shiftState = ShiftState.OFF
            return
        }

        val context = plainContext
        val trimmed = context.trimEnd { it == ' ' || it == '\t' }
        shiftState = when {
            context.isEmpty() -> ShiftState.ONE_SHOT
            trimmed.lastOrNull() in listOf('.', '!', '?') && context.endsWith(" ") -> ShiftState.ONE_SHOT
            else -> ShiftState.OFF
        }
    }

    private fun emitState() {
        onStateChange?.invoke(shiftState)
    }
}
