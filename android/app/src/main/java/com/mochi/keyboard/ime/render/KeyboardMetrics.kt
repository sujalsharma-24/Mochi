package com.mochi.keyboard.ime.render

import kotlin.math.roundToInt

/**
 * Every dimension the keyboard is drawn with, derived from the available width — ported from iOS's
 * `KeyboardMetrics.swift`. Not invented numbers: fitted to measurements of the *system* keyboard
 * (39dp key height @320, 43 @375, 46 @414 — dp and iOS points share the same density-independent
 * definition, so the same fit applies unchanged), so a Mochi keyboard lands its keys where a user's
 * thumbs already expect them. All units are dp.
 */
class KeyboardMetrics(availableWidthDp: Float, isLandscape: Boolean) {
    val availableWidthDp: Float = maxOf(240f, availableWidthDp)
    val sideInsetDp: Float
    val topInsetDp: Float
    val bottomInsetDp: Float
    val columnGapDp: Float
    val rowGapDp: Float
    val standardKeyWidthDp: Float
    val keyHeightDp: Float
    val keyCornerRadiusDp: Float
    val inputLabelSizeSp: Float
    val systemLabelSizeSp: Float
    val suggestionBarHeightDp: Float

    init {
        val fittedHeight = 0.0727f * this.availableWidthDp + 15.727f

        if (isLandscape) {
            keyHeightDp = 33f
            topInsetDp = 5f
            bottomInsetDp = 3f
            rowGapDp = 6f
        } else {
            keyHeightDp = fittedHeight.roundToInt().toFloat()
            topInsetDp = 10f
            bottomInsetDp = 4f
            rowGapDp = (keyHeightDp * 0.24f).roundToInt().toFloat()
        }

        sideInsetDp = if (this.availableWidthDp >= 400f) 4f else 3f
        columnGapDp = 6f

        val usableWidth = this.availableWidthDp - sideInsetDp * 2
        val totalGap = columnGapDp * (TOP_ROW_COLUMN_COUNT - 1)
        standardKeyWidthDp = (usableWidth - totalGap) / TOP_ROW_COLUMN_COUNT

        // Deliberately rounder than the system's ~5-6dp — costs nothing in typing accuracy, unlike
        // key position, and it's where the product's identity lives. Themes may override per role.
        keyCornerRadiusDp = (keyHeightDp * 0.21f).roundToInt().toFloat()

        inputLabelSizeSp = (keyHeightDp * 0.55f).roundToInt().toFloat()
        systemLabelSizeSp = (keyHeightDp * 0.38f).roundToInt().toFloat()

        suggestionBarHeightDp = if (isLandscape) 34f else 44f
    }

    fun totalHeightDp(rowCount: Int, includesSuggestionBar: Boolean = false): Float {
        val rows = maxOf(1, rowCount).toFloat()
        val keys = topInsetDp + rows * keyHeightDp + (rows - 1) * rowGapDp + bottomInsetDp
        return keys + if (includesSuggestionBar) suggestionBarHeightDp else 0f
    }

    override fun equals(other: Any?): Boolean =
        other is KeyboardMetrics && availableWidthDp == other.availableWidthDp &&
            keyHeightDp == other.keyHeightDp && topInsetDp == other.topInsetDp

    override fun hashCode(): Int = availableWidthDp.hashCode() * 31 + keyHeightDp.hashCode()

    companion object {
        const val TOP_ROW_COLUMN_COUNT = 10f
    }
}
