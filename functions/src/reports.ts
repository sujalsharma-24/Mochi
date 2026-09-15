import { onDocumentCreated } from 'firebase-functions/v2/firestore';
import { db } from './admin.js';

/** Apple/Google both require reported UGC to actually get acted on - matches
 * firestore.rules' own comment naming this trigger "onReportThreshold". Auto-hide pulls the theme
 * back to unpublished so it drops out of every feed query pending manual review (WA7,
 * not built yet) - reports/{reportId} itself is deliberately not client-readable (moderation-only
 * surface per the rules), so this is the only place that threshold logic can live.
 *
 * moderationStatus is set to 'hidden' here rather than 'pending' - 'pending' means "brand new
 * draft, not yet auto-scanned" (CreateRepository's default / onThemeCreated's starting point);
 * reusing it for "auto-hidden after reports" made the two indistinguishable to a future admin
 * reviewer. Every feed query still only shows 'approved', so this has no effect on visibility -
 * it's purely so 'pending' vs 'hidden' can be told apart once WA7's moderation tooling exists. */
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
    moderationStatus: 'hidden',
  });
});
