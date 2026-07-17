---
name: project-mochi-decisions
description: "All locked product decisions for Mochi — finalized in discovery session, July 2026"
metadata: 
  node_type: memory
  type: project
  originSessionId: f7b11015-d7e5-40a3-9089-fe2f54d48fee
---

# Mochi — Locked Decisions (All Finalized)

All 14 blocking decisions locked as of Session 1 (July 8, 2026).

---

| # | Decision | Answer | Decided By |
|---|---|---|---|
| 1 | iOS minimum version | **iOS 15** | Client (corrected from iOS 16) |
| 2 | Android minimum version | **Android 8.0 (API 26)** | Client |
| 3 | Subscription pricing | **$2.99/month · $19.99/year · 3-day free trial** | Assistant (delegated) |
| 4 | Free / Premium split | **30% free / 70% premium** | Client |
| 5 | Login methods | **Email + Google + Apple + Phone OTP** | Client |
| 6 | Comments | **No comments** | Client (removed from scope) |
| 7 | Effects tab | **In V1** (key-press, background, trail effects) | Client |
| 8 | Stickers & Emojis | **In V1** — source TBD | Client (source deferred) |
| 9 | Live Wallpapers | **5 at launch (all premium)** — more = extra cost | Client |
| 10 | Guest mode | **No guest mode** — login required | Client |
| 11 | UGC photo moderation | **Google Cloud Vision API + Report button** | Assistant (delegated) |
| 12 | Platform release order | **iOS first, then Android** | Client |
| 13 | Autocorrect + Swipe typing | **In scope V1** | Client |
| 14 | Running costs | **Client pays** (Firebase, CDN, Apple Dev, etc.) | Client |
| 15 | Collections | **Curated subsets of the 250 themes** | Client |

---

## Stickers Source — Deferred

Still open. Options to decide:
- **A (Recommended):** Client provides sticker artwork — simplest, no extra cost
- **B:** Use free licensed packs (Flaticon / Icons8)
- **C:** User-uploaded stickers — more dev work, more moderation surface

Decision deferred to a later session. Not blocking development until sticker screen is reached.

---

## Monetization Architecture

- RevenueCat manages subscriptions (cross-platform receipt validation, paywall analytics, trial management)
- App Store / Play Store handle actual billing (no direct card collection)
- Stripe connected via RevenueCat for web fallback if needed
- Free tier: 30% of 250 themes = ~75 themes; all effects except 1 basic; standard fonts only
- Premium tier: all 250 themes, all fonts, all effects, all stickers, live wallpapers

---

## Deep Links

Firebase Dynamic Links are **deprecated as of August 2025**. Do not use.
**Resolved in TRD session (2026-07-09): hand-rolled Universal Links (iOS) + App Links (Android) + a static HTML redirect page for the store-fallback case. NOT Branch.io** — Branch.io lost its free tier in July 2025 and now costs $199/mo minimum, which is not viable at this budget. See [[project-mochi-trd]].

---

## iOS Keyboard Extension Notes

- Memory ceiling: ~60–70MB (hard limit from iOS)
- Full Access permission required for: network calls, Firebase sync, subscription validation
- Effects must be lightweight (Core Animation preferred over SpriteKit)
- Apple Sign-In mandatory (Apple rule: if any OAuth is offered on iOS, Apple Sign-In must also be offered)

**Why:** These are constraints, not decisions — recording here so they're never forgotten during implementation.
**How to apply:** Flag these during any architecture or implementation discussion.

---

## Figma Ground Truth (Session 3, 2026-07-10/11)

Client's Figma was finally reviewed via an exported zip (`docs/figma/1.png`–`13.png`). Two corrections to earlier assumptions:

1. **Real bottom-nav structure is 5 tabs**: Keyboard, Fonts, Create (center FAB), Themes, Community — not a single combined Explore/Store tab as the written feature spec implied. Figma wins per [[project-mochi-learnings]]'s standing rule.
2. **Paywall pricing conflict — resolved, locked spec wins**: Figma screens 11/12 show $199/mo · $999/yr · $1999 lifetime plus a custom UPI/Card/GPay/PhonePe/Paytm payment form. This contradicts the already-locked $2.99/mo · $19.99/yr · 3-day-trial RevenueCat decision (#3 above) — and separately, the custom payment form would violate Apple App Store Guideline 3.1.1 (digital subscriptions must use native IAP, not a custom checkout). Almost certainly an unmodified template frame, not a deliberate client redesign. Sujal confirmed: **build to the locked $2.99/$19.99 spec with native StoreKit/Play Billing buttons via RevenueCat, ignore the Figma numbers and payment form entirely.**

**No Figma source exists for:** Splash/Onboarding, Auth, standalone Theme Detail screen. Sujal chose to have these designed now (matching the established visual language) rather than block on the client providing them.

**Why:** So no future session re-litigates the nav structure or re-discovers the paywall conflict from scratch.
**How to apply:** Treat the 5-tab structure as current truth for any nav-related work. When building the Paywall screen, use locked decision #3's numbers, never the Figma frame's numbers/payment UI.