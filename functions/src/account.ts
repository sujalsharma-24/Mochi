import { onCall, HttpsError } from 'firebase-functions/v2/https';
import { FieldValue } from 'firebase-admin/firestore';
import { db, auth } from './admin.js';

/**
 * Soft-deletes the Firestore profile (isDeleted/deletedAt - firestore.rules' users/{uid} comment
 * explicitly reserves this: "deletion goes through the onAccountDelete callable only"), unpublishes
 * the user's themes so they drop out of every feed, and deletes the real Firebase Auth account.
 * Likes/follows referencing the deleted uid are left as harmless orphans - a full GDPR-style
 * cascade delete is more than this project's v1 scope needs.
 */
export const onAccountDelete = onCall(async (request) => {
  const uid = request.auth?.uid;
  if (!uid) {
    throw new HttpsError('unauthenticated', 'Sign in required.');
  }

  const themesSnap = await db.collection('themes').where('creatorUid', '==', uid).get();
  const docs = themesSnap.docs;
  for (let i = 0; i < docs.length; i += 500) {
    const batch = db.batch();
    for (const doc of docs.slice(i, i + 500)) {
      batch.update(doc.ref, { isPublished: false });
    }
    await batch.commit();
  }

  await db
    .collection('users')
    .doc(uid)
    .set({ isDeleted: true, deletedAt: FieldValue.serverTimestamp() }, { merge: true });

  await auth.deleteUser(uid);

  return { success: true };
});
