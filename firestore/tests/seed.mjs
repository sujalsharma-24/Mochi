/**
 * Seeds a handful of real `themes/{id}` docs into the Firebase Local Emulator Suite so the Android
 * app's ThemeRepository (android/app/.../data/ThemeRepository.kt) has something to actually query.
 * Reuses this folder's existing @firebase/rules-unit-testing devDependency rather than adding a
 * separate firebase-admin setup - withSecurityRulesDisabled() lets a seed script write data that
 * would normally only be legal via Cloud Functions (isPublished/approved/counters), the same way a
 * real onThemePublish-approval flow eventually will.
 *
 * Usage: `firebase emulators:start` in one terminal (repo root), then `npm run seed` here in
 * another. Requires the emulator to already be running - this does not start it.
 */
import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import { initializeTestEnvironment } from '@firebase/rules-unit-testing';
import { doc, setDoc, Timestamp } from 'firebase/firestore';

const __dirname = path.dirname(fileURLToPath(import.meta.url));

// Must match the app's real Firebase project id (android/app/google-services.json's
// project_info.project_id) - the emulator suite runs in singleProjectMode (firebase.json), which
// locks to whichever project id it's started with, and the app's default FirebaseApp now takes
// its project id from google-services.json rather than a fake "demo-" id.
const PROJECT_ID = 'mochi-940bd';

const themes = [
  {
    id: 'seed-fantasy-castle-night',
    creatorUid: 'seed-creator-mochi-studio',
    creatorDisplayName: 'Mochi Studio',
    creatorAvatarUrl: '',
    name: 'Fantasy Castle Night',
    description: 'A dreamy purple night castle theme.',
    hashtags: ['fantasy', 'night', 'purple'],
    previewImageUrl: '',
    isPremium: true,
    likeCount: 12500,
    downloadCount: 4200,
  },
  {
    id: 'seed-space-vibe',
    creatorUid: 'seed-creator-sakura',
    creatorDisplayName: 'sakura',
    creatorAvatarUrl: '',
    name: 'Space Vibe',
    description: 'Aesthetic starfield keyboard theme.',
    hashtags: ['space', 'aesthetic'],
    previewImageUrl: '',
    isPremium: false,
    likeCount: 9800,
    downloadCount: 3100,
  },
  {
    id: 'seed-cozy-sakura-cafe',
    creatorUid: 'seed-creator-lemonade',
    creatorDisplayName: 'Lemonade',
    creatorAvatarUrl: '',
    name: 'Cozy Sakura Cafe',
    description: 'A soft green theme with cute frogs and nature vibes.',
    hashtags: ['cute', 'nature', 'green'],
    previewImageUrl: '',
    isPremium: true,
    likeCount: 956,
    downloadCount: 210,
  },
  {
    id: 'seed-pastel-rainbow',
    creatorUid: 'seed-creator-elite-themes',
    creatorDisplayName: 'Elite Themes',
    creatorAvatarUrl: '',
    name: 'Pastel Rainbow',
    description: 'Bright pastel rainbow gradient keyboard.',
    hashtags: ['rainbow', 'pastel'],
    previewImageUrl: '',
    isPremium: false,
    likeCount: 8200,
    downloadCount: 2600,
  },
];

// The locked feature spec calls for "5 animated wallpapers at launch (all premium)", but this seed
// mixes in one free wallpaper so both the locked and unlocked WallpaperExploreScreen states are
// actually exercisable against the emulator - same reasoning the `themes` seed mix above uses.
// Ids intentionally match android/.../features/wallpapers/WallpaperExploreScreen.kt's bundled
// wallpaperArt map keys so the real Firestore-backed grid renders the same art as the MockData
// fallback, not a placeholder box.
const liveWallpapers = [
  { id: 'wallpaper_cloudy_day', name: 'Cloudy Day', previewUrl: '', assetUrl: '', isPremium: true },
  { id: 'wallpaper_sakura_dream_wp', name: 'Sakura Dream', previewUrl: '', assetUrl: '', isPremium: false },
  { id: 'wallpaper_galaxy_explorer', name: 'Galaxy Explorer', previewUrl: '', assetUrl: '', isPremium: true },
  { id: 'wallpaper_pastel_dreams', name: 'Pastel Dreams', previewUrl: '', assetUrl: '', isPremium: true },
  { id: 'wallpaper_rainbow_bliss', name: 'Rainbow Bliss', previewUrl: '', assetUrl: '', isPremium: true },
];

async function main() {
  const testEnv = await initializeTestEnvironment({
    projectId: PROJECT_ID,
    firestore: {
      rules: fs.readFileSync(path.join(__dirname, '..', 'firestore.rules'), 'utf8'),
      host: '127.0.0.1',
      port: 8080,
    },
  });

  await testEnv.withSecurityRulesDisabled(async (context) => {
    const firestore = context.firestore();
    const now = Timestamp.now();
    for (const theme of themes) {
      const { id, ...data } = theme;
      await setDoc(doc(firestore, 'themes', id), {
        ...data,
        reportCount: 0,
        isPublished: true,
        moderationStatus: 'approved',
        createdAt: now,
        updatedAt: now,
      });
    }
    for (const wallpaper of liveWallpapers) {
      const { id, ...data } = wallpaper;
      await setDoc(doc(firestore, 'liveWallpapers', id), data);
    }
  });

  console.log(`Seeded ${themes.length} themes and ${liveWallpapers.length} live wallpapers into the '${PROJECT_ID}' emulator project.`);
  await testEnv.cleanup();
}

main().catch((err) => {
  console.error(err);
  process.exitCode = 1;
});
