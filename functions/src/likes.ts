import { onDocumentWritten } from 'firebase-functions/v2/firestore';
import { FieldValue } from 'firebase-admin/firestore';
import { db } from './admin.js';
import { isoWeekId } from './weekId.js';

/**
 * likes/{uid}_{themeId} is create/delete only (firestore.rules forbids update), so this only ever
 * sees a pure create or a pure delete - never a data change on an existing doc. This is the ONLY
 * writer of themes.likeCount, users.likesGivenCount/likesReceivedCount, and the weeklyStats
 * leaderboard - firestore.rules blocks clients from touching any of those directly (see the rules
 * file's own top comment), which is exactly why liking/following didn't move any counters yet in
 * WA2 - this function is what closes that gap.
 */
export const onLikeWritten = onDocumentWritten('likes/{likeId}', async (event) => {
  const before = event.data?.before;
  const after = event.data?.after;
  const wasLiked = before?.exists ?? false;
  const isLiked = after?.exists ?? false;
  if (wasLiked === isLiked) return;

  const data = (isLiked ? after : before)?.data() as { uid?: string; themeId?: string } | undefined;
  const likerUid = data?.uid;
  const themeId = data?.themeId;
  if (!likerUid || !themeId) return;

  const themeRef = db.collection('themes').doc(themeId);
  const themeSnap = await themeRef.get();
  if (!themeSnap.exists) return;
  const creatorUid = themeSnap.data()?.creatorUid as string | undefined;

  const delta = isLiked ? 1 : -1;
  const batch = db.batch();
  batch.update(themeRef, { likeCount: FieldValue.increment(delta) });
  batch.set(
    db.collection('users').doc(likerUid),
    { likesGivenCount: FieldValue.increment(delta) },
    { merge: true }
  );
  if (creatorUid) {
    batch.set(
      db.collection('users').doc(creatorUid),
      { likesReceivedCount: FieldValue.increment(delta) },
      { merge: true }
    );
    const weekRef = db
      .collection('weeklyStats')
      .doc(isoWeekId())
      .collection('creators')
      .doc(creatorUid);
    batch.set(weekRef, { likeCount: FieldValue.increment(delta) }, { merge: true });
  }
  await batch.commit();
});
