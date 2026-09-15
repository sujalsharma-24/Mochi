# Mochi iOS — Current State (handover snapshot, 2026-09-15)

**Read this first.** This is the single entry point for anyone auditing or taking over Mochi. It
records where the **iOS** app stands at the moment it was pushed. iOS is the more complete platform
and is the **reference implementation**: Android should be brought up to what iOS does, not the
other way round.

Everything here was checked against the code at the time of writing. When a file comment
contradicts this doc (several still say "28 themes", see *Doc rot* below), the code is right and
the comment is stale.

---

## 1. Snapshot

| | |
|---|---|
| Repo | `github.com/sujalsharma-24/Mochi`, branch `master` |
| Snapshot date | 2026-09-15 |
| iOS work period covered | ~2026-07-25 → 2026-09-15, mostly 2026-08-30 → 2026-09-15 |
| Toolchain | Xcode 26, Swift 6.3 toolchain (`SWIFT_VERSION` 5.0 language mode), deployment target iOS 16.0 |
| Project generation | XcodeGen. `ios/project.yml` is the source of truth; `Mochi.xcodeproj` is git-ignored |
| Bundle IDs (current) | `com.tanmaysingh.mochi` (app), `com.tanmaysingh.mochi.MochiKeyboard` (extension), App Group `group.com.tanmaysingh.mochi` |
| Signing | `DEVELOPMENT_TEAM: 6338ADN35J` (Tanmay's personal Apple ID, automatic signing). **Must change before release**, see §8 |
| Backend | Firebase code is written but **dormant**: `GoogleService-Info.plist` is absent, so `AppContainer.shared == nil` and the app runs local-first |
| Builds | Yes. `xcodegen generate` + simulator Debug build: **BUILD SUCCEEDED** on 2026-09-15 at this snapshot; `ios/Tools/validate-themes.sh` **PASSED** for all themes. The app was also installed on a physical iPhone the same day. UI tests were not re-run for this snapshot |

### Build & run

```bash
brew install xcodegen          # once
cd ios
xcodegen generate              # after any project.yml change or new file
open Mochi.xcodeproj           # scheme: MochiApp (embeds MochiKeyboard)
```

- Cold build ≈ 12 min (Firebase C++), warm ≈ 3–5 min.
- To use the real keyboard on a device: install, then Settings → General → Keyboard → Keyboards →
  Add New Keyboard → Mochi. Full Access is **not** requested (`RequestsOpenAccess: false`).
- `simctl install` over a running app silently does nothing. Uninstall first, or you'll be
  looking at a stale build.

---

## 2. Targets & top-level layout

```
ios/
  project.yml              XcodeGen spec: targets, Info.plist keys, entitlements, SPM packages
  MochiApp/                the container app (SwiftUI)
    App/                   entry point, AppRootView (flow gate + NavigationStack), AppRoute, RootView (tabs),
                           ThemeSnapshotHarness (DEBUG)
    Features/<Screen>/     one folder per screen (§3)
    Data/                  stores, catalogues, repositories (Firebase, dormant), Search engine
    DesignSystem/          tokens, Typography, per-screen *Metrics, ScreenScale, DesignGrid
    Components/            shared views: ThemeCard, KeyboardThemePreview, KeyboardTestBench,
                           ThemePlateThumbnail, ArtTweakLab (DEBUG) …
    Models/ MockData/      view models' data shapes; MockData is now only a fallback/seed
    Assets.xcassets        app art: 75 wallpapers, 134 themethumb_* thumbnails, avatars, AppIcon …
  MochiKeyboard/           the keyboard App Extension (UIKit). KeyboardViewController
  MochiShared/             code compiled into BOTH app and extension
    Theme/                 MochiKeyboardTheme token model, ThemeColor (WCAG maths), ThemeStore
    Themes/                BuiltInThemes.swift + BuiltInThemes+Batch2…8.swift: 140 themes
    Render/                KeyView, KeyboardSurfaceView: the one renderer both targets use
    Input/                 KeyboardInputEngine: autocap, double-space period, suggestions, font styles
    Fonts/                 FontStyleCatalog (6 Unicode lookalike styles), FontStyleStore
    AppGroup.swift         the ONE place the App Group id is written
  SharedAssets/KeyboardArt.xcassets   themebg_* plates + keyart_<prefix>_* per-key illustrations (~250 MB)
  MochiUITests/            XCUITest flows (§6)
  Tools/                   validate-themes.sh, ThemeValidationCLI, run-theme-lab.sh, run-art-tweak.sh
scratchpad/                Python theme-ingest/generation pipeline (§6). Intermediate _plate_*.png are git-ignored
docs/figma/                Figma frame exports 1.png–13.png: the visual ground truth per screen
```

Other docs still worth reading: `docs/keyboard-theme-system.md` (theme architecture),
`ios/MochiShared/README.md`, `docs/PRODUCTION_PLAN.md`, `docs/TRD.md`, `docs/project-memory/`
(product/business decisions). `docs/IOS_FUNCTIONAL_STATUS.md` and the `plans/handoffs/*` files are
**historical** and are superseded by this file.

---

## 3. Screen-by-screen status

"Local-first" means the screen is fully functional with on-device data and persistence. The
Firebase path exists in code but can't run until the plist lands (§5).

| Screen | Figma | Status | Data / behaviour today |
|---|---|---|---|
| Splash + Onboarding | — (Android-designed) | ✅ Done | Shows once per install (`@AppStorage("mochi.hasSeenOnboarding")`) |
| Auth (Email, Google, Apple, Phone OTP) | — | ✅ Code done, ⛔ dormant | Skipped entirely while `AppContainer.shared == nil` |
| Home | `1.png` | ✅ Functional, pixel-ported | Recently applied (capped at 3), popular themes, font collection. FONTS/THEMES pills jump to their tabs |
| Themes | `8.png` | ✅ Functional, pixel-ported | Real 140-theme catalogue (`ThemeCatalog` ← `BuiltInThemes.all`). Category pills filter via `ThemeSemantics`. Sort/filter work. "My downloaded themes" strip is persisted |
| Theme Detail | — (spec only) | ✅ Functional | **Live typable keyboard preview** of the real theme. Apply writes `AppliedThemeStore` + `ThemeStore` (App Group), so the real keyboard picks it up. Like/download persisted locally. Premium → Paywall |
| Theme Collection ("see all") | — | ✅ Functional | One parameterised page behind every "see all" (Community Top/Latest, Profile Creations/Liked/Downloads) |
| Fonts + Downloaded Fonts | `5.png` | ✅ Functional, pixel-ported | 6 Unicode lookalike styles (§4). Pills filter by category, Filter = free/pro, Sort = Popular/Newest/A–Z. Apply → App Group → keyboard. Pro → Paywall |
| Search | `6.png` | ✅ Functional | Client-side concept-relevance engine (`Data/Search/`) over themes + fonts + creators. Recents persisted, trending/suggestion chips and tier/sort filters wired |
| Create Custom Theme | `4.png` | ✅ Functional editor, pixel-ported | `ThemeDraft` is the single source of truth. Colour/effects/background controls drive a live preview. Autosaves drafts and publishes locally to `CustomThemeStore`, and published custom themes appear in the catalogue/search. `CreateRepository` (Firestore/Storage) path exists but is dormant |
| Community | `2.png` | 🟡 UI done, data partly mock | Pixel-ported. Top/Latest use real catalogue or ViewModel data when present, otherwise `MockData`. Popular Creators is `MockData`. Follow/Report go through dormant repositories |
| Profile (own + other) | `3.png` | 🟡 UI done, data mostly mock | Pixel-ported with `ProfileMetrics` scaling. No ViewModel. `uid` only toggles own vs other affordances. Other creators' real profiles don't exist (no creator↔theme join in data) |
| Wallpapers + Wallpaper Preview | `10.png` | ✅ Functional | 75 bundled wallpapers (`WallpaperCatalog`), rail + content layout, collections, recently downloaded (persisted). Download/Apply saves to Photos (add-only permission). Apply then opens the share sheet, because **iOS has no public API to set the wallpaper** |
| Settings | `7.png` | ✅ UI done, partly dormant | Keyboard toggles persist to the App Group (`AppSettingsStore`). Sign out / Delete account call `AuthRepository`, a no-op without Firebase |
| Paywall | `11.png`/`12.png` | 🟡 UI done, billing inert | Locked pricing **$2.99/mo · $19.99/yr · 3-day trial**. Figma's $199/$999 + custom card form was never approved and would break Guideline 3.1.1. `BillingRepository.isConfigured = false`; "Unlock anyway (demo)" sets a local premium flag |
| Leaderboard | `9.png` | 🟡 UI done, mock | `MockData.rankedCreators`. Period tabs and follow toggles are local-only. "Explore Community" link is a no-op (no route) |

Navigation: `AppRootView` owns a `NavigationStack` with `AppRoute` (`themeDetail`, `profile(uid:)`,
`search`, `settings`, `paywall`, `leaderboard`, `wallpapers`, `downloadedFonts`,
`themeCollection`). `selectedTab` and the font selection are hoisted to `AppRootView` so any screen
can jump tabs.

Responsive sizing: every screen was measured on an iPhone 16 Pro (402×874pt).
`DesignSystem/ScreenScale.swift` and `DesignGrid.swift` scale sizes, type and columns to the real
screen. Fixed on 2026-09-15 after layouts broke on the 16 Pro Max. **Other device sizes (SE, mini,
iPad) have not been systematically checked.**

---

## 4. The keyboard extension (the core product)

This is the most developed part of iOS, and Android has nothing equivalent yet.

- **Renderer**: `MochiShared/Render/` (`KeyboardSurfaceView`, `KeyView`), driven by a
  `MochiKeyboardTheme` token document. The in-app preview (`KeyboardThemePreview`,
  `KeyboardTestBench`) uses the exact same renderer, so what you preview is what types.
- **140 built-in themes**: batch 1 (3 hand-authored: Cozy Sakura Café, Fantasy Castle Night, Dreamy
  Castle) + batches 2–8 (21 + 40 + 9 + 19 + 25 + 20 + 3), mostly generated by the `scratchpad/`
  pipeline. Each has its own background plate (`themebg_*`, HEIC ~1448px) and up to 33 per-key
  illustrations (`keyart_<prefix>_*`).
- **7-material system** (Inkwell, Pane, Jelly, Clay, Letterpress, Keycap, Pearl). Key colours are
  *derived from each plate* (sampled luminance, snapped out of the illegible mid band). Ink colour
  is *solved* for 5.5–6.5:1 contrast. Details: `docs/keyboard-theme-system.md` and the `gen_*.py`
  scripts.
- **Validation**: `ios/Tools/validate-themes.sh` runs the token/contrast validator + per-pixel art
  check over every theme in ~1 s, no simulator needed. It must pass before a theme ships.
- **Fonts are not typefaces.** A keyboard extension cannot change the font of inserted text, so a
  Mochi "font" is a Unicode lookalike map (a→𝓪). `FontStyleCatalog` holds the 6 styles and
  `normalize()` maps styled text back to ASCII, so autocap and suggestions still work. No `.ttf`
  files are involved.
- **App ↔ extension contract**: the app writes, the extension reads, through the App Group
  (`ThemeStore`, `FontStyleStore`, `AppSettingsStore`). If the entitlement and
  `AppGroup.identifier` disagree, both sides silently fall back to separate `.standard` stores.
  Theme/font apply then "works" in-app and never reaches the keyboard. Change them together.
- **Hard platform limits (by design)**: ~30–48 MB extension memory ceiling (plates are decoded
  straight to drawn size); can't blur host-app content; can't draw above the input view (accent
  callouts flip below on the top row); no mic key; no Full Access.
- Premium gating is **app-side only**. `BillingRepository` uses `.standard` defaults, so the
  extension can't see premium status.

---

## 5. Local-first stores vs. dormant backend

Because no `GoogleService-Info.plist` exists, every user action persists on device. The Firebase
layer is fully written against the same Firestore schema / Cloud Functions Android uses
(`functions/` is shared), but it can't run.

| Store (`MochiApp/Data` / `MochiShared`) | Holds | Container |
|---|---|---|
| `AppliedThemeStore` + `ThemeStore` | active theme | App Group (extension reads) |
| `FontStyleStore` | applied + owned font styles | App Group |
| `AppSettingsStore` | keyboard toggles | App Group |
| `CustomThemeStore` | Create drafts + locally published themes | files under shared root |
| `LikedThemeStore`, `DownloadedThemeStore`, `DownloadedWallpaperStore` | hearts, downloads | local |
| `RecentSearchStore` | recent searches | `.standard` |
| `BillingRepository` | local demo premium flag | `.standard` |

Dormant (code complete, needs the plist): `AuthRepository`, `UserRepository`, `ThemeRepository`,
`LikeRepository`, `FollowRepository`, `ReportRepository`, `CreateRepository`, `StorageRepository`,
FCM token sync. **When Firebase is enabled, someone has to decide how local state (likes,
downloads, custom themes) merges with or migrates to the server.** Nothing does that yet.

---

## 6. Dev & QA tooling

- **UI tests** (`ios/MochiUITests/`): `ThemesFlowUITests`, `FontsFlowUITests`, `SearchFlowUITests`,
  `CreateThemeFlowUITests`, `WallpapersFlowUITests`, `ScreenshotUITests`.
- **Launch arguments**: `UITEST_SKIP_ONBOARDING`, `QA_OPEN_WALLPAPERS`, `QA_OPEN_THEME_DETAIL`,
  `QA_OPEN_PROFILE` (jump straight to a screen); `-MochiThemeLab 1 -MochiThemeLabTheme <id-suffix>`
  (theme lab); `-MochiThemeSnapshots 1 [-MochiThemeSnapshotIDs a,b]` renders every theme's real
  keyboard to PNG (DEBUG, used to produce the `themethumb_*` thumbnails).
- **ArtTweakLab** (DEBUG): in-app sliders for per-key art position/size/opacity that emit
  paste-ready Swift. `ios/Tools/run-art-tweak.sh`.
- **CI**: `.github/workflows/ios-screenshots.yml` (macOS 26 runner) builds and runs the screenshot
  UI test on pushes to `ios/**`. The loose-PNG export in `ScreenshotUITests` has never worked, so
  pull screenshots from the `.xcresult` instead. CI was green as of late August. **It hasn't been
  checked against this snapshot**, and the extra ~300 MB of assets will slow checkout.
- **Theme pipeline** (`scratchpad/*.py`): `ingest_batch*.py` (source PNGs in a Downloads folder
  named `themebg_*` / `keyart_<pfx>_*` → HEIC plate + trimmed/scaled key art → imagesets),
  `gen_b*.py` (writes `BuiltInThemes+BatchN.swift`: material assignment + derived palette),
  `theme_color.py` (Python mirror of `ThemeColor.swift` WCAG maths), `report_*.txt`
  (per-batch output). Source folders are local to Tanmay's machine and **not** in the repo; the
  processed output is.

---

## 7. What's still left on iOS (our side)

Roughly in priority order. None of these are started unless noted.

1. **Firebase enablement.** Register the iOS app in the `mochi-940bd` Firebase project under the
   *final* bundle ID, add `GoogleService-Info.plist`, set `REVERSED_CLIENT_ID` (search
   `REPLACE_WITH_IOS_REVERSED_CLIENT_ID`), then verify Auth, publish, likes, follows and reports
   end to end. Also decide how local state migrates (§5).
2. **Real IAP.** StoreKit 2 or RevenueCat (the spec says RevenueCat), App Store Connect products
   at the locked prices, restore purchases, and entitlement reachable from the extension if any
   premium theme must be enforced in the keyboard itself.
3. **Profile**: real ViewModel, other-creator profiles (needs a creator↔theme link; today
   `creatorUid` is empty everywhere and `ThemeCatalog` attributes everything to "Mochi Studio").
4. **Community / Leaderboard**: replace `MockData` creators/rankings with real queries.
   Leaderboard period tabs have no backend.
5. **Push notifications (FCM)**: SDK present, proxy disabled. APNs token forwarding, permission
   prompt and handling are not built.
6. **Sign in with Apple entitlement**: code exists; the entitlement was removed from `project.yml`
   because a personal team can't provision it. Re-add under a paid team. Required by Guideline
   4.8 because Google sign-in is offered.
7. **Theme polish (optional)**: batch-3+ `verticalAnchor` framing is 0.5 across the board; ~15
   dark themes read samey; ~30 key illustrations were dropped because their source had no alpha;
   some themes have empty/placeholder space-key art (e.g. Whispering Lake Cottage).
8. **Device coverage**: check SE/mini/Plus/iPad layouts; the app declares iPad support
   (`TARGETED_DEVICE_FAMILY 1,2`).
9. **Doc rot**: file header comments in `ThemeCatalog.swift`, `RenderableTheme.swift` and
   `ThemePlateThumbnail.swift` still say "28 themes" (now 140).

---

## 8. Known App Store blockers (starting list, not the full audit)

- **Identity**: bundle IDs, App Group and `DEVELOPMENT_TEAM` are Tanmay's personal ones.
  `com.mochi.app` / `group.com.mochi.app` are taken by another team, so the client needs their own
  reverse-DNS ID. Change `project.yml` + `MochiShared/AppGroup.swift` together, and use the same ID
  for the Firebase iOS app.
- **Paid Apple Developer Program account** (client's name, per delivery terms), certificates and
  provisioning for both targets + App Group + Sign in with Apple.
- **Privacy manifest**: no `PrivacyInfo.xcprivacy` exists for either target. Firebase and
  UserDefaults use require-reason APIs.
- **Account deletion** must actually work (Guideline 5.1.1(v)). The code exists but is dormant.
- **UGC moderation** (Guideline 1.2): report + auto-hide exists in `functions/`
  (`onReportThreshold`, now sets `moderationStatus: 'hidden'`). Block-user and admin review tooling
  are not built.
- **Paywall** must use native IAP with restore; see §7.2.
- **Keyboard review notes**: explain why Full Access is not requested; make sure no feature
  implies network use from the extension.
- App icon exists (`AppIcon`, single 1024 slot from `docs/figma/icon.png`). Store screenshots,
  privacy policy URL, age rating and export compliance are not done.

---

## 9. Android status & porting guidance (Play Store)

Android (`android/`, package `com.mochi.keyboard`) was built by Sujal first. It has the same 14
feature folders and **real Firebase wiring** (`google-services.json` committed). But it is **behind
iOS on the product itself**:

| Area | iOS | Android |
|---|---|---|
| Keyboard themes | 140 fully-authored themes, 7 materials, per-key art, contrast-validated | `ime/` is 3 files (`MochiInputMethodService`, `KeyboardVisualTheme`, `KeyPopupWindow`) |
| Font styles | 6 Unicode lookalike styles, applied inside the keyboard | no equivalent found in `ime/` |
| Theme detail | live typable preview using the real renderer | Android's IME has no shared renderer to preview with |
| Search | concept-relevance engine | substring filter over a Firestore pool |
| Create | real editor + live preview + local drafts/publish | Firestore write (`CreateThemeScreen.kt`, ~800 lines) |
| Wallpapers | 75 bundled, collections, save to Photos | Firestore `liveWallpapers` grid |
| Figma pixel parity | Home, Themes, Fonts, Community, Profile, Create, Wallpapers, Settings measured | not compared screen by screen |
| Backend | written, dormant | live |

(Android column: a quick code survey, not a full audit. Verify before planning work from it.)

Porting approach that should carry over cleanly:

- **Theme data is platform-neutral.** `MochiKeyboardTheme` tokens + `themebg_*` / `keyart_*`
  assets can be exported (e.g. to JSON + drawables) and rendered by an Android IME. The renderer
  logic in `MochiShared/Render/` is the spec; the colour maths in `ThemeColor.swift` /
  `scratchpad/theme_color.py` is the contrast rule.
- **Font styles** are pure character maps. `FontStyleCatalog.swift` ports 1:1 to Kotlin, and
  Android's IME can apply it in `commitText`.
- **Search** (`Data/Search/`) is plain Swift with no platform dependencies and ports directly.
- Android's IME runs **in-process** with the app, so the App Group dance isn't needed there.
  Android also *can* set the device wallpaper (`WallpaperManager`), which iOS can't.
- Android already has the live backend. The reverse port (iOS enabling Firebase) should follow
  Android's repository contracts, which iOS already mirrors.

---

## 10. Decisions not to re-litigate

- Paywall pricing is the locked spec, not Figma's numbers. Native IAP only.
- No custom `.ttf` for "fonts": Unicode lookalikes are the only way that works inside a keyboard
  extension.
- `Apply` on wallpapers ends in Photos + the share sheet. iOS has no wallpaper-setting API.
- No Full Access. The app writes, the extension reads.
- Wallpaper category chips and Leaderboard period tabs have no backing data field yet (schema
  gap, not a UI bug).
- Don't hand-edit `ios/MochiKeyboard/Info.plist` or the `.entitlements` files; XcodeGen generates
  them from `project.yml`.
- Keyboard art must be aspect-**fill**, bottom-flush. Never trust colours sampled from marketing
  renders as cap fills (double-counts the background).
