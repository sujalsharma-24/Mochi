package com.mochi.keyboard.util

import java.time.Clock
import java.time.LocalDate
import java.time.ZoneOffset
import java.time.temporal.IsoFields

/**
 * ISO-8601 week id ("2026-W30") - must match functions/src/weekId.ts's isoWeekId() exactly, since
 * this is used to look up the same `weeklyStats/{weekId}/creators` document that function writes.
 * java.time's IsoFields implements the same Monday-based, week-1-contains-the-first-Thursday
 * definition as that hand-rolled JS version, so this is a direct port, not a re-derivation.
 */
fun isoWeekId(date: LocalDate = LocalDate.now(Clock.systemUTC().withZone(ZoneOffset.UTC))): String {
    val week = date.get(IsoFields.WEEK_OF_WEEK_BASED_YEAR)
    val year = date.get(IsoFields.WEEK_BASED_YEAR)
    return "$year-W${week.toString().padStart(2, '0')}"
}
