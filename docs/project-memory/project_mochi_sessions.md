---
name: project-mochi-sessions
description: "Chronological session log for Mochi — what was done, decided, and changed each session"
metadata: 
  node_type: memory
  type: project
  originSessionId: f7b11015-d7e5-40a3-9089-fe2f54d48fee
---

# Mochi — Session Log

---

## Session 1 — Product Discovery & Feature Scoping
**Date:** July 8, 2026
**Duration:** Long session (ran out of context, continued in second window)
**Stage:** Pre-development — requirements gathering and feature finalization

### What Happened
- User (Sujal) briefed assistant on the project: Australian client, $425 budget, 3-week timeline, keyboard theme social app
- Full proposal PDF reviewed (5 pages, client-approved, June 2026)
- Figma design link provided by client (all screens, one design for both platforms, includes app icon)
- Iterative Q&A across multiple rounds to extract all requirements
- Research agent (Opus model) generated 100 detailed questions across 21 categories
- Fable advisory agent reviewed questions and gave verdicts (Must Keep / Simplify / Defer / Cut)
- 14 blocking decisions identified and all resolved in this session

### Decisions Made This Session
All 14 open decisions locked — see [[project-mochi-decisions]] for full table.

Key calls:
- Pricing decided by assistant: $2.99/month · $19.99/year · 3-day trial
- UGC moderation decided by assistant: Google Cloud Vision API + Report button
- Effects tab: in V1 (client confirmed)
- No comments, no guest mode, iOS first

### Corrections Made This Session
See [[project-mochi-changelog]] for full correction log.

### Status at End of Session
- All features locked ✅
- All platform/OS decisions locked ✅
- All monetization decisions locked ✅
- One item deferred: stickers source (not blocking)
- Ready to begin: architecture planning → UI implementation → testing

### Next Session Goals
- Decide stickers source
- Begin architecture/implementation planning
- Set up Firebase project + required accounts
- Review Figma and map screens to feature spec

---

## Session 2 — Technical Requirements Document (Deep Research)
**Date:** July 9, 2026
**Duration:** Medium (research-heavy, 5 parallel web-research agents)
**Stage:** Pre-development — architecture and technical planning

### What Happened
- Ran `/deep-research` to produce a full TRD before any code is written
- Departed from the skill's default "compare N items" pipeline since this was one interdependent system design, not independent research items
- Dispatched 5 parallel research agents: Apple App Store keyboard/UGC compliance, RevenueCat/Branch.io current status, Firebase+Vision cost modeling, Australian/international privacy compliance, iOS keyboard-extension memory constraints
- Synthesized into `docs/TRD.md` + published Artifact — see [[project-mochi-trd]] for full content

### Decisions Made This Session
- Architecture: Serverless BaaS (Firebase-direct + Cloud Functions), no REST/GraphQL, no custom backend
- SwiftUI (main app) + UIKit/SpriteKit (keyboard extension)
- Weekly leaderboard design resolved concretely (per-week Firestore subcollection)
- Two environments only (dev/prod, no staging)
- Full details in [[project-mochi-trd]]

### Corrections Made This Session
- Memory ceiling: 60-70MB (client-stated) → ~40MB (empirical, corrected)
- Effects tech: Core Animation → SpriteKit (corrected)
- Deep links: Branch.io option removed → native Universal/App Links only (Branch.io lost its free tier July 2025)
- New scope item: Block-user feature added (Apple UGC requirement, was missing from spec)

### Status at End of Session
- All architecture, data model, API, and compliance decisions locked ✅
- TRD published as Artifact for Sujal to review ✅
- Ready to begin: Firestore security rules + Cloud Functions scaffolding, then iOS implementation

### Next Session Goals
- Firestore security rules (highest-priority security work per TRD §01)
- Confirm Block-user feature addition with client (minor scope note)
- Decide stickers source (still deferred from Session 1)
- Begin iOS project scaffolding per TRD §07 folder structure

---

## Session 2b — TRD Full Redo (Deep Research, same day)
**Date:** July 9, 2026
**Duration:** Medium (5 parallel research agents, same pattern as Session 2)
**Stage:** Pre-development — architecture verification

### What Happened
- Sujal asked to use `/deep-research` again to fully redo the TRD from scratch (not review/patch v1) a few hours after Session 2 produced v1
- Flagged to Sujal first that v1 already covered everything asked — he chose "full redo from scratch" anyway
- Departed from the deep-research skill's default outline/items pipeline again (same reasoning as Session 2 — one interdependent system design, not comparable independent items)
- Dispatched 5 parallel research agents re-verifying every load-bearing claim in v1: architecture patterns, iOS/Android keyboard-extension tech specifics, Firestore data/API layer, cost/security/compliance, engineering conventions/CI-CD
- Synthesized into TRD v2 (`docs/TRD.md`, overwritten in place) + republished Artifact

