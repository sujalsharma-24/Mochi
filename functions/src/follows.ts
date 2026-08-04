import { onDocumentWritten } from 'firebase-functions/v2/firestore';
import { FieldValue } from 'firebase-admin/firestore';
import { db } from './admin.js';

/** Same create/delete-only shape as likes.ts - see onLikeWritten's comment. */
export const onFollowWritten = onDocumentWritten('follows/{followId}', async (event) => {
  const before = event.data?.before;
  const after = event.data?.after;
  const wasFollowing = before?.exists ?? false;
  const isFollowing = after?.exists ?? false;
  if (wasFollowing === isFollowing) return;

  const data = (isFollowing ? after : before)?.data() as
    | { followerId?: string; followeeId?: string }
    | undefined;
  const followerId = data?.followerId;
  const followeeId = data?.followeeId;
  if (!followerId || !followeeId) return;

  const delta = isFollowing ? 1 : -1;
  const batch = db.batch();
  batch.set(
    db.collection('users').doc(followerId),
    { followingCount: FieldValue.increment(delta) },
    { merge: true }
  );
  batch.set(
    db.collection('users').doc(followeeId),
    { followerCount: FieldValue.increment(delta) },
    { merge: true }
  );
  await batch.commit();
});
