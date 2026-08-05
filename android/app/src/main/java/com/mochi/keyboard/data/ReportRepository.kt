package com.mochi.keyboard.data

import com.google.firebase.firestore.FieldValue
import com.google.firebase.firestore.FirebaseFirestore
import kotlinx.coroutines.tasks.await

/**
 * Writes must match firestore/firestore.rules' reports/{reportId} `create` rule exactly
 * (reporterUid == auth.uid, status == "open") - functions/src/reports.ts' onReportThreshold
 * trigger reads themeId + status to auto-unpublish a theme at 5 open reports. reports/{reportId}
 * is never client-readable (moderation-only surface per the rules), so there's no read method
 * here - this repository is write-only by design, not an oversight.
 */
class ReportRepository(private val firestore: FirebaseFirestore) {

    suspend fun reportTheme(reporterUid: String, themeId: String, reason: String) {
        val report = hashMapOf(
            "reporterUid" to reporterUid,
            "themeId" to themeId,
            "reason" to reason,
            "status" to "open",
            "createdAt" to FieldValue.serverTimestamp()
        )
        firestore.collection("reports").add(report).await()
    }
}
