# Handoff — iOS Android-parity pass (2026-08-31)

## Prompt for the next session

> We're working on the Mochi **iOS** app. Last session brought it to structural parity with the
> Android app — the 4 missing screens now exist (Settings, Paywall, Wallpapers, Leaderboard), a
> real `NavigationStack` ties everything together, and the theme apply flow shows a live typable
> keyboard. This session we go **page by page and make every page fully functional**. I'll tell you
> which page to work on and what's still wrong on it — **wait for me to name the page and the
> fixes**, don't pre-emptively refactor or re-tune layouts. Visual/Figma-pixel polish is part of
> this pass. Start by building + running the app in the simulator so I can see the current state.

Read this whole file first. The three things below are wrong in the "obvious" mental model and a
fresh session will re-derive them incorrectly (last session did).

---

## Premise corrections (important)

1. **Figma DOES exist for the 4 new screens.** `docs/figma/7.png` Settings · `9.png` Leaderboard ·
   `10.png` Wallpapers · `11.png` + `12.png` Paywall. The new SwiftUI screens are built clean on
   the app's design tokens, **not** pixel-tuned to these frames yet — that's this session's job
   when the user asks for it. (Paywall's Figma shows $199/$999 pricing + a custom card form —
   **ignore it**; the locked spec is $2.99/mo · $19.99/yr · 3-day trial, native IAP only.)
2. **Paywall needs zero StoreKit / RevenueCat.** `BillingRepository` is an inert stub by design,
   exactly like `android/.../data/BillingRepository.kt` (`isConfigured = false`). Do not add a
   payments SDK. "Unlock anyway (demo)" flips a local `@AppStorage` flag so premium-gated UI can
   be exercised.
3. **The wallpaper / avatar / icon assets already exist**, copied from
   `android/app/src/main/res/drawable-nodpi/` into `ios/MochiApp/Assets.xcassets/` last session
   (`wallpaper_*` ×10, `avatar_{dreamy_designs,pixel_art,techy_keys,vibe_studio}`,
   `icon_premium_crown`, `icon_trophy_mochi`).

---

## File-pointer table

| Screen | iOS file | Android source | Figma |
|---|---|---|---|
| Navigation graph | `ios/MochiApp/App/AppRootView.swift` + `AppRoute.swift` + `RootView.swift` | `android/.../ui/AppNavHost.kt` + `RootScreen.kt` | — |
| Home / Keyboard | `Features/Home/HomeView.swift` + `HomeViewModel.swift` | `features/home/HomeScreen.kt` | `docs/figma/1.png` |
| Fonts | `Features/Fonts/FontsView.swift` | `features/fonts/FontsScreen.kt` | `docs/figma/5.png` |
| Themes | `Features/Themes/ThemesView.swift` + VM | `features/themes/ThemesScreen.kt` | `docs/figma/8.png` |
| Community | `Features/Community/CommunityView.swift` + VM | `features/community/CommunityScreen.kt` | `docs/figma/2.png` |
| Create | `Features/Create/CreateThemeView.swift` + VM | `features/create/CreateThemeScreen.kt` | `docs/figma/4.png` |
| Theme Detail | `Features/ThemeDetail/ThemeDetailView.swift` + VM | `features/themedetail/ThemeDetailScreen.kt` | — (spec only) |
| Profile | `Features/Profile/ProfileView.swift` | `features/profile/ProfileScreen.kt` + `ProfileViewModel.kt` | `docs/figma/3.png` |
| Search | `Features/Search/SearchView.swift` | `features/search/SearchScreen.kt` + `SearchViewModel.kt` | `docs/figma/6.png` |
| Settings | `Features/Settings/SettingsView.swift` + `Data/AppSettingsStore.swift` | `features/settings/SettingsScreen.kt` + VM | `docs/figma/7.png` |
| Paywall | `Features/Paywall/PaywallView.swift` + `Data/BillingRepository.swift` | `features/paywall/PaywallScreen.kt` + VM | `docs/figma/11.png` `12.png` |
| Wallpapers | `Features/Wallpapers/WallpapersView.swift` | `features/wallpapers/WallpaperExploreScreen.kt` + VM | `docs/figma/10.png` |
| Leaderboard | `Features/Leaderboard/LeaderboardView.swift` | `features/leaderboard/LeaderboardScreen.kt` + VM | `docs/figma/9.png` |
| Onboarding / Splash | `Features/Onboarding/OnboardingView.swift` | `features/onboarding/OnboardingScreen.kt` | — |
| Auth | `Features/Auth/AuthView.swift` + VM | `features/auth/AuthScreen.kt` + VM | — |
| Keyboard renderer | `ios/MochiShared/` (do not touch) | `android/.../ime/` | — |

MockData: `ios/MochiApp/MockData/MockData.swift` (added `wallpapers`, `rankedCreators`).
Theme→render bridge: `ios/MochiApp/Data/RenderableTheme.swift` (only 2 built-in themes render for real).

---

## Decision log (why things are the way they are)

