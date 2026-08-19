import { onDocumentUpdated } from 'firebase-functions/v2/firestore';
import { db, messaging } from './admin.js';

/** Matches ThemeRepository.kt's exact feed-visibility filter (`isPublished == true &&
 * moderationStatus == 'approved'`) - a theme is "published" for notification purposes exactly when
 * it would start showing up in a real feed, not merely when the create/update write happens. */
function isVisible(data: FirebaseFirestore.DocumentData | undefined): boolean {
  return data?.isPublished === true && data?.moderationStatus === 'approved';
}

/** FCM caps a single sendEachForMulticast call at 500 registration tokens. */
const FCM_BATCH_SIZE = 500;
function chunk<T>(items: T[], size: number): T[][] {
  const out: T[][] = [];
  for (let i = 0; i < items.length; i += size) out.push(items.slice(i, i + size));
  return out;
}

/**
 * "New theme from a followed creator" (project_mochi_features.md's Notifications/FCM section).
 * Fires on themes/{themeId} update rather than moderation.ts' onThemeCreated (a create-only
 * trigger) because a theme only actually becomes visible after nsfwjs classification resolves
 * asynchronously (onThemeCreated's own update to moderationStatus), or later still if a draft gets
 * published after the fact (owner flips isPublished via the update allowlist) - either path is a
 * themes/{themeId} update, never a create. Guards on the false->true visibility transition so this
 * never double-notifies for an already-visible theme's unrelated edits (e.g. editing description).
 */
export const onThemePublished = onDocumentUpdated('themes/{themeId}', async (event) => {
  const before = event.data?.before?.data();
  const after = event.data?.after?.data();
  if (!after) return;
  if (isVisible(before) || !isVisible(after)) return;

  const creatorUid = after.creatorUid as string | undefined;
  const themeId = event.params.themeId;
  if (!creatorUid) return;

  const followerDocs = await db.collection('follows').where('followeeId', '==', creatorUid).get();
  if (followerDocs.empty) return;
  const followerIds = followerDocs.docs
    .map((d) => d.data().followerId as string | undefined)
    .filter((id): id is string => !!id);
  if (followerIds.length === 0) return;

  const followerUsers = await db.getAll(...followerIds.map((id) => db.collection('users').doc(id)));
  const tokens = followerUsers
    .filter((snap) => snap.exists && snap.data()?.notificationsEnabled !== false)
    .map((snap) => snap.data()?.fcmToken as string | undefined)
    .filter((token): token is string => !!token);
  if (tokens.length === 0) return;

  const creatorName = (after.creatorDisplayName as string) || 'Someone you follow';
  const themeName = (after.name as string) || 'a new theme';

  await Promise.all(
    chunk(tokens, FCM_BATCH_SIZE).map((batch) =>
      messaging.sendEachForMulticast({
        tokens: batch,
        data: {
          type: 'new_theme',
          themeId,
          title: `${creatorName} published a new theme`,
          body: themeName,
        },
      })
    )
  );
});
