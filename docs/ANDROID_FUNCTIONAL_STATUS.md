# Mochi Android — Functional Build Status

**Last updated:** 2026-08-19 (Session 23)
**Scope:** This tracks the WA0–WA9 workstream plan for making the Android companion app functional —
real Firebase Auth/Firestore/Storage data and real Cloud Functions logic behind every screen.

**Explicitly out of scope for this whole plan:** wiring a user-selected theme into the keyboard's
actual live rendering (`MochiInputMethodService`), and all other IME-internals work — autocorrect
engine, swipe typing, particle effects, custom fonts rendered in-keyboard, emoji/sticker panel, Full
Access handling. The IME currently types with one hardcoded theme; that stays as-is except where WA6
explicitly enforces a settings toggle inside it (haptics/key-click sound).

---

## At a glance

| Workstream | What it covers | Status |
|---|---|---|
| WA0 | Foundation (App Check, RevenueCat SDK) | Code done — blocked on account setup |
| WA1 | Firestore data model | ✅ Done |
| WA2 | Repository layer | ✅ Done |
| WA3 | Cloud Functions backend | ✅ Done, verified against emulator — **not deployed to the live project** |
| WA4 | Screen-by-screen real data wiring | ✅ Done — all 10 screens |
| WA5 | Push notifications | 🔄 In progress — slice 1 built, not device-verified |
| WA6 | Loading/empty/error states + settings enforcement in the IME | ✅ Done |
| WA7 | Moderation tooling (admin review) | ⏳ Not started — surveyed only |
| WA8 | Testing | 🔄 Partial |
| WA9 | Play Store prep | ⏳ Not started |

---

## ✅ Completed

### WA1 — Firestore data model
`ThemeDocument` carries `backgroundType`/`backgroundConfig`/`keysConfig`/`fontsConfig`/`effectsConfig`,
matching `firestore.rules`' update allowlist field-for-field. Profile-related counts (stats, likes,
downloads) are real `Int`s read from Firestore, formatted for display at render time.

### WA2 — Repository layer
Repositories: `UserRepository`, `ThemeRepository`, `WallpaperRepository`, `LikeRepository`,
`FollowRepository`, `BlockRepository`, `ReportRepository`, `CreateRepository`, `StorageRepository`,
`SettingsRepository`, `SearchHistoryRepository`, `WallpaperLibraryRepository`, `BillingRepository` —
all wired into a manual `AppContainer` (no DI framework; revisit only if this grows unwieldy).

### WA3 — Cloud Functions backend
11 functions, all built and integration-tested against the local emulator (`functions/test/integration.mjs`,
14 passing checks) — **not yet deployed to the live project**, blocked on the Blaze billing setup below.

| Function | Trigger | What it does |
|---|---|---|
| `onLikeWritten` | Firestore write on `likes/{id}` | Updates like counters, weekly leaderboard fan-out |
| `onFollowWritten` | Firestore write on `follows/{id}` | Updates follower/following counters |
| `onUserProfileUpdated` | Firestore update on `users/{uid}` | Fans denormalized creator identity out to their themes |
| `onThemeCreated` | Firestore create on `themes/{id}` | nsfwjs auto-moderation → `approved`/`rejected` |
| `onReportThreshold` | Firestore create on `reports/{id}` | Auto-unpublishes a theme after 5+ open reports |
| `onThemePublished` | Firestore update on `themes/{id}` | Pushes "new theme" to followers (WA5) |
| `revenueCatWebhook` | HTTP | Subscription entitlement updates |
| `onAccountDelete` | Callable | Soft-deletes profile, unpublishes themes, deletes the real Auth account |
| `checkUsernameAvailable` / `reserveUsername` | Callable | Username reservation |
| `sendPhoneOtp` / `verifyPhoneOtp` | Callable | Twilio SMS OTP sign-in |

UGC image moderation uses **nsfwjs** (free, fully local, pure-JS `@tensorflow/tfjs` backend) instead of
Google Cloud Vision — a deliberate zero-paid-service call.

### WA4 — Screen-by-screen real data wiring
Every screen now reads/writes real Firestore data instead of `MockData`. Fonts is the one deliberate
exception (fonts are a fixed built-in catalog on both platforms, not Firestore documents, so there's no
separate "real" data to wire).

| Screen | Real since | Notes |
|---|---|---|
| Home | Session 9 | First real Firestore-backed screen (predates the WA plan) |
| Themes + Theme Detail | WA4 slice 1 | Real feed, real Like button |
| Community | WA4 slice 2 | 5 feed tabs, real Follow, Report → `reports/{id}` |
| Create & Publish | WA4 slice 3 | Save Draft / Publish both write real `themes/{id}` docs |
| Profile (own + other) | WA4 slice 4 | Follow/Block real; own-profile falls back to MockData only on load error |
| Settings (Account + Keyboard) | WA4 slice 5 / WA6 | Log Out, Delete Account, 4 keyboard toggles |
| Paywall | WA4 slice 6 | Real RevenueCat offerings fetch + entitlement gating (purchase itself untestable until a real API key exists) |
| Search | WA4 slice 7 | Live substring filter over a bounded pool (no paid search service) |
| Leaderboard | WA4 slice 8 | This Week (real `weeklyStats`), All Time (real); This Month reuses All Time — no monthly aggregate exists in the schema |
| Wallpapers | WA4 slice 9 | Real `liveWallpapers` grid; Download is local-only (no server-side action exists — collection is read-only) |