- **NavigationStack, not more booleans.** `RootView` had `selectedTheme`/`showProfile`/`showSearch`
  flags; 4 more screens + creator-profile + Settings-from-Profile needed a real stack. `AppRoute` is
  a `Hashable` enum carrying `KeyboardTheme` directly (it's already `Hashable`), so no id-lookup
  table (Android needed `ThemeCache` only because Compose routes are strings).
- **`AppSettingsStore` uses `UserDefaults(suiteName: "group.com.mochi.app")`, not `.standard`.** On
  iOS the keyboard is a *separate process* (unlike Android's same-process IME), so it must read the
  toggles from the shared App Group container — same identifier `ThemeStore` uses. `.standard` would
  silently not reach the keyboard.
- **No StoreKit.** See premise #2.
- **Wallpapers is one grid, not three.** Android's own header says it abandoned the Figma
  sidebar+3-grid layout for phone width; the real `liveWallpapers` schema has no
  category/likeCount/createdAt to group by. Category chips are decorative.
- **Leaderboard period tabs + follow toggles are local-only** — no backend query behind them.
- **Onboarding shows once per install** (`@AppStorage("mochi.hasSeenOnboarding")`), then straight to
  Main. Previously it was skipped entirely whenever `AppContainer.shared == nil`.
- **`ThemeDetailViewModel.isUserPremium`** is now a computed read of `BillingRepository.shared`
  (was hardcoded `false`). Not `@Published`, so it refreshes on nav re-render, not live — fine for now.

---

## The blocker + owner

**`ios/MochiApp/GoogleService-Info.plist` does not exist. Only Sujal can provide it** (register an
iOS app for the `mochi-940bd` Firebase project, bundle id `com.mochi.app`). Until it lands:
`AppContainer.shared == nil`, every screen runs on MockData, and Auth / publish / real likes /
follows / moderation / FCM cannot execute. All that code is written and dormant — do **not**
re-litigate this or try to synthesise the plist from Android's `google-services.json` (the iOS
`GOOGLE_APP_ID` must be registered, it can't be derived).

---

## Build reality

```
cd ios && xcodegen generate
xcodebuild build -project Mochi.xcodeproj -scheme MochiApp \
  -destination "platform=iOS Simulator,id=FA5DF16D-851C-453B-B9D2-963B4361154A"
```

- Toolchain: **Xcode 26 / Swift 6.3** (CI moved to `macos-26` — see commit `cf6b302`, `bb6a6b5`).
- Warm incremental build ≈ 3–5 min. Cold (Firebase C++ recompile) ≈ 12 min.
- **Disk is tight** — was down to ~120 MB free mid-session. Before a heavy session, clear
  `~/Library/Developer/Xcode/DerivedData/{ModuleCache.noindex, non-Mochi projects}`. Keep
  `Mochi-dapmslrxdlqigscuhujivdiinjxx`.
- Screenshots: the loose-PNG write in `ScreenshotUITests` still fails silently; pull them from the
  `.xcresult` with `xcrun xcresulttool export attachments --path <bundle> --output-path <dir>`.
- Simulator UDID: `FA5DF16D-851C-453B-B9D2-963B4361154A` (iPhone 16 Pro).

---

## Deliberate gaps — do NOT "fix" these unprompted

- **Fonts** is MockData-permanent on both platforms (fixed built-in catalogue, not Firestore).
- Wallpaper **category chips** are decorative (no backing field). Same for Leaderboard's
  Filter/Sort icons and the "This Month"/"All Time" period tabs (all reuse the same list).
- **No `isVerified` / avatar-photo field** exists anywhere in the schema — real creators never show
  a verified badge or a real photo (neutral fallback). Only MockData paths pass `isVerified: true`.
- Real Firestore themes render as the **procedural placeholder** (`imageAssetName = "firestore:<id>"`
  matches no asset, no remote image loader exists). `RenderableTheme` maps every catalogue theme to
  one of the **2** built-in renderable themes; non-exact matches say so in the UI.
- **Other-creator Profile** (`.profile(uid:)` with a non-nil uid) still shows the signed-in user's
  mock profile — the screen has no ViewModel yet. `uid` only toggles own-vs-other affordances.
- `functions/src/reports.ts` has an uncommitted `'hidden'` moderation-status change in the working
  tree — pre-existing, not this effort's, leave it.

## Do NOT touch

- **`ios/MochiShared/`** — the keyboard renderer. It works, it's the largest compile unit, and it's
  out of scope. The in-app preview (`KeyboardThemePreview` / `KeyboardTestBench` in
  `MochiApp/Components/`) is the only surface that consumes it.
- Existing pixel-tuned screens' layout math — until the user names that screen for a polish pass.

---

## Session log — what landed

| Commit | What |
|---|---|
| `cf6b302` | Swift 6.3 / Firebase 12 build fixes (app didn't compile on Xcode 26) |
| `bb6a6b5` | Keyboard-theme-system committed into the app target + small label/CI fixes |
| `a165cb6` | Theme apply flow + live keyboard preview + real Search + Home nav |
| `b747008` | Revert Home library-toggle gating (user wanted both sections shown) |
| `69bca15` | **This pass**: NavigationStack + Settings/Paywall/Wallpapers/Leaderboard + assets + MockData |
| `e9bfbf8` | Remove stray `q8.py` |

## Known-incomplete after this pass (candidates for the page-by-page session)

- All 4 new screens: pixel-tune to their Figma frames; wire their still-decorative controls.
- Profile: real ViewModel, own-vs-other, wire Edit Profile / see-all / liked-theme taps.
- Search: persist recent searches; wire Trending / Suggestion chips; the Free/Premium/Newest filters.
- Create: the colour pickers / sliders / eyedropper / effects still don't change the theme; live
  preview doesn't update.
- Theme Detail: Share button; make `isUserPremium` live.
- Home: the 3 recently-applied thumbnails are flat art (could be live keyboards); no notification bell.
- Themes / Fonts: Preview/Apply/download icons; category pills don't filter.
- Community: the other two "see all"s; the top search box → Search.
