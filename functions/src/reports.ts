import { onDocumentCreated } from 'firebase-functions/v2/firestore';
import { db } from './admin.js';

/** Apple/Google both require reported UGC to actually get acted on - matches
 * firestore.rules' own comment naming this trigger "onReportThreshold". Auto-hide pulls the theme
 * back to pending/unpublished so it drops out of every feed query pending manual review (WA7,
 * not built yet) - reports/{reportId} itself is deliberately not client-readable (moderation-only
 * surface per the rules), so this is the only place that threshold logic can live. */
const AUTO_HIDE_THRESHOLD = 5;

export const onReportThreshold = onDocumentCreated('reports/{reportId}', async (event) => {
  const snap = event.data;
  if (!snap) return;
  const themeId = snap.data().themeId as string | undefined;
  if (!themeId) return;

  const openReports = await db
    .collection('reports')
    .where('themeId', '==', themeId)
    .where('status', '==', 'open')
    .get();

  if (openReports.size < AUTO_HIDE_THRESHOLD) return;

  await db.collection('themes').doc(themeId).update({
    isPublished: false,
    moderationStatus: 'pending',
  });
});
