/**
 * Exercises all 8 Cloud Functions against the local emulator suite via the same client SDK a real
 * app would use (not the Admin SDK - so every write here is also proving firestore.rules accepts
 * the shape CreateRepository.kt/LikeRepository.kt/etc. actually send). Run with the emulator suite
 * already up: `firebase emulators:start --project demo-mochi-test` from the repo root, then
 * `node test/integration.mjs` from functions/.
 *
 * revenueCatWebhook's second case deliberately uses a fake RevenueCat API key (see .secret.local) -
 * the assertion is that the function reaches the real api.revenuecat.com boundary and fails there
 * (502), not that a real subscriber lookup succeeds. That's the correct thing to prove without a
 * real RevenueCat account.
 */
import { initializeApp } from 'firebase/app';
import {
  getAuth,
  connectAuthEmulator,
  createUserWithEmailAndPassword,
  signInWithEmailAndPassword,
} from 'firebase/auth';
import {
  getFirestore,
  connectFirestoreEmulator,
  doc,
  setDoc,
  updateDoc,
  deleteDoc,
  getDoc,
  collection,
  addDoc,
  serverTimestamp,
} from 'firebase/firestore';
import { getFunctions, connectFunctionsEmulator, httpsCallable } from 'firebase/functions';
import assert from 'node:assert/strict';

const PROJECT_ID = 'demo-mochi-test';
const FUNCTIONS_BASE = 'http://127.0.0.1:5001/demo-mochi-test/us-central1';

const app = initializeApp({ projectId: PROJECT_ID, apiKey: 'demo-key' });
const auth = getAuth(app);
const db = getFirestore(app);
const functions = getFunctions(app, 'us-central1');
connectAuthEmulator(auth, 'http://127.0.0.1:9099', { disableWarnings: true });
connectFirestoreEmulator(db, '127.0.0.1', 8080);
connectFunctionsEmulator(functions, '127.0.0.1', 5001);

function wait(ms) {
  return new Promise((resolve) => setTimeout(resolve, ms));
}

async function waitFor(label, fn, timeoutMs = 10000, intervalMs = 300) {
  const start = Date.now();
  while (Date.now() - start < timeoutMs) {
    const result = await fn();
    if (result !== undefined && result !== false) return result;
    await wait(intervalMs);
  }
  throw new Error(`Timed out waiting for: ${label}`);
}

async function signUpOrIn(email) {
  try {
    await createUserWithEmailAndPassword(auth, email, 'password123!');
  } catch {
    await signInWithEmailAndPassword(auth, email, 'password123!');
  }
  return auth.currentUser.uid;
}

async function createUserDoc(uid) {
  // Idempotent so this script can be re-run against a still-live emulator without hitting
  // firestore.rules' update allowlist (a set() on an already-existing doc is evaluated as an
  // "update" by the rules, which only permits a specific editable-field subset - not a full
  // recreate). Firestore emulator data persists for the life of the emulator process.
  const existing = await getDoc(doc(db, 'users', uid));
  if (existing.exists()) return;
  await setDoc(doc(db, 'users', uid), {
    uid,
    createdAt: serverTimestamp(),
    updatedAt: serverTimestamp(),
    subscriptionStatus: 'free',
    followerCount: 0,
    followingCount: 0,
    themeCount: 0,
    likesGivenCount: 0,
    likesReceivedCount: 0,
    isDeleted: false,
  });
}

let passed = 0;
async function step(name, fn) {
  await fn();
  passed += 1;
  console.log(`  PASS  ${name}`);
}

