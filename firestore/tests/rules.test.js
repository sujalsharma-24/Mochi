import { test, before, after } from 'node:test';
import assert from 'node:assert/strict';
import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import {
  initializeTestEnvironment,
  assertFails,
  assertSucceeds,
} from '@firebase/rules-unit-testing';
import { doc, getDoc, setDoc, updateDoc, deleteDoc } from 'firebase/firestore';

const __dirname = path.dirname(fileURLToPath(import.meta.url));

let testEnv;

before(async () => {
  testEnv = await initializeTestEnvironment({
    projectId: 'mochi-rules-test',
    firestore: {
      rules: fs.readFileSync(path.join(__dirname, '..', 'firestore.rules'), 'utf8'),
      host: '127.0.0.1',
      port: 8080,
    },
  });
});

after(async () => {
  await testEnv.cleanup();
});

function asUser(uid) {
  return testEnv.authenticatedContext(uid).firestore();
}

function asGuest() {
  return testEnv.unauthenticatedContext().firestore();
}

async function seed(setupFn) {
  await testEnv.withSecurityRulesDisabled(async (ctx) => {
    await setupFn(ctx.firestore());
  });
}

test('deny-by-default: an undeclared collection is fully closed', async () => {
  const db = asUser('alice');
  await assertFails(getDoc(doc(db, 'somethingNotInSchema/doc1')));
  await assertFails(setDoc(doc(db, 'somethingNotInSchema/doc1'), { x: 1 }));
});

test('users: can create own profile only with safe server-owned defaults', async () => {
  const db = asUser('alice');
  await assertSucceeds(setDoc(doc(db, 'users/alice'), {
    uid: 'alice', createdAt: 1, updatedAt: 1,
    subscriptionStatus: 'free', followerCount: 0, followingCount: 0,
    themeCount: 0, likesGivenCount: 0, likesReceivedCount: 0, isDeleted: false,
  }));
});

test('users: cannot self-grant a premium subscription on create', async () => {
  const db = asUser('mallory');
  await assertFails(setDoc(doc(db, 'users/mallory'), {
    uid: 'mallory', createdAt: 1, updatedAt: 1,
    subscriptionStatus: 'active', // the exact attack this rule exists to stop
  }));
});

test('users: cannot self-grant a premium subscription via update', async () => {
  await seed(async (db) => {
    await setDoc(doc(db, 'users/mallory'), {
      uid: 'mallory', subscriptionStatus: 'free', displayName: 'Mallory',
    });
  });
  const db = asUser('mallory');
  await assertFails(updateDoc(doc(db, 'users/mallory'), { subscriptionStatus: 'active' }));
  // but editing an actually-allowed field still works
  await assertSucceeds(updateDoc(doc(db, 'users/mallory'), { bio: 'hi', updatedAt: 2 }));
});

test('users: cannot write another user\'s profile', async () => {
  const db = asUser('mallory');
  await assertFails(updateDoc(doc(db, 'users/alice'), { bio: 'hacked' }));
});

test('themes: create must start at zero counters and pending moderation', async () => {
  const db = asUser('creator1');
  await assertSucceeds(setDoc(doc(db, 'themes/theme1'), {
    creatorUid: 'creator1', name: 'Test Theme', moderationStatus: 'pending',
    likeCount: 0, downloadCount: 0, reportCount: 0,
  }));
  await assertFails(setDoc(doc(db, 'themes/theme2'), {
    creatorUid: 'creator1', name: 'Sneaky', moderationStatus: 'approved', // skip moderation
    likeCount: 0, downloadCount: 0, reportCount: 0,
  }));
});

test('themes: client cannot directly inflate likeCount', async () => {
  await seed(async (db) => {
    await setDoc(doc(db, 'themes/theme1'), {
      creatorUid: 'creator1', name: 'Test Theme', moderationStatus: 'approved',
      isPublished: true, likeCount: 5, downloadCount: 0, reportCount: 0,
    });
  });
  const db = asUser('creator1');
  await assertFails(updateDoc(doc(db, 'themes/theme1'), { likeCount: 999999 }));
});

test('likes: cannot create a like on someone else\'s behalf (uid spoofing)', async () => {
  const db = asUser('mallory');
  await assertFails(setDoc(doc(db, 'likes/alice_theme1'), {
    uid: 'alice', themeId: 'theme1', createdAt: 1, // uid doesn't match the caller
  }));
});

test('likes: a genuine like create/delete by the real owner succeeds', async () => {
  const db = asUser('alice');
  await assertSucceeds(setDoc(doc(db, 'likes/alice_theme1'), {
    uid: 'alice', themeId: 'theme1', createdAt: 1,
  }));
  await assertSucceeds(deleteDoc(doc(db, 'likes/alice_theme1')));
});

test('weeklyStats leaderboard: publicly readable, never client-writable', async () => {
  await seed(async (db) => {
    await setDoc(doc(db, 'weeklyStats/2026-W30/creators/creator1'), { likeCount: 10 });
  });
  await assertSucceeds(getDoc(doc(asGuest(), 'weeklyStats/2026-W30/creators/creator1')));
  await assertFails(setDoc(doc(asUser('creator1'), 'weeklyStats/2026-W30/creators/creator1'), { likeCount: 99999 }));
});
