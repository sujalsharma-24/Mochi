---
name: project-mochi-changelog
description: "Running log of every correction, reversal, or scope change in the Mochi project — what changed, why, and when"
metadata: 
  node_type: memory
  type: project
  originSessionId: f7b11015-d7e5-40a3-9089-fe2f54d48fee
---

# Mochi — Changelog (Corrections & Scope Changes)

This file tracks every time something changed from what was previously stated. Essential for catching contradiction patterns and keeping the spec reliable.

---

## Session 1 Changes (July 8, 2026)

### CHANGE-001: iOS Minimum Version
- **Before:** iOS 16 (client stated initially)
- **After:** iOS 15 (client corrected)
- **Why:** Client revised their answer during discovery
- **Impact:** Slightly broader device support; no feature impact

---

### CHANGE-002: Gallery Uploads
- **Before:** No gallery uploads (client said in early Q&A)
- **After:** Gallery upload allowed in Create screen → Background tab only (for keyboard background image)
- **Why:** Figma design clearly shows gallery picker in Create screen — client's words contradicted their own design
- **Impact:** Must implement photo library picker on Create screen. Must also implement UGC moderation for images on publish.

---

### CHANGE-003: Pricing (Typo Fix)
- **Before:** $199/month and $999/year (client listed — clearly a typo for a keyboard app)
- **After:** $2.99/month and $19.99/year, 3-day free trial (decided by assistant)
- **Why:** Original pricing was obviously wrong (~4x higher than any comparable app); client delegated decision
- **Impact:** RevenueCat product IDs will use the corrected pricing

---

### CHANGE-004: Comments Removed
- **Before:** Comments listed as a social feature
- **After:** No comments in V1 scope
- **Why:** Proposal did not mention comments; client confirmed removal when asked to decide
- **Impact:** Removes comment thread UI, reduces moderation surface, simplifies Community screen

---

### CHANGE-005: Free / Premium Split Reversed
- **Before:** 70% free / 30% premium (noted in early session summary)
- **After:** 30% free / 70% premium (client corrected — aggressive monetization from day 1)
- **Why:** Client wants to monetize heavily from launch; early summary had it backwards
- **Impact:** ~75 free themes out of 250; most content behind paywall; strong paywall conversion pressure

---

### CHANGE-006: Firebase Dynamic Links → Deprecated
- **Before:** Firebase Dynamic Links planned for share/deep links
- **After:** Firebase Dynamic Links shut down August 2025; cannot use
- **Replacement:** Branch.io OR Universal Links (iOS) + App Links (Android)
- **Why:** Firebase deprecated the service; discovered during requirements research
- **Impact:** Need to choose Branch.io or roll hand-crafted deep links. Added to constraints.

---

### CHANGE-007: Following Feed Location
- **Before:** "Following" described as a separate screen
- **After:** "Following" is a tab within the Community screen (tabs: For You / Popular / Latest / Following / My Likes)
- **Why:** Clarified during discovery — it's a filter tab, not a standalone screen
- **Impact:** Community screen has 5 tabs; screen count stays at 10

---

## TRD v2 Changes (July 9, 2026 — same-day full redo of the TRD)

Client/Sujal asked for a full from-scratch re-research of the TRD (not incremental review) a few hours after v1 was written. Five parallel research agents re-verified every claim. Six corrections resulted — see [[project-mochi-trd]] for full detail:

### CHANGE-008: Keyboard extension particle effects — SpriteKit reversed back to Core Animation
- **Before (v1):** SpriteKit (`SKEmitterNode`) — this itself had corrected the client's original "Core Animation preferred" assumption
- **After (v2):** Core Animation (`CAEmitterLayer`) — reverses v1's correction back to the original instinct, but for a different, better-sourced reason (SKScene/SKView render-loop overhead vs. CAEmitterLayer compositing directly into the UIKit view hierarchy)
- **Why:** Fresh research found SpriteKit's render loop is heavyweight for a compact, intermittently-visible keyboard accessory view under the memory budget. No source proves SpriteKit crashes in extensions specifically — this is reasoning + comparative perf data, flagged as medium confidence.
- **Impact:** Effects implementation approach changes; re-prototype before fully committing.

