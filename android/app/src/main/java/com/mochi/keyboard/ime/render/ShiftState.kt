package com.mochi.keyboard.ime.render

/**
 * The three states shift can actually be in — ported from iOS's `ShiftState`. Modelled as an enum
 * rather than a boolean-plus-flag pair because the two-flag version has an unrepresentable-but-
 * reachable fourth state (locked *and* one-shot), whose symptom — caps lock silently releasing
 * after one letter — reads as "the keyboard is broken" rather than a specific defect.
 */
enum class ShiftState {
    /** Lowercase. */
    OFF,
    /** Uppercase for exactly one character, then back to OFF. */
    ONE_SHOT,
    /** Uppercase until explicitly turned off. */
    LOCKED;

    val isUppercase: Boolean get() = this != OFF
    val showsEngagedKey: Boolean get() = this != OFF

    /** What a single tap on the shift key does from here. Tapping while locked releases the lock
     * rather than dropping to one-shot — a lit caps-lock key being tapped is a request for
     * lowercase, not for one more capital. */
    fun afterShiftTap(): ShiftState = when (this) {
        OFF -> ONE_SHOT
        ONE_SHOT -> OFF
        LOCKED -> OFF
    }

    fun afterCharacterInput(): ShiftState = if (this == ONE_SHOT) OFF else this
}
