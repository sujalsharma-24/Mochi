import { onCall, HttpsError } from 'firebase-functions/v2/https';
import { FieldValue } from 'firebase-admin/firestore';
import { db } from './admin.js';

// firestore.rules' usernames/{username} comment names these two callables directly:
// "Reservation is performed inside the reserveUsername callable... Client may read to support an
// optimistic 'is this taken?' UI check" (that's checkUsernameAvailable).
const USERNAME_PATTERN = /^[a-z0-9_]{3,20}$/;

function validateUsername(raw: unknown): string {
  const username = typeof raw === 'string' ? raw.toLowerCase() : '';
  if (!USERNAME_PATTERN.test(username)) {
    throw new HttpsError(
      'invalid-argument',
      'Usernames are 3-20 lowercase letters, numbers, or underscores.'
    );
  }
  return username;
}

export const checkUsernameAvailable = onCall(async (request) => {
  const username = validateUsername(request.data?.username);
  const doc = await db.collection('usernames').doc(username).get();
  return { available: !doc.exists };
});

export const reserveUsername = onCall(async (request) => {
  const uid = request.auth?.uid;
  if (!uid) {
    throw new HttpsError('unauthenticated', 'Sign in required.');
  }
  const username = validateUsername(request.data?.username);

  const usernameRef = db.collection('usernames').doc(username);
  const userRef = db.collection('users').doc(uid);

  await db.runTransaction(async (tx) => {
    const existing = await tx.get(usernameRef);
    if (existing.exists) {
      throw new HttpsError('already-exists', 'That username is taken.');
    }
    tx.set(usernameRef, { uid, reservedAt: FieldValue.serverTimestamp() });
    tx.set(userRef, { username }, { merge: true });
  });

  return { success: true };
});
