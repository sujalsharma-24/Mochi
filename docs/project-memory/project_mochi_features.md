---
name: project-mochi-features
description: Complete locked feature spec for all 10 screens of the Mochi keyboard app
metadata: 
  node_type: memory
  type: project
  originSessionId: f7b11015-d7e5-40a3-9089-fe2f54d48fee
---

# Mochi — Complete Feature Spec (Locked V1)

**Screens:** 10 core screens + keyboard panel components
**Theme Count:** 250 at launch (30% free, 70% premium)
**Free/Premium Split:** 30% free / 70% premium (premium from day 1, no free-then-paid model)

> **Navigation (Figma correction, Session 3):** Real bottom-nav is **5 tabs** — Keyboard, Fonts, Create (center FAB), Themes, Community. The written spec implied a single combined Explore/Store tab; Figma shows 5 discrete tabs. Figma wins. See [[project-mochi-decisions]].

---

## Screen 1 — Splash / Onboarding

- Animated Mochi logo on splash
- 3–4 onboarding slides showing key features (themes, community, effects)
- "Get Started" button → Auth screen
- **No skip / No guest mode** — login required to proceed
- Keyboard setup instructions (how to enable as system keyboard on device)
- iOS: Full Access permission prompt with explanation of why it's needed

---

## Screen 2 — Authentication

**Login Methods:**
- Email + Password
- Google Sign-In (OAuth 2.0)
- Apple Sign-In (OAuth 2.0 — mandatory on iOS when other OAuth is offered)
- Phone Number + OTP

**Additional:**
- Forgot Password / Reset via email
- Terms of Service acceptance on register
- No guest mode

---

## Screen 3 — Home Dashboard

- Currently active keyboard theme shown as live preview
- Quick-change strip: recently used / downloaded themes
- "For You" recommended themes section (from Explore)
- New Releases horizontal strip
- Featured Collections shortcut
- Push notification bell icon (top bar)
- Shortcut button to Create screen

---

## Screen 4 — Explore / Store

**Search:**
- Search bar: searches name, hashtags, color, style, category
- Filter panel: color, style, category, price (free / premium)
- Sort options: Popular, New, Top Rated

**Sections:**
- Trending themes grid
- Collections (curated subsets of the 250 themes)
- Live Wallpapers section (5 wallpapers at launch)
- All Themes grid (250 total — 30% free / 70% premium with lock icon)

**Premium Indicator:** Lock icon on premium themes; tapping triggers paywall

---

## Screen 5 — Theme Detail

- Live interactive keyboard preview (user can type to see theme in action)
- Theme name + description
- Hashtags (tappable → filters community/explore by hashtag)
- Creator credit (tappable → creator's profile)
- Like button + like count
- Download / Apply button
- Premium badge → triggers Paywall screen if locked
- Share button (deep link via Universal Links (iOS) + App Links (Android) — NOT Firebase Dynamic Links, NOT Branch.io — Branch.io lost free tier July 2025, $199/mo minimum)

---

## Screen 6 — Create Screen

**4 Tabs:**

### Background Tab
- Solid color (full color picker)
- Gradient (2-color picker + direction selector)
- Gallery image (photo library upload for keyboard background only; Google Cloud Vision moderation on publish)

### Keys Tab
- Key shape selector: rounded / sharp / pill / square
- Key background color (color picker)
- Border width + border color
- Shadow toggle

### Fonts Tab
- Choose from available custom fonts (rendered as Unicode lookalike characters)
- Font size slider
- Bold / Regular toggle

### Effects Tab
- **Key-press effects:** sparkles, hearts, ripple, neon glow (plays on each key tap)
- **Background effects:** falling stars, floating bubbles, glowing particles (ambient during typing)
- **Trail effects:** swipe path color / glow (for swipe/gesture typing)
- Free users: 1–2 basic effects (e.g., ripple only); Premium: all effects

**Other Create Screen Features:**
- Real-time keyboard preview panel at top (updates live as user customizes)
- Save options: Save Private / Publish to Community
- Hashtag picker when publishing (for discoverability)

---

## Screen 7 — Community

**Feed Tabs:** For You / Popular / Latest / Following / My Likes

**Theme Card includes:**
- Preview image
- Theme name + creator
- Like count + Like button
- Report button (UGC moderation)
- **No comments**

**Leaderboard:**
- Weekly reset (Firestore query pattern)
- Ranked by total likes
- Filterable by time period
- Shows top creators

**Hashtag Browsing:**
- Tapping a hashtag → filtered feed

---

## Screen 8 — Profile

**Own Profile:**
- Avatar (from auth provider or upload)
- Username + bio (editable)
- Settings shortcut
- Tabs: My Themes / Liked Themes

**Other User's Profile:**
- Follow / Unfollow button
- Follower / Following count
- **Block button** — added in TRD session (2026-07-09), not in original proposal. Apple Guideline 1.2 requires UGC apps to offer both Report and Block; original spec only had Report. See [[project-mochi-trd]].

**Shared:**
- Published themes grid
- Like stats (given / received)
- Creator credit links back here from Theme Detail

---

## Screen 9 — Settings

**Account:**
- Change email / password
- Delete account

**Subscription:**
- Current plan display
- Upgrade / Downgrade / Cancel (via RevenueCat)
- Restore Purchase option

**Keyboard:**
- Autocorrect toggle
- Swipe typing toggle
- Haptic feedback toggle
- Key click sound toggle

**Notifications:** Push notification preferences (toggles per category)
**Language:** Select from 4 supported languages
**Privacy:** Data preferences
**About:** App version, Terms of Service, Privacy Policy, Open Source Licenses
**Logout**

---

## Keyboard Panel Components (within active keyboard)

### Emoji / Stickers Panel
- Standard Unicode emoji keyboard
- Sticker packs (source TBD — see [[project-mochi-decisions]])
- Organized by categories / packs
- Search within emoji / stickers

### Keyboard Functional Features
- Autocorrect (toggleable)
- Swipe / gesture typing (toggleable)
- Haptic feedback
- Key click sounds
- Number row
- Special characters row

---

## Paywall / Subscription Screen

- Triggered when tapping any premium-locked content
- Plan A: **$2.99 / month** with 3-day free trial
- Plan B: **$19.99 / year** ("Most Popular" badge) with 3-day free trial
- Lists what premium unlocks (all premium themes, fonts, effects, stickers)
- Restore Purchase button
- Managed via RevenueCat + App Store / Play Store native billing
- No direct card collection (App Store / Play Store handle it)

---

## Live Wallpapers

- 5 animated wallpapers at launch (all premium)
- Additional wallpapers available at extra cost later (separate payment to developer)
- Shown in Explore under Live Wallpapers section + applicable in Create > Background

---

## Notifications (FCM)

- New theme from followed creator
- Weekly leaderboard ranking update
- New feature announcements
- Subscription reminders (pre-trial-end)