### CHANGE-009: Memory ceiling tightened further
- **Before (v1):** ~40MB effective ceiling
- **After (v2):** ~30-40MB dirty memory (practical budget), ~77MB total hard cap, memory warning fires ~55MB
- **Why:** Better-sourced figures from a dated Nov 2024 production postmortem (CoreText/emoji glyph cache case study, directly relevant to Mochi's Unicode-lookalike custom fonts)
- **Impact:** Build cache-flushing on the system memory-warning callback from day one; test dirty memory in Instruments in week 1, not later.

### CHANGE-010: App Check — gap closed into a firm decision
- **Before (v1):** Flagged as "a gap, should be added" with no specifics
- **After (v2):** Concrete: App Attest (iOS) + Play Integrity (Android) enabled on Firestore/Storage/callable Functions from launch, confirmed free at Mochi's scale
- **Why:** Firebase's own security checklist explicitly recommends it; closes the "scraped API key from a script" hole Security Rules alone can't close
- **Impact:** New setup step in Cloud Functions/client config, no cost impact.

### CHANGE-011: `functions.config()` deprecation — new, was missing entirely from v1
- **Before (v1):** Not mentioned
- **After (v2):** Cloud Runtime Configuration API (underlying `functions.config()`) shuts down 2025-12-31; deployments using it fail after March 2027. Must use `defineSecret()`/Secret Manager + `.env` from the first line of Functions code.
- **Why:** Time-sensitive Firebase deprecation discovered in this research pass, directly relevant since Functions code is being written now
- **Impact:** Affects how every Cloud Function reads config/secrets — must be built right from day one, not migrated later.

### CHANGE-012: GitHub Actions macOS runner cost trap — new
- **Before (v1):** GitHub Actions named as CI/CD tool, no cost-structure detail
- **After (v2):** macOS runners bill at ~10x the Linux rate (~$0.062/min vs ~$0.006/min); every workflow must be path-filtered per-platform so an Android/Functions-only commit doesn't burn 10x-cost macOS minutes
- **Why:** New research finding
- **Impact:** CI workflow files must be written path-filtered from the start (`ios-build.yml` scoped to `ios/**`, etc.) — cheap to do correctly first, annoying to retrofit.

### CHANGE-013: Age rating corrected from 13+ to 17+/18+-equivalent
- **Before (v1, ADR-009):** "13+, not Families/4+"
- **After (v2):** Target the new (July 2025 Apple overhaul) system's highest non-mature band appropriate for open-publish UGC apps — equivalent to the old 17+, not 13+
- **Why:** v1's instinct (avoid Kids category) was right, but UGC apps with unmoderated-until-reported content are conventionally rated in the higher band; v1 landed on the wrong specific number
- **Impact:** Store-listing metadata only, no feature-scope change — but wrong initial submission risks a resubmission cycle.

### CHANGE-014 (minor, schema addition): Denormalized creator fields on theme docs
- **Before (v1):** `themes/{id}` only stored `creatorUid`
- **After (v2):** Also stores `creatorDisplayName`/`creatorAvatarUrl`, kept in sync by a new `onProfileUpdate` Cloud Function fan-out trigger
- **Why:** v1's schema would have forced an extra per-card user-doc read to render theme feed cards (N+1 read problem) — caught by this pass's architecture research
- **Impact:** One new Cloud Function; otherwise transparent to the client.

---

<!-- Template for future changes:

### CHANGE-NNN: [Short Title]
- **Before:** [What was previously stated]
- **After:** [What it is now]
- **Why:** [Reason for change — client correction / Figma contradiction / market research / etc.]
- **Impact:** [What this affects in the build]

-->

---

### CHANGE-015: Login Screen — Layout and Gradient Redesign
- **Before:** Plain gradient background auth layout with a `ModeToggle` Sign In/Sign Up pill switcher at the top, list-style social buttons (full-width rows for Google and Apple with text labels), flat text fields with no icons.
- **After:** Wavy bezier curved top header with Mochi's warm pink-orchid-purple gradient, white circular leaf logo badge, bold "Welcome" title, clean rounded icon-prefixed input fields, eye-toggle on password, right-aligned "Forgot Password?", icon-only social card buttons, mode switch link at bottom.
- **Why:** Sujal shared a reference screenshot showing a premium login screen layout and requested the screen be redesigned to match.
- **Impact:** `AuthScreen.kt` fully rewritten. `WaveHeaderShape`, `StyledInputField`, `SocialIconCard` composables introduced.

---

### CHANGE-016: Social Login — Facebook Removed, Real PNG Icons Added
- **Before:** Three social buttons (Google, Apple, Facebook). Google and Apple icons were Canvas-drawn placeholders. Facebook button present.
- **After:** Two social buttons only — Google and Apple. Both use official brand PNG assets (`ic_google_logo.png`, `ic_apple_logo.png`) from `drawable-nodpi/`.
- **Why:** Sujal explicitly requested Facebook sign-in be removed. Canvas-drawn logo approximations were visually inaccurate.
- **Impact:** `AuthScreen.kt` updated. Two new PNG assets added to `res/drawable-nodpi/`.

---

### CHANGE-017: Onboarding Screen — Full UI Redesign with PNG Illustrations
- **Before:** Simple feature pages with a plain white box containing an icon from `drawable-nodpi/` (palette, library, create_custom), text below, and a gradient button. Minimal visual design.
- **After:** Premium illustrated onboarding with badge chips, floating glassmorphic illustration cards with drop shadows and purple borders, high-res AI-generated PNG illustrations, Skip button in top bar, "Mochi" wordmark, animated gradient pill page indicator, Continue/Get Started CTA with arrow icon, and a 3-step keyboard setup guide card on the final page.
- **Why:** Sujal requested the onboarding screens be redesigned as they were "not up to the mark." Four high-quality PNG illustrations generated.
- **Impact:** `OnboardingScreen.kt` fully rewritten. Four new PNG assets added: `onboarding_themes.png`, `onboarding_fonts.png`, `onboarding_create.png`, `onboarding_setup.png`.

---

### CHANGE-018: Auth/Onboarding Header Gradient — Deep Violet → Warm Mochi Palette
- **Before (initial redesign attempt):** Deep violet-blue gradient used for the Auth screen header (`#6B21A8` → `#7C3AED` → `#8B5CF6` → `#9333EA`).
- **After:** Warm pink-orchid-purple gradient (`#9012A7` → `#CE76DB` → `#E27FCC` → `#8F7CE9`) matching the existing Home, Themes, and Community screen palette.
- **Why:** Sujal saw the first design on his phone and said the blue color didn't match the rest of the app UI — immediately corrected.
- **Impact:** `HeaderGradient` and `PrimaryButtonGradient` in `AuthScreen.kt` updated. Rebuilt and re-deployed to device.

