import FirebaseFirestore

/// Writes must match firestore/firestore.rules' reports/{reportId} `create` rule exactly
/// (reporterUid == auth.uid, status == "open") — functions/src/reports.ts' onReportThreshold
/// trigger reads themeId + status to auto-unpublish a theme at 5 open reports. reports/{reportId}
/// is never client-readable (moderation-only surface per the rules), so there's no read method
/// here — write-only by design, same contract android/.../data/ReportRepository.kt uses.
final class ReportRepository {
    private let firestore: Firestore

    init(firestore: Firestore) {
        self.firestore = firestore
    }

    func reportTheme(reporterUid: String, themeId: String, reason: String) async throws {
        try await firestore.collection("reports").addDocument(data: [
            "reporterUid": reporterUid,
            "themeId": themeId,
            "reason": reason,
            "status": "open",
            "createdAt": FieldValue.serverTimestamp()
        ])
    }
}
