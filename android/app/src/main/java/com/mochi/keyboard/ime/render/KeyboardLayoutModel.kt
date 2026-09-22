package com.mochi.keyboard.ime.render

import androidx.annotation.DrawableRes

/** What a key does when tapped — ported from iOS's `KeyAction`. Kept separate from how it looks so
 * a new theme never requires a layout change and vice versa. */
sealed class KeyAction {
    data class Insert(val text: String) : KeyAction()
    object Backspace : KeyAction()
    object Shift : KeyAction()
    data class SwitchPlane(val plane: KeyboardPlane) : KeyAction()
    /** Advance to the next system keyboard — only shown when the IME reports more than one input
     * method is enabled. */
    object NextKeyboard : KeyAction()
    object NewLine : KeyAction()
    object Space : KeyAction()
    /** Occupies grid space without drawing or accepting touches — reproduces the wider gaps the
     * system keyboard leaves either side of shift and backspace. */
    object Spacer : KeyAction()
}

enum class KeyboardPlane { LETTERS, NUMBERS, SYMBOLS, EMOJI }

/** How wide a key is, relative to the row it lives in. */
sealed class KeyWidth {
    object Standard : KeyWidth()
    data class Ratio(val multiple: Float) : KeyWidth()
    /** Splits whatever width the fixed keys in the row leave over. */
    object Fill : KeyWidth()
}

class KeyDefinition(
    val action: KeyAction,
    val role: KeyRole,
    val width: KeyWidth = KeyWidth.Standard,
    /** Text drawn on the cap; null for icon keys and spacers. */
    val label: String? = null,
    /** Vector drawable resource for icon keys (backspace, shift, globe, emoji), used when [label]
     * is null. */
    @DrawableRes val iconRes: Int? = null,
    val accessibilityLabel: String? = null,
    /** Fires repeatedly while held — only backspace does this. */
    val repeatsWhenHeld: Boolean = false
) {
    /** Stable identity used to look up this key's per-key illustration, or null for keys that never
     * carry one. Derived from the *action*, not the label, so it stays stable across shift/plane
     * changes that would otherwise flicker the artwork. */
    val artIdentity: String?
        get() = when (val a = action) {
            is KeyAction.Insert -> {
                val lowered = a.text.lowercase()
                if (lowered.length == 1 && lowered[0].isLetter()) lowered else null
            }
            KeyAction.Shift -> "shift"
            KeyAction.Backspace -> "backspace"
            KeyAction.Space -> "space"
            KeyAction.NewLine -> "return"
            KeyAction.NextKeyboard -> "globe"
            is KeyAction.SwitchPlane -> if (a.plane == KeyboardPlane.EMOJI) "emoji" else "123"
            KeyAction.Spacer -> null
        }

    /** Long-press alternates, if any — drives the accent callout. */
    val alternates: List<String>
        get() {
            val a = action
            return if (a is KeyAction.Insert) AccentMap.alternates(a.text) else emptyList()
        }

    companion object {
        fun letter(character: String) = KeyDefinition(KeyAction.Insert(character), KeyRole.INPUT, label = character)
        val SPACER = KeyDefinition(KeyAction.Spacer, KeyRole.INPUT, width = KeyWidth.Fill)
    }
}

class KeyRow(val keys: List<KeyDefinition>, val additionalSideInsetDp: Float = 0f)

