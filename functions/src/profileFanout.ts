import { onDocumentUpdated } from 'firebase-functions/v2/firestore';
import { db } from './admin.js';

/**
 * themes/{id} denormalizes creatorDisplayName/creatorAvatarUrl so feed cards don't need an extra
 * per-card user-doc read (see project_mochi_trd - this was the whole reason those fields exist).
 * Whenever a user changes their name/avatar, every theme they've published needs the same update -
 * client can't do this itself (firestore.rules' themes update allowlist excludes those two fields
 * specifically, since they must only ever come from this trigger, never a client claiming a new
 * identity for someone else's theme).
 */
export const onUserProfileUpdated = onDocumentUpdated('users/{uid}', async (event) => {
  const before = event.data?.before.data();
  const after = event.data?.after.data();
  if (!before || !after) return;

  const displayName = after.displayName as string | undefined;
  const avatarUrl = after.avatarUrl as string | undefined;
  const nameChanged = before.displayName !== after.displayName;
  const avatarChanged = before.avatarUrl !== after.avatarUrl;
  if (!nameChanged && !avatarChanged) return;

  const uid = event.params.uid as string;
  const themesSnap = await db.collection('themes').where('creatorUid', '==', uid).get();
  if (themesSnap.empty) return;

  // Firestore batches cap at 500 writes - chunk defensively even though one creator publishing
  // 500+ themes is far beyond this project's 250-theme launch catalog.
  const docs = themesSnap.docs;
  for (let i = 0; i < docs.length; i += 500) {
    const batch = db.batch();
    for (const doc of docs.slice(i, i + 500)) {
      batch.update(doc.ref, {
        ...(nameChanged ? { creatorDisplayName: displayName ?? '' } : {}),
        ...(avatarChanged ? { creatorAvatarUrl: avatarUrl ?? '' } : {}),
      });
    }
    await batch.commit();
  }
});