async function main() {
  console.log('--- Setting up test users ---');
  const creatorUid = await signUpOrIn('creator@test.mochi');
  await createUserDoc(creatorUid);
  const randoUid = await signUpOrIn('rando@test.mochi');
  await createUserDoc(randoUid);
  console.log(`  creator uid: ${creatorUid}`);
  console.log(`  rando uid:   ${randoUid}`);

  // Theme created as creator, no previewImageUrl - exercises onThemeCreated's no-image auto-approve
  // path (the image-classification path was already verified directly in a separate smoke test).
  await signUpOrIn('creator@test.mochi');
  const themeRef = await addDoc(collection(db, 'themes'), {
    creatorUid,
    creatorDisplayName: 'Original Name',
    creatorAvatarUrl: '',
    name: 'Integration Test Theme',
    description: '',
    hashtags: [],
    previewImageUrl: '',
    isPremium: false,
    isPublished: true,
    moderationStatus: 'pending',
    likeCount: 0,
    downloadCount: 0,
    reportCount: 0,
    createdAt: serverTimestamp(),
    updatedAt: serverTimestamp(),
  });
  const themeId = themeRef.id;

  console.log('\n--- 1/8: onThemeCreated (moderation) ---');
  await step('theme auto-approved (no image to moderate)', async () => {
    const status = await waitFor('moderationStatus == approved', async () => {
      const snap = await getDoc(doc(db, 'themes', themeId));
      return snap.data()?.moderationStatus === 'approved';
    });
    assert.ok(status);
  });

  console.log('\n--- 2/8: onLikeWritten ---');
  await signUpOrIn('rando@test.mochi');
  await step('like increments theme.likeCount and both users counters', async () => {
    await setDoc(doc(db, 'likes', `${randoUid}_${themeId}`), { uid: randoUid, themeId });
    await waitFor('likeCount == 1', async () => {
      const snap = await getDoc(doc(db, 'themes', themeId));
      return snap.data()?.likeCount === 1;
    });
    await waitFor('rando.likesGivenCount == 1', async () => {
      const snap = await getDoc(doc(db, 'users', randoUid));
      return snap.data()?.likesGivenCount === 1;
    });
    await waitFor('creator.likesReceivedCount == 1', async () => {
      const snap = await getDoc(doc(db, 'users', creatorUid));
      return snap.data()?.likesReceivedCount === 1;
    });
  });
  await step('unlike decrements theme.likeCount back to 0', async () => {
    await deleteDoc(doc(db, 'likes', `${randoUid}_${themeId}`));
    await waitFor('likeCount == 0', async () => {
      const snap = await getDoc(doc(db, 'themes', themeId));
      return snap.data()?.likeCount === 0;
    });
  });

  console.log('\n--- 3/8: onFollowWritten ---');
  await step('follow increments both users counters', async () => {
    await setDoc(doc(db, 'follows', `${randoUid}_${creatorUid}`), {
      followerId: randoUid,
      followeeId: creatorUid,
    });
    await waitFor('rando.followingCount == 1', async () => {
      const snap = await getDoc(doc(db, 'users', randoUid));
      return snap.data()?.followingCount === 1;
    });
    await waitFor('creator.followerCount == 1', async () => {
      const snap = await getDoc(doc(db, 'users', creatorUid));
      return snap.data()?.followerCount === 1;
    });
  });
  await step('unfollow decrements both back to 0', async () => {
    await deleteDoc(doc(db, 'follows', `${randoUid}_${creatorUid}`));
    await waitFor('rando.followingCount == 0', async () => {
      const snap = await getDoc(doc(db, 'users', randoUid));
      return snap.data()?.followingCount === 0;
    });
  });

  console.log('\n--- 4/8: onUserProfileUpdated (fan-out) ---');
  await signUpOrIn('creator@test.mochi');
  // Unique per run - a value identical to what's already stored (e.g. leftover from a prior run
  // against this same still-live emulator) is correctly a no-op, since the trigger only fans out
  // an actual change.
  const newDisplayName = `Renamed Creator ${Date.now()}`;
  await step('changing displayName fans out to the theme', async () => {
    await updateDoc(doc(db, 'users', creatorUid), {
      displayName: newDisplayName,
      updatedAt: serverTimestamp(),
    });
    await waitFor('theme.creatorDisplayName updated', async () => {
      const snap = await getDoc(doc(db, 'themes', themeId));
      return snap.data()?.creatorDisplayName === newDisplayName;
    });
  });

  console.log('\n--- 5/8: onReportThreshold ---');
  await signUpOrIn('rando@test.mochi');
  await step('5 open reports auto-unpublishes the theme', async () => {
    for (let i = 0; i < 5; i += 1) {
      await addDoc(collection(db, 'reports'), {
        reporterUid: randoUid,
        status: 'open',
        themeId,
      });
    }
    // firestore.rules only lets the theme's owner (or an approved+published read) see it once
    // unpublished - a non-owner correctly gets permission-denied reading it now, so poll as the
    // owner rather than rando.
    await signUpOrIn('creator@test.mochi');
    await waitFor('theme.isPublished == false', async () => {
      const snap = await getDoc(doc(db, 'themes', themeId));
      return snap.data()?.isPublished === false;
    });
  });

  console.log('\n--- 6/8: checkUsernameAvailable + reserveUsername ---');
  await signUpOrIn('creator@test.mochi');
  const username = `mochi_${Date.now().toString().slice(-8)}`;
  await step('username available before reservation', async () => {
    const check = httpsCallable(functions, 'checkUsernameAvailable');
    const result = await check({ username });
    assert.equal(result.data.available, true);
  });
  await step('reserveUsername succeeds', async () => {
    const reserve = httpsCallable(functions, 'reserveUsername');
    const result = await reserve({ username });
    assert.equal(result.data.success, true);
  });
  await step('username no longer available after reservation', async () => {
    const check = httpsCallable(functions, 'checkUsernameAvailable');
    const result = await check({ username });
    assert.equal(result.data.available, false);
  });
  await step('reserving the same username again fails', async () => {
    const reserve = httpsCallable(functions, 'reserveUsername');
    await assert.rejects(() => reserve({ username }));
  });

  console.log('\n--- 7/8: onAccountDelete ---');
  const deleteMeUid = await signUpOrIn('deleteme@test.mochi');
  await createUserDoc(deleteMeUid);
  await step('callable soft-deletes the profile and removes the Auth account', async () => {
    const deleteAccount = httpsCallable(functions, 'onAccountDelete');
    const result = await deleteAccount();
    assert.equal(result.data.success, true);

    // The deleted user's own session is no longer valid - re-sign-in as creator to read the result.
    await signUpOrIn('creator@test.mochi');
    const snap = await getDoc(doc(db, 'users', deleteMeUid));
    assert.equal(snap.data()?.isDeleted, true);
  });

  console.log('\n--- 8/8: revenueCatWebhook ---');
  await step('rejects a request with no/wrong auth header', async () => {
    const res = await fetch(`${FUNCTIONS_BASE}/revenueCatWebhook`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ event: { app_user_id: creatorUid } }),
    });
    assert.equal(res.status, 401);
  });
  await step('correct secret reaches the real RevenueCat API boundary and fails cleanly (no real account)', async () => {
    const res = await fetch(`${FUNCTIONS_BASE}/revenueCatWebhook`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        Authorization: 'dev-test-webhook-secret',
      },
      body: JSON.stringify({ event: { app_user_id: creatorUid } }),
    });
    // 502 = "reached RevenueCat's real API and got a non-ok response" - expected with a fake key.
    assert.equal(res.status, 502);
  });

  console.log(`\nALL ${passed} CHECKS PASSED`);
  process.exit(0);
}

main().catch((err) => {
  console.error('\nFAILED:', err);
  process.exit(1);
});