/** The key grid for one plane, before theming — ported from iOS's `KeyboardLayout`. */
class KeyboardLayout(val rows: List<KeyRow>) {
    companion object {
        fun letters(includesNextKeyboardKey: Boolean, metrics: KeyboardMetrics): KeyboardLayout {
            val homeRowInset = (metrics.standardKeyWidthDp + metrics.columnGapDp) / 2
            return KeyboardLayout(
                listOf(
                    KeyRow("QWERTYUIOP".map { KeyDefinition.letter(it.toString()) }),
                    KeyRow("ASDFGHJKL".map { KeyDefinition.letter(it.toString()) }, additionalSideInsetDp = homeRowInset),
                    KeyRow(bottomLetterRow()),
                    KeyRow(functionRow(includesNextKeyboardKey, returnLabel = "return"))
                )
            )
        }

        fun numbers(includesNextKeyboardKey: Boolean): KeyboardLayout = KeyboardLayout(
            listOf(
                KeyRow("1234567890".map { KeyDefinition.letter(it.toString()) }),
                KeyRow("-/:;()$&@\"".map { KeyDefinition.letter(it.toString()) }),
                KeyRow(
                    listOf(
                        KeyDefinition(KeyAction.SwitchPlane(KeyboardPlane.SYMBOLS), KeyRole.SYSTEM, KeyWidth.Ratio(1.33f), label = "#+=", accessibilityLabel = "More symbols"),
                        KeyDefinition.SPACER
                    ) + ".,?!'".map { KeyDefinition.letter(it.toString()) } + listOf(
                        KeyDefinition.SPACER,
                        KeyDefinition(KeyAction.Backspace, KeyRole.SYSTEM, KeyWidth.Ratio(1.33f), iconRes = com.mochi.keyboard.R.drawable.ic_key_backspace, accessibilityLabel = "Delete", repeatsWhenHeld = true)
                    )
                ),
                KeyRow(functionRow(includesNextKeyboardKey, returnLabel = "return", planeSwitchLabel = "ABC", planeSwitchTarget = KeyboardPlane.LETTERS))
            )
        )

        fun symbols(includesNextKeyboardKey: Boolean): KeyboardLayout = KeyboardLayout(
            listOf(
                KeyRow("[]{}#%^*+=".map { KeyDefinition.letter(it.toString()) }),
                KeyRow("_\\|~<>€£¥•".map { KeyDefinition.letter(it.toString()) }),
                KeyRow(
                    listOf(
                        KeyDefinition(KeyAction.SwitchPlane(KeyboardPlane.NUMBERS), KeyRole.SYSTEM, KeyWidth.Ratio(1.33f), label = "123", accessibilityLabel = "Numbers"),
                        KeyDefinition.SPACER
                    ) + ".,?!'".map { KeyDefinition.letter(it.toString()) } + listOf(
                        KeyDefinition.SPACER,
                        KeyDefinition(KeyAction.Backspace, KeyRole.SYSTEM, KeyWidth.Ratio(1.33f), iconRes = com.mochi.keyboard.R.drawable.ic_key_backspace, accessibilityLabel = "Delete", repeatsWhenHeld = true)
                    )
                ),
                KeyRow(functionRow(includesNextKeyboardKey, returnLabel = "return", planeSwitchLabel = "ABC", planeSwitchTarget = KeyboardPlane.LETTERS))
            )
        )

        private fun bottomLetterRow(): List<KeyDefinition> = listOf(
            KeyDefinition(KeyAction.Shift, KeyRole.SYSTEM, KeyWidth.Ratio(1.33f), iconRes = com.mochi.keyboard.R.drawable.ic_key_shift, accessibilityLabel = "Shift"),
            KeyDefinition.SPACER
        ) + "ZXCVBNM".map { KeyDefinition.letter(it.toString()) } + listOf(
            KeyDefinition.SPACER,
            KeyDefinition(KeyAction.Backspace, KeyRole.SYSTEM, KeyWidth.Ratio(1.33f), iconRes = com.mochi.keyboard.R.drawable.ic_key_backspace, accessibilityLabel = "Delete", repeatsWhenHeld = true)
        )

        private fun functionRow(
            includesNextKeyboardKey: Boolean,
            returnLabel: String,
            planeSwitchLabel: String = "123",
            planeSwitchTarget: KeyboardPlane = KeyboardPlane.NUMBERS
        ): List<KeyDefinition> {
            val keys = mutableListOf(
                KeyDefinition(KeyAction.SwitchPlane(planeSwitchTarget), KeyRole.SYSTEM, KeyWidth.Ratio(1.33f), label = planeSwitchLabel, accessibilityLabel = if (planeSwitchLabel == "ABC") "Letters" else "Numbers")
            )
            if (includesNextKeyboardKey) {
                keys.add(KeyDefinition(KeyAction.NextKeyboard, KeyRole.SYSTEM, KeyWidth.Ratio(1.33f), iconRes = com.mochi.keyboard.R.drawable.ic_key_globe, accessibilityLabel = "Next keyboard"))
            }
            keys.add(KeyDefinition(KeyAction.SwitchPlane(KeyboardPlane.EMOJI), KeyRole.SYSTEM, KeyWidth.Ratio(1.1f), iconRes = com.mochi.keyboard.R.drawable.ic_key_emoji, accessibilityLabel = "Emoji"))
            keys.add(KeyDefinition(KeyAction.Space, KeyRole.SPACE, KeyWidth.Fill, label = "space"))
            keys.add(KeyDefinition(KeyAction.NewLine, KeyRole.ACTION, KeyWidth.Ratio(2.6f), label = returnLabel, accessibilityLabel = "Return"))
            return keys
        }

        fun layout(plane: KeyboardPlane, includesNextKeyboardKey: Boolean, metrics: KeyboardMetrics): KeyboardLayout =
            when (plane) {
                KeyboardPlane.LETTERS -> letters(includesNextKeyboardKey, metrics)
                KeyboardPlane.NUMBERS -> numbers(includesNextKeyboardKey)
                KeyboardPlane.SYMBOLS -> symbols(includesNextKeyboardKey)
                // No key grid for emoji; report letters so height stays stable across the switch.
                KeyboardPlane.EMOJI -> letters(includesNextKeyboardKey, metrics)
            }
    }
}

/** A key with its resolved frame (dp, top-left origin). */
class SolvedKey(val definition: KeyDefinition, val leftDp: Float, val topDp: Float, val widthDp: Float, val heightDp: Float)

object KeyboardLayoutSolver {
    fun solve(layout: KeyboardLayout, metrics: KeyboardMetrics, widthDp: Float): List<SolvedKey> {
        val solved = mutableListOf<SolvedKey>()
        var y = metrics.topInsetDp

        for (row in layout.rows) {
            val rowInset = metrics.sideInsetDp + row.additionalSideInsetDp
            val available = widthDp - rowInset * 2
            val gapTotal = metrics.columnGapDp * maxOf(0, row.keys.size - 1)

            var fixedWidth = 0f
            var fillCount = 0
            for (key in row.keys) {
                when (val w = key.width) {
                    KeyWidth.Standard -> fixedWidth += metrics.standardKeyWidthDp
                    is KeyWidth.Ratio -> fixedWidth += metrics.standardKeyWidthDp * w.multiple
                    KeyWidth.Fill -> fillCount++
                }
            }
            val fillWidth = if (fillCount > 0) maxOf(0f, (available - gapTotal - fixedWidth) / fillCount) else 0f

            var x = rowInset
            for (key in row.keys) {
                val width = when (val w = key.width) {
                    KeyWidth.Standard -> metrics.standardKeyWidthDp
                    is KeyWidth.Ratio -> metrics.standardKeyWidthDp * w.multiple
                    KeyWidth.Fill -> fillWidth
                }
                if (key.action != KeyAction.Spacer) {
                    solved.add(SolvedKey(key, x, y, width, metrics.keyHeightDp))
                }
                x += width + metrics.columnGapDp
            }
            y += metrics.keyHeightDp + metrics.rowGapDp
        }
        return solved
    }
}