### WA6 — Loading/empty/error states + settings enforcement
Every WA4 screen follows the same loading/empty/error/MockData-fallback pattern established by Home.
`MochiInputMethodService` reads `hapticFeedbackEnabled`/`keyClickSoundEnabled` from the same
`SettingsRepository` DataStore the Settings screen writes to, and gates real key-press feedback on
them. Autocorrect/swipe-typing toggles persist but have no runtime effect — neither has an IME engine
to gate (out of this whole plan's scope).

---

## 🔄 In Progress

### WA5 — Push notifications (slice 1 of 4 categories)
The feature spec names 4 notification categories. Slice 1 covers the one that needed no new
infrastructure beyond FCM itself:

- ✅ **Built**: `firebase-messaging` SDK, notification channel, `POST_NOTIFICATIONS` runtime permission,
  real `fcmToken`/`notificationsEnabled` fields on `UserDocument`, Settings' Notifications toggle wired
  to Firestore for real, and a new `onThemePublished` Cloud Function that notifies a creator's
  followers exactly when a theme becomes publicly visible.
- ✅ **Verified**: clean Kotlin compile, clean TypeScript build, a full Firestore rules-test pass
  (10/10) against a real local emulator.
- ❌ **Not verified**: no actual push has been sent or received. There's no local FCM emulator, and
  this machine has no Google credentials (`gcloud`, ADC, or a logged-in Firebase CLI) for the local
  Functions emulator to reach the real FCM API.

**Blocked on, checklist:**
1. *(Sujal)* Upgrade `mochi-940bd` to the Blaze plan in Firebase Console.
2. *(Sujal)* Set a Google Cloud billing budget alert **before** any deploy — Blaze has no default cap.
3. *(Sujal)* Confirm 1–2 are done so the Firebase CLI can be authorized on this machine.
4. *(Assistant)* `firebase deploy --only functions`, point the app at the live project, verify a real
   push arrives on-device with two accounts (one following the other).

This also unblocks real Paywall purchase testing and real Twilio SMS delivery, both sitting on the
same Blaze prerequisite — the plan is to verify all three once unblocked, not just push notifications.

**Deferred to a later WA5 slice:** weekly-leaderboard update notifications (needs new scheduled-function
infrastructure — this codebase has never built an `onSchedule` function), new-feature announcements
(needs an admin-broadcast mechanism, not just a trigger), subscription reminders (blocked on
RevenueCat's still-placeholder API key).

### WA8 — Testing
Covered so far: `functions/test/integration.mjs` (14 Cloud Function checks) and
`firestore/tests/rules.test.js` (10 Firestore Security Rules checks), both run against the local
emulator. No dedicated Android-side test suite yet (theme-recipe round-trip, entitlement logic, etc.).

---

## ⏳ Not started

### WA7 — Moderation tooling
Surveyed (not built). Finding: the auto-moderation system currently has **no way to reverse itself**.
`onThemeCreated` (nsfwjs) and `onReportThreshold` (5+ reports auto-unpublish) can only ever hide or
reject a theme — nothing in the codebase can undo that. There's also no admin/moderator identity
concept anywhere (no custom claims, no role field), and `reports/{id}` is unreadable by anyone,
including a would-be moderator. Two ways to close this, not yet decided with Sujal:

1. **Manual Firebase Console process** — zero new code; an admin edits `moderationStatus`/`isPublished`
   directly in the console (bypasses rules via console credentials). Needs the `'pending'`-vs-`'hidden'`
   status collision fixed first so a browsing admin can tell "brand new draft" apart from "auto-hidden
   for reports."
2. **Small admin web page** — real build work: an admin identity mechanism, a scoped `reports` read
   exception, and an approve/reject callable.

### WA9 — Play Store prep
Not started — lower priority since iOS ships to app stores first per the locked release-order
decision. Doesn't block "make Android functional."

---

## Known blockers (need Sujal or the client)

| Blocker | Blocks |
|---|---|
| Blaze billing plan + budget alert on `mochi-940bd` | Live Cloud Functions deploy, real push notifications, real Paywall purchases, real Twilio SMS |
| Real RevenueCat account + API key | Real subscription purchase/restore testing |
| App Check Play Integrity toggle (Firebase Console) | Release-signed builds (Debug provider works for every sideload today) |
| Cloudflare CDN setup | Not yet blocking anything actively built |
| Confirm `com.Adam.Mochi` reads as a placeholder name with the client | Cosmetic — before launch only |
| Stickers source decision (client art / licensed pack / user-upload) | Not blocking until the sticker panel is built |

## Other outstanding items

- **Uncommitted "Bubble Tea" IME theme work** has been sitting in the working tree since Session 15
  (10 sessions now) — real keyboard-rendering work that falls outside this plan's scope by design.
  Left untouched and uncommitted per Sujal's standing instruction; needs a decision eventually (commit
  it as its own piece of work, or discard).
- **WA7's tradeoff** (manual console process vs. admin web page) is queued up but not yet decided.