### Decisions Made / Changed This Session
Six corrections to v1, all in [[project-mochi-changelog]] CHANGE-008 through CHANGE-014 and [[project-mochi-trd]]:
- Keyboard particle effects: SpriteKit → reversed back to Core Animation (`CAEmitterLayer`)
- Memory ceiling tightened: ~30-40MB dirty / ~77MB total / ~55MB warning (was a flat "~40MB")
- App Check: gap → concrete decision (App Attest iOS + Play Integrity Android, free at this scale)
- New finding, wasn't in v1 at all: `functions.config()` deprecated, must use `defineSecret()`/Secret Manager from day one
- New finding: GitHub Actions macOS runners cost ~10x Linux — workflows must be path-filtered from day one
- Age rating: corrected from "13+" to 17+/18+-equivalent for UGC apps
- Plus one schema gap caught (not a correction): `themes` docs need denormalized `creatorDisplayName`/`creatorAvatarUrl`, not just `creatorUid`, to avoid an N+1 read problem in the feed

Everything else in v1 was independently reconfirmed, in several cases with better sources.

### Status at End of Session
- TRD v2 is the current source of truth — supersedes v1 (v1's content is fully superseded, v2 documents what changed and why)
- Ready to begin: Firestore security rules + Cloud Functions scaffolding, then iOS implementation

### Next Session Goals
- Same as Session 2's next-goals, now against v2: Firestore security rules first, confirm Block-user + stickers-source with client (stickers-source now has a concrete compliance reason to resolve — Apple Sticker Guidelines apply directly), begin iOS scaffolding per TRD §07

---

## Session 3 — UI-First Build Kickoff (iOS)

**Date:** July 10-11, 2026
**Duration:** Long
**Stage:** iOS implementation — UI layer, no backend wiring yet

### What Happened
- Sujal chose to build UI-first, backend-later (departs from Session 2b's plan to do Firestore rules/Functions first — he wants to see the app take shape before wiring data)
- Sujal provided the actual Figma export as a zip (`mochi.zip`, 13 numbered screen PNGs + icon assets), extracted to `docs/figma/`
- All 13 screens reviewed and mapped against the locked feature spec — see [[project-mochi-decisions]] for the mapping table and the nav-structure correction
- Discovered the real bottom-nav structure is 5 tabs (Keyboard, Fonts, Create, Themes, Community), not the single combined Explore/Store assumed from the written spec — Figma wins per the standing rule
- Discovered a serious paywall conflict: Figma screens 11/12 show $199/mo, $999/yr, $1999 lifetime pricing plus a custom UPI/Card/GPay/PhonePe/Paytm payment form. This contradicts the locked $2.99/$19.99 RevenueCat decision AND would violate Apple App Store Guideline 3.1.1 (no custom payment collection for digital subscriptions) — very likely an unmodified template frame, not a deliberate client choice. Sujal confirmed: build to the locked spec, ignore the Figma numbers/payment UI.
- Confirmed 3 screens have no Figma source at all: Splash/Onboarding, Auth, standalone Theme Detail. Sujal chose to have these designed now (matching the existing visual style) rather than wait on the client.
- Flagged and confirmed a platform constraint: dev machine is Windows, and Xcode (required for any iOS build/compile/preview) is Mac-only. Sujal confirmed he has Mac/cloud-Mac access, so code was written blind (unverified) with the expectation he'll open it in Xcode himself.
- `git init` run in the project root (was not a git repo before this session)
- Built the iOS project as XcodeGen-driven (`ios/project.yml`) rather than a hand-authored `.xcodeproj`, since a binary/plist Xcode project file can't be reliably authored without Xcode itself — Sujal runs `xcodegen generate` once on his Mac to produce the real project
- Built out: design tokens (colors/gradients/typography sampled from the Figma exports), mock data layer, reusable components (theme card, gradient buttons, custom tab bar with center FAB, vector keyboard-preview placeholder since no isolated per-theme art assets exist), and 5 of the main screens (Home, Fonts, Themes, Community, Create) — Home is full-depth, the other 4 are a solid first pass (missing some Figma chrome like search bars/filter chips/leaderboard sub-screen)

### Decisions Made This Session
- UI-first build order (backend deferred) — Sujal's explicit call, overriding the TRD-session's original "security rules first" plan
- Paywall: build to locked $2.99/$19.99/RevenueCat spec, not the Figma placeholder numbers/payment form
- Missing screens (Splash, Auth, Theme Detail): design now matching existing style, don't block on client
- iOS project tooling: XcodeGen (`project.yml`) instead of a committed `.xcodeproj`

### Status at End of Session
- `docs/figma/` has all 13 client-provided screens for reference
- `ios/` has a buildable-in-principle SwiftUI app (Home, Fonts, Themes, Community, Create tabs) — **unverified**, no compile has been run since this is a Windows machine
- Not yet built: Profile, Settings, Paywall, Splash/Onboarding, Auth, standalone Theme Detail
- Nothing committed to git yet (repo initialized but no commits) — Sujal hasn't asked for a commit

### Next Session Goals
- Sujal opens the project in Xcode (`xcodegen generate` in `ios/`) and reports back whether it actually compiles — first real compile check, likely to surface issues since this was written blind
- Continue UI build: Profile, Settings, Paywall, Splash/Onboarding, Auth, Theme Detail
- Polish pass on the 5 existing screens toward tighter Figma parity (search bars, filter chips, leaderboard as its own screen, apply-theme modal)
- Backend work (Firestore rules, Cloud Functions, data wiring) remains deferred until the UI pass is far enough along — revisit sequencing then

---

## Session 4 — Home Screen Figma Parity (Android UI Polish)
**Date:** July 2026 (between Session 3 and Session 5)
**Duration:** Short (focused pixel-parity pass)
**Stage:** iOS/Android UI — Figma parity polish on Home screen

### What Happened
- Focused polish pass on the Home screen action-card component to match Figma measurements exactly
- Fixed action-card subtitle color (was rendering gray; Figma shows it near-black)
- Fixed action-card icon alignment and icon-text gap (pixel-measured vs Figma)
- Re-measured and corrected action-card icon/text and toggle button sizes vs Figma
- Replaced Material's default button with a custom slim pill button to fix action-card overflow
- Commits: `bc3235e`, `051dcfa`, `8ad3ab8`, `168713d`
- Session marker commit: `6cf4b0f session: home-screen-figma-parity [standalone-ef2fd53b]`

### Decisions Made This Session
- Custom slim pill button component created for action cards — replaces Material default which caused overflow

### Status at End of Session
- Home screen action-card component improved toward Figma, but **not confirmed pixel-perfect** — see Session 6, which continued this exact work for 9+ more iteration rounds and still ended without final user confirmation. Correcting an earlier overstatement here: "matches Figma at pixel level" was premature.
- Other screens still at first-pass quality (Session 3's "solid first pass")

### Next Session Goals
- Continue UI build: Profile, Settings, Paywall, Splash/Onboarding, Auth, Theme Detail
- Polish remaining screens toward Figma parity
- First Xcode compile check (still pending from Session 3)

---

## Session 5 — Product Finalization + Memory System Creation
**Date:** July 16, 2026
**Duration:** Medium
**Stage:** Product finalization, project management tooling

### What Happened
- Resumed from a context-limit break mid-session (previous session ran out of context window)
- Explained the Effects tab to Sujal (key-press effects, background effects, trail effects)
- Locked final outstanding decisions: Effects tab in V1, pricing confirmed ($2.99/$19.99), UGC moderation confirmed (Google Cloud Vision + Report button)
- Created the full project memory system from scratch: 9 memory files + MEMORY.md index
- Created `/sync-memory` skill at user level (`~/.claude/commands/sync-memory.md`) and project level

### Decisions Made This Session
- Effects tab: **in V1** (client confirmed after effects were explained)
- All prior pricing and UGC moderation decisions confirmed (delegated to assistant in prior session, confirmed now)
- Memory system structure and skill created

### Status at End of Session
- All 14+ blocking decisions locked ✅
- Complete memory system live ✅
- `/sync-memory` skill available across all projects ✅
- One item still deferred: stickers source

### Next Session Goals
- Decide stickers source (only remaining open item)
- Continue UI build: Profile, Settings, Paywall, Splash, Auth, Theme Detail
- First Xcode compile check — Sujal opens project in Xcode, reports back
- Firestore security rules (deferred backend work)

---

## Session 6 — Physical Device Testing + Extended Home Screen Figma-Parity Loop
**Date:** July 16, 2026
**Duration:** Very long (device setup + 9+ iteration rounds on one screen)
**Stage:** Android UI — device verification, Home screen pixel-parity (unresolved)

### What Happened
- Got the compiled Android app running click-through-able on a real device (not just Compose `@Preview`): enabled USB debugging on Sujal's physical phone (model V2207), installed via `adb`/`gradlew installDebug`, confirmed full navigation flow works (Splash → Onboarding → Auth → 5-tab app).
- Found and fixed a real navigation bug via the phone screenshot: the Onboarding "Next" button's `onClick` always advanced straight to Auth regardless of which page was showing — only the button *label* was conditional on `isLastPage`, not the behavior. Fixed with `pagerState.animateScrollToPage(...)`.
- Started (but did not finish) setting up an Android emulator as a fallback to the phone: downloaded SDK cmdline-tools, `platforms;android-34`, and a system image — all installed successfully, but **no AVD was ever created**. Parked per Sujal's own call ("leave it, download later"), not a failure — just deprioritized once the phone worked.
- Then entered a long, iterative, screenshot-driven loop trying to get the **Home screen** to match `docs/figma/13.png` exactly, at Sujal's explicit request for pixel-perfect parity, iterating one round per screenshot he sent back. Roughly 9 distinct rounds this session alone (see the full handoff doc for blow-by-blow detail — this summary only hits the headline pattern):
  1. Rebuilt Home as a fixed, non-scrolling single-viewport layout (Sujal's explicit "no scrolling" requirement) using real Figma-cropped icon PNGs he provided.
  2. Compactness pass (action cards, bold toggle, sparkle decorations) — shipped two new bugs (invisible button text, sparkle overlapping a button), fixed both immediately.
  3. Structural relayout: icon-left/text-right action cards with a border outline (was stacked, borderless) — found via direct side-by-side crop comparison against Figma, not eyeballing whole screenshots.
  4. Fixed the two action cards rendering at different heights, oversized buttons, a "white border" that was actually an entire unwanted white card background, and non-rectangular font cards.
  5. Self-caught (without a new complaint) that "Popular Themes" was showing the exact same theme data as "Recently Applied" above it — a data-wiring bug, not a visual one.
  6. Sujal sent a detailed, CSS-flavored spec demanding shared components (flex/grid language, translated to Compose's `weight()`/`IntrinsicSize`/`Arrangement.SpaceBetween`) — extracted a genuinely shared `KeyboardPreviewCard` composable used by two different rows, so they can't drift apart again.
  7. 5 precise numbered fixes against the reference again (toggle default state, text alignment, softer button gradient, aspect ratio consistency between rows).
  8. Sujal switched to Hinglish. Found the "Mochi" logo's font was visibly wrong — Baloo 2 (used everywhere else) has pointed letter-peaks, Figma's wordmark is much rounder. Downloaded a second font (Fredoka, Google Fonts OFL) and scoped it to just the logo style.
  9. Did **precise Python/PIL pixel measurement** of a cropped Figma card for the first time this session (rather than eyeballing) — measured exact aspect ratios, icon-to-card-width ratios, and button proportions from real pixel coordinates. This resolved several complaints that earlier "close enough" attempts hadn't. Also found and fixed an app-wide bug: `SectionHeader`'s "see all" link used Android's default `TextButton`, which carries an invisible ~40dp minimum touch-target height that was silently padding out *every* section header in the entire app, not just Home.
  10. Most recent fix: discovered that an explicit `Modifier.height(24.dp)` on a button was being silently overridden by Material's own internal minimum-height behavior — the button was rendering taller than coded, overflowing its card and clipping text. Fixed by building a custom non-Material pill button. **This fix was pushed but never confirmed by Sujal before the session ended** — the conversation moved to closing out via `/handoff` before his next screenshot arrived.
- Wrote a full session handoff document (`plans/handoffs/HANDOFF_home-screen-figma-parity_2026-07-16.md`, chain `standalone-ef2fd53b`) capturing every round in far more detail than fits here, including exact pixel measurements, rejected approaches, and a commit-by-commit table — read that file, not just this summary, before continuing Home screen work.

### Decisions Made This Session
- Physical phone (not emulator) is the primary real-device test surface going forward — faster, no download/setup overhead, and Sujal already has it in hand. Emulator setup left half-done as a fallback only.
- Fredoka font added specifically for the "Mochi" wordmark style only — every other text style stays on Baloo 2. Scoped narrowly rather than a wholesale font swap.
- `SectionHeader`'s Material `TextButton` → plain clickable `Text` fix was applied globally (it's a shared component used by every screen), even though only Home had been re-verified against it by session's end.

### Status at End of Session — read this carefully
- **The Home screen Figma-parity work is NOT complete or confirmed**, despite ~9 rounds of fixes this session (and more in the session before it — see Session 4's corrected status above). Every round converged on *something* the user had flagged, but each fix reliably surfaced or exposed the next mismatch, and the very last fix shipped was never actually confirmed against a fresh screenshot.
- **This is the honest headline for future sessions: getting one screen to genuinely pixel-perfect match against a real Figma export took far longer and more rounds than expected, and still isn't done.** See the Learnings entry below for why, and don't assume any given round is "probably the last one."
- Full technical detail lives in the handoff doc, not repeated here — treat it as required reading before touching Home screen again.

### Next Session Goals
- **First and most important**: get Sujal's actual confirmation on the last pushed fix (custom slim pill button, commit `bc3235e`) via a fresh `HomeScreenPreview` screenshot — do not assume it's correct just because it built successfully.
- Continue the precise-pixel-measurement discipline (crop a clean isolated region of `docs/figma/13.png`, measure with Python/PIL, compute proportions algebraically) as the default approach for any further sizing disputes — it worked meaningfully better than eyeballing whole screenshots.
- Once Home is genuinely confirmed, move to the next screen in the queue — Sujal has said he'll guide screen-by-screen.
- Re-verify the `SectionHeader` fix on at least one or two other screens that use it (Community, Profile, Themes) — it was a global code fix but only visually re-checked on Home.

---

## Session 7 — Home Screen Figma-Parity, Round 3 (still unresolved)
**Date:** July 16, 2026
**Duration:** Medium-long (rigorous pixel measurement + comparison methodology work)
**Stage:** Android UI — Home screen pixel-parity (continued, still not confirmed)

### What Happened
- Resumed from Session 6's handoff (`plans/handoffs/HANDOFF_home-screen-figma-parity_2026-07-16.md`), which ended with commit `bc3235e` (custom `SlimPillButton` overflow fix) pushed but never confirmed by Sujal.
- Sujal sent a fresh screenshot of `bc3235e`: confirmed the subtitle-clipping bug was fixed, but said the action cards and FONTS/THEMES toggle still didn't match Figma, and asked specifically for icon sizes, text sizes, and toggle-button sizes to be corrected using real Figma measurements.
- Did a full pixel-measurement pass on `docs/figma/13.png` (cropped the action-card region, used Python/PIL + numpy to find exact bounding boxes for the card border, icon, title/subtitle cap-heights, button, and FONTS toggle text). Derived and shipped: icon 56dp→48dp, title 13sp→10sp, subtitle 10sp→9sp, card aspect ratio 1.55→1.83 (restored), card-to-card gap 16dp→8dp, action button 72dp→64dp/11sp→10sp, toggle text 14sp→16sp. Commit `051dcfa`, build succeeded, pushed.
- **Sujal corrected the reference file**: "compare it with 1.png not 13.png." Investigated and found `docs/figma/13.png` has a full-height black bezel/frame artifact on its right edge (~x=2164–2299, confirmed via column scan spanning the entire image height) that isn't part of the actual screen — it had been silently distorting any *absolute* px→dp scale calculation from that file. Cross-checked the action-card measurements against the clean `docs/figma/1.png` export and found them essentially identical (card border box 974×531 vs 974×534px, icon 272×219 vs 271×219px) — so the ratio-based fixes already shipped in `051dcfa` were still sound, but the file mix-up cost real time and should not have happened.
- Sujal said he'd save a fresh screenshot. Found it by searching `~/Pictures/Screenshots` for recent files — two showed up; one was an unrelated personal document (a Deloitte internship application form) that was correctly identified as irrelevant and not commented on further, the other was the actual `HomeScreenPreview` screenshot.
- Built a new comparison technique: cropped both the build screenshot and `docs/figma/1.png` to the *same dp range* (using each image's own measured px-per-dp ratio — 0.89 for the low-res build screenshot, 5.52 for the Figma export) and resized both to the same output width, producing two panels that are directly pixel-comparable despite coming from wildly different source resolutions.
- Findings from that matched-scale comparison:
  - Card aspect ratio now genuinely matches (1.845 rendered vs 1.83 target) — that part of `051dcfa` worked.
  - Title text is still undershooting Figma's size: the shipped 10sp produced a 13px cap-height at matched scale vs Figma's 15px, implying ~11–12sp is closer to correct. The 10sp figure had come from combining a measured cap-height ratio with an *assumed* cap-height-to-font-size constant (0.72) that turned out to be measurably wrong once checked against an actual render.
  - Subtitle text couldn't be reliably measured this way — it renders in a lighter gray (`textSecondary`) than the title/button's dark text, and a naive dark-pixel threshold undercounts it, so no clean correction was derived.
  - The action-card button text ("Create"/"Choose") visually and clearly renders smaller/fainter than Figma's bold black button text at matched scale — a real, visible gap that was **found but not fixed** before the conversation moved on.
- Sujal asked "have you updated the homescreen?" — confirmed 3 commits pushed this session (`051dcfa`, plus `8ad3ab8` icon-alignment/vertical-centering and `168713d` subtitle-color fixes, both made and committed but not visible in the assistant's own context window at time of reporting — confirmed via `git log`, not fabricated).
- Sujal's closing message this session: direct, blunt frustration that despite repeatedly asking for an exact Figma match, it still wasn't achieved — asked for an honest memory update covering both what was done and what wasn't accomplished.

### Decisions Made This Session
- `docs/figma/1.png` is the canonical reference file going forward, not `13.png` — `13.png` includes device-frame/bezel canvas that can distort absolute measurements (ratio-based measurements from either file are equivalent, but 1.png avoids the risk entirely).
- Dp-scale-matched crop+resize comparison (build screenshot vs Figma, both resized to a common width after cropping to the same dp range) is now the preferred verification method — more reliable than either eyeballing or raw single-image pixel measurement, especially given how low-resolution Android Studio's preview screenshots are compared to the Figma source.

### Status at End of Session — read this before continuing
- **Still not confirmed pixel-perfect, despite three more commits this session on top of the ~9 rounds already logged in Session 6 and the pass in Session 4.** This is now well past a dozen iteration rounds across three sessions on a single screen's action-card component alone.
- **Known, specific, NOT-yet-fixed gap**: action-card button text ("Create"/"Choose") renders visibly smaller/fainter than Figma at matched scale — clearly identified via the dp-matched comparison but the fix was never implemented this session.
- **Known unreliable measurement**: subtitle text cap-height could not be trusted via pixel-threshold methods due to its lighter color; whatever subtitle size ships next should be verified by eye against a matched-scale crop, not just computed.
- **Not touched at all this session, despite the user's "even small details should be same" standard**: header ("Mochi" wordmark, Create Custom icon), Recently Applied row, Popular Themes row, Font Collection row — only the action-card + toggle region got the rigorous treatment this round.
- Root cause of the slow convergence, worth internalizing: computing a target font size from a single Figma crop's cap-height plus an assumed cap-height-to-em constant produces a number that *looks* rigorous but can still be measurably wrong (confirmed this session — the constant used was off by roughly 15-20%). The only way to actually verify a shipped size is correct is to render it, screenshot it, and do a matched-scale comparison against Figma — that verification step was being skipped between "measure Figma" and "ship the change," which is very likely why so many rounds have been needed.

### Next Session Goals
- Fix the button text size gap identified but not resolved this session (SlimPillButton / GradientButton text in action cards).
- Re-derive subtitle size by matched-scale visual comparison, not pixel-threshold measurement (color makes threshold-based measurement unreliable for this element).
- Before claiming any element "matches Figma," do the render → screenshot → dp-matched-crop comparison against `docs/figma/1.png` — do not ship on the basis of Figma-crop measurement alone.
- Once action cards + toggle are genuinely confirmed, extend the same rigorous treatment to the rest of the Home screen (header, Recently Applied, Popular Themes, Font Collection) — none of it has had this level of scrutiny yet.
- Consider whether to explicitly ask Sujal if exact Figma inspector values (font sizes, exact dp measurements from Figma's own UI, not reverse-engineered from a flattened PNG) are available — reverse-engineering exact values from a raster export has an inherent error margin that keeps costing rounds.

---

## Session 8 — Home Screen Figma-Parity, Round 4 (real device build loop + Android is unlocked here)
**Date:** July 17, 2026
**Duration:** Very long (many discrete rounds, one-change-at-a-time per Sujal's explicit process)
**Stage:** Android UI — Home screen, continued (still not fully signed off)

### What Happened
- Sujal opened the session by locking in explicit non-negotiable rules before any work started: every change must be a real verifiable diff (no describing work that wasn't done — he lost 5 hours to that once and it nearly cost him the client), no sugarcoating, accuracy over speed, show-don't-tell, stop and ask when blocked on an asset/ambiguity, and — introduced partway through this session — **one change at a time, sent by him, with his own verification before the next one** (he explicitly said he does NOT want me bundling/self-directing multiple list items at once, correcting an earlier assumption from the start of this session that I could work through his whole 12-item list independently).
- **Major unlock: this machine can actually build, install, and run the Android app.** Unlike iOS (Windows, no Mac, blind code only), Android SDK/platform-tools were already present (`%LOCALAPPDATA%\Android\Sdk`), so this session for the first time used a real build→install→screenshot→verify loop via `adb` + `gradlew installDebug`, instead of relying solely on Sujal's screenshots. This should be the default going forward for Android work.
- Diagnosed and fixed real, code-verifiable bugs (not just spacing tweaks) by reading `HomeScreen.kt`/`ThemeArt.kt`/`MochiTabBar.kt` before touching anything:
  - **Popular Themes card crop was a real asset bug, not a perception issue**: `theme_cozy_sakura_cafe.png`/`theme_sakura_train.png`/`theme_pastel_rainbow.png` were natively ~2.3:1 wide-banner crops forced into a 1.35:1 display box, so `ContentScale.Crop` was cutting ~40% off the sides. Re-cropped all three directly from `docs/figma/1.png` (and `8.png` for Pastel Rainbow, which is cut off in `1.png`'s frame) at the exact measured card aspect. **Committed and pushed** — commit `e6dbac2`.
  - **Bottom nav bar "missing" was a false alarm**: `MochiTabBar` already existed and was wired up in `RootScreen.kt`; it just doesn't appear in `HomeScreenPreview` because that Preview renders `HomeScreen` in isolation. No code bug — Sujal confirmed to keep using `HomeScreenPreview` anyway and not switch reference points.
  - **MochiTabBar audit** (Sujal approved doing this proactively): added a missing 1dp purple border on the bar (Figma has one, code didn't).
- Extended, iterative round-by-round work after that (each shipped as its own build+screenshot, sent for Sujal's own review per his process rule):
  - Home background swapped from a coded gradient to a real PNG Sujal provided (`home_background.png`) — first attempt used `ContentScale.Crop` and cropped the image; Sujal wanted the whole image with no crop. Flagged the real tradeoff (his 941×1672 image vs the phone's 720×1612 screen don't share an aspect ratio, so "no crop" necessarily means letterbox gaps) rather than picking one silently — Sujal resolved it cleanly by re-supplying the PNG pre-sized to match the screen ratio exactly (839×1875 vs 720×1612, within 0.2%).
  - Removed the now-redundant hardcoded `SparkleDecorations()` composable (2 hand-placed ✦ glyphs) since the new background image has its own baked-in stars — dead-code cleanup per Sujal's "no old code stuff left behind" instruction.
  - "Create Custom" label bolded; header pushed down (top padding 8dp→24dp) so a background star that was being clipped by the icon becomes visible — the exact clearance needed was computed from real numbers (star's pixel position in the actual PNG, phone's real status bar height via `adb shell dumpsys window`), not guessed.
  - Mochi wordmark: Sujal supplied a reference PNG of the wordmark; confirmed via direct letterform comparison that the current font (Fredoka Bold, chosen in an earlier session) already matches exactly — no font swap needed, this was purely a size problem. Solved with a **scale-independent ratio method**: measured wordmark-height ÷ the Create Custom icon's known-fixed 48dp size in both the Figma export and a real device screenshot (pulled via `adb`), then solved for the sp value that makes those ratios match (63sp, up from 40sp) — landed within 1.6% of Figma's proportion, verified by re-screenshotting after building. This ratio approach is more robust than the cap-height/em-constant guessing that caused repeated misses in Sessions 6–7.
  - Discovered (by measuring, not eyeballing) that Figma top-aligns the Mochi wordmark and the Create Custom icon (both start at literally the same y-pixel) rather than center-aligning them — changed the header `Row`'s `verticalAlignment` from `CenterVertically` to `Top` to match.
  - Action cards (Custom Create / Choose from Library): icon size 48dp→56dp; `Row` alignment changed `CenterVertically`→`Top` so the two cards' titles start at the same height regardless of how many lines each title wraps to (this had been silently misaligning "Choose from Library" since it wraps to 2 lines and "Custom Create" doesn't).
  - Card-row→toggle gap 8dp→20dp, toggle→"Popular Themes" gap 8dp→24dp, both measured directly from `docs/figma/1.png` pixel gaps rather than guessed.
  - FONTS/THEMES toggle narrowed with extra side margin + widened inter-pill gap, matching Figma (the toggle is visibly inset from the screen edges in Figma, not edge-to-edge like the action-card row above it).
  - **Create FAB icon**: Sujal provided an asset that turned out to be a full glossy/3D-bevel rendering of the whole button (circle+icon+"Create" text baked in as one flattened image) — visually a different style (glossy/embossed) from Figma's flat gradient. Flagged the mismatch; per Sujal's direction, extracted the real FAB button directly from `docs/figma/1.png` pixels instead (same technique as the Popular Themes fix). First crop left a stray ring artifact because the crop had a margin around the circle, so `clip(CircleShape)` in code was clipping outside the drawn circle — fixed by re-measuring for an exact edge-to-edge crop (circle touches all 4 sides of the square, corners are the only background left, which the code's circular clip removes correctly).
  - **Keyboard tab icon** (Sujal-provided asset): same pattern — his asset was a 6×2-key wide rectangle (1.62 aspect), Figma's actual selected-tab badge is a near-square 4×3-ish grid. Sujal chose (via AskUserQuestion) to have this extracted from Figma directly too, same as the FAB.
  - **Community tab icon**: Material's `Icons.Filled.Group` didn't match Figma's actual 3-person-silhouette icon. Extracted it directly from Figma as a real alpha-transparent PNG (this one was straightforward since it's a flat monochrome icon, unlike the earlier white-on-gradient cases that were correctly avoided in Session 7/8) and wired it with `ColorFilter.tint()` so it keeps the same dynamic gray/purple selected-state tinting the Material icon had.
  - Create FAB resized 64dp→40dp (measured via the same screen-width-ratio technique used for the wordmark), with the notch geometry (offset, radius) recalculated to match rather than left stale.
  - Nav bar thinned: vertical padding 8dp→4dp, icon-to-label gap 4dp→2dp, based on measuring Figma's actual bar height (~40dp) against the previous coded height (~60dp). **This last round was screenshotted and shown but Sujal has not yet confirmed it** — he moved straight to asking for a memory update instead of reviewing it.
- **Process incident, logged here in full because it's a real safety lesson, not just a bug**: mid-session, an automated `adb input tap` at a blindly-assumed fixed coordinate (used to click through onboarding screens after a reinstall) apparently landed on the phone's home screen and opened WhatsApp instead of the app. Sujal asked for the resulting screenshot to be deleted, taking the blame himself ("my mistake I opened whatsapp") even though the tap sequence was mine. The local copy was deleted immediately; the on-device copy could not be deleted in the moment because the phone was disconnected from `adb` at that point — Sujal said he'd delete it himself. **This must not happen again**: never send blind coordinate taps assuming a known navigation state, especially after a reinstall (app process state after `installDebug` was inconsistent all session — sometimes resumed mid-onboarding, sometimes cold-started, unpredictably). From that point on, the working discipline became: check `adb shell dumpsys window | grep mCurrentFocus` (and `dumpsys power` for screen wakefulness) **before** any screenshot or tap, to positively confirm Mochi's `MainActivity` is actually in the foreground first.
- Device connectivity was flaky throughout — the phone repeatedly dropped from `adb devices` (empty list) and had to be reconnected several times by Sujal mid-task; this cost real time across the session and should be expected going forward, not treated as a one-off.
- Git: only **one** commit/push happened this session (`e6dbac2`, early on, covering just the Popular Themes crop fix + tab bar border). Every change after that — background image, Mochi wordmark, action cards, gap spacing, toggle width, all three tab-bar icon replacements, FAB resize, nav bar thinning — is **still uncommitted** in the working tree as of the end of this session. Sujal has not asked for another commit; don't assume it's safe to commit without asking, but the next session should surface this clearly since there's now a large amount of uncommitted, unpushed work sitting locally.

### Decisions Made This Session
- One-change-at-a-time with Sujal's own verification between each is now the enforced process for this screen (superseding the "go through the whole list" framing from the very start of this session).
- Whenever a Sujal-provided asset visually mismatches the actual Figma pixels (style or shape), the fix is to extract the real asset directly from `docs/figma/*.png` rather than using the mismatched asset or asking Sujal for yet another one — confirmed 3 times this session (Popular Themes art, Create FAB, Keyboard tab icon) and explicitly chosen by Sujal via AskUserQuestion once it was framed as an option.
- `docs/figma/1.png` remains the reference Sujal wants used (he explicitly declined switching to `RootScreenPreview` even to see the real nav bar, and confirmed `HomeScreenPreview` stays the comparison surface).
- Ratio-based measurement (element A ÷ known-fixed element B, computed identically in both the Figma export and a real device screenshot) is now the preferred sizing technique over absolute px→dp conversion or assumed cap-height constants — it caught and self-corrected for a device/Figma scale mismatch that would have silently produced a wrong number otherwise.

### Status at End of Session — read carefully
- **Not yet confirmed by Sujal**: the nav bar thinning (padding/gap reduction) — screenshotted but the conversation moved to a memory-update request before he reviewed it.
- **Still open from the original 12-item list this session started with**: (1) Recently Applied row thumbnail icon sizes, (2) their label font sizes, (9) gap between Popular Themes row and Font Collection heading — none of these three have been touched yet. Items (3)/(4) (forcing "Choose from Library"/"Pick a created keyboard" onto specific line breaks) were never explicitly implemented as a deliberate fix, though the later icon-size increase incidentally seems to be causing "Choose from Library" to wrap to two lines now as a side effect of less available width — this has **not** been verified as intentional/correct and should be re-checked, not assumed fixed.
- **Uncommitted work**: everything after commit `e6dbac2` (see above) is sitting in the working tree, unpushed.
- Full technical detail (exact dp values, exact measurement methodology per element) is in this log rather than a separate handoff doc this time — read this entry in full before continuing Home screen work.

### Next Session Goals
- Get Sujal's actual confirmation on the nav bar thinning round before treating it as done.
- Pick up the 3 untouched original list items (thumbnail icon/label sizes, Popular Themes→Font Collection gap) — Sujal drives which one first, one at a time, per his process rule.
- Re-verify the "Choose from Library" text wrap is actually correct/intentional, not just an accidental side effect of the icon resize.
- Ask Sujal whether he wants a commit for the large amount of uncommitted work before it accumulates further.
- Keep using the real build→install→adb-screenshot verification loop established this session for any further Android work — check `mCurrentFocus` before every screenshot/tap, never blind-tap a coordinate assuming a known nav state.

---

<!-- Template for future sessions:

## Session N — [Title]
**Date:** YYYY-MM-DD
**Duration:** [short/medium/long]
**Stage:** [Pre-dev / Architecture / iOS Dev / Android Dev / Testing / Launch / Post-launch]

### What Happened
[Brief narrative of what was worked on]

### Decisions Made This Session
[New decisions, with context]

### Corrections / Changes
[Anything that changed from before — link to changelog]

### Status at End of Session
[What's done, what's next]

### Next Session Goals
[Specific objectives for next session]

-->
