---
name: project-mochi-constraints
description: "Non-functional requirements, known technical limitations, and platform constraints for Mochi"
metadata: 
  node_type: memory
  type: project
  originSessionId: f7b11015-d7e5-40a3-9089-fe2f54d48fee
---

# Mochi — Constraints & Non-Functional Requirements

---

## Performance Requirements (from Proposal)

| Metric | Target |
|---|---|
| App launch time | < 2 seconds |
| Theme download on 4G | < 3 seconds |
| Keyboard preview update | Real-time (no perceptible lag) |
| Security | HTTPS / TLS 1.2+ for all network calls |

---

## iOS Keyboard Extension Constraints

- **Memory ceiling:** client originally stated ~60–70MB. **Corrected in TRD session (2026-07-09):** real-world empirical reports (Apple Developer Forums, production keyboard-extension GitHub issues) cluster lower, ~40-50MB effective before Jetsam kills the process — Apple never published an official number. **Design and test against a ~40MB worst case**, not 60-70MB. See [[project-mochi-trd]].
- **Full Access permission:** Required only for theme sync / premium entitlement checks — NOT for basic typing. Apple Guideline 4.4.1 requires the keyboard to remain fully functional (typing, autocorrect, swipe) without Full Access or network. Firebase SDK must never run inside the keyboard extension process itself (proxied through the main app via App Group instead) — see [[project-mochi-trd]] ADR-006.
- **No background processing** in keyboard extension — everything must be fast and synchronous within the memory budget
- **Animations — v2 TRD final call (Core Animation wins):** v1 TRD reversed the client's original "Core Animation preferred" assumption to SpriteKit; v2 TRD reversed it back to **Core Animation (`CAEmitterLayer`)** with better sourcing (SKScene render-loop overhead vs. CAEmitterLayer compositing directly into the UIKit view hierarchy). Flagged medium-confidence — prototype on-device before fully committing. See [[project-mochi-trd]] CHANGE-008.
- **Font rendering:** Custom fonts must be implemented as Unicode lookalike characters (not system font loading, which is restricted in extensions)

---

## Platform & Submission

- **Apple Developer Program:** $99/year (client's account)
- **Google Play Developer:** $25 one-time (client's account)
- **App Store Review:** Apple reviews keyboard apps closely — Full Access justification must be documented
- **Huawei AppGallery:** NOT in scope for this contract — separate cost if desired later

---

## Deprecated / Replaced Technologies

| Technology | Status | Replacement |
|---|---|---|
| Firebase Dynamic Links | **DEPRECATED August 2025** | **Resolved (TRD session, 2026-07-09): native Universal Links (iOS) + App Links (Android) + a small static HTML redirect page for store-fallback. NOT Branch.io** — Branch.io removed its free tier in July 2025 and now starts at $199/mo, which would consume the entire $425 dev budget in ~2 months. See [[project-mochi-trd]] ADR-005. |

**Critical:** Do not use Firebase Dynamic Links anywhere in the codebase or documentation. Do not integrate Branch.io — cost-prohibitive at this budget.

---

## UGC / Content Moderation Requirements

- Apple and Google both require moderation for user-generated content in apps
- Gallery images used as keyboard backgrounds go through **Google Cloud Vision API** before being published to Community
- Free tier: 1,000 scans/month (likely sufficient early on); scales with usage, billed to client
- Report button on every Community theme card — after threshold of reports, auto-hide pending review
- No comments = reduced moderation surface

---

## Subscription / Billing Constraints

- RevenueCat free tier handles cross-platform receipt validation, paywalls, trial logic
- App Store / Play Store handle actual billing — no direct card storage by the app
- Stripe connected for web payments / fallback (through RevenueCat)
- Apple requires: if any OAuth offered → Apple Sign-In must also be offered
- Apple requires: in-app purchases must go through App Store billing — no external payment links inside the app

---

## Scalability

- Firebase Firestore + Firebase Storage (Spark plan → upgrade to Blaze as needed)
- CDN (Cloudflare or AWS CloudFront) for theme preview images and font file delivery
- Firestore weekly leaderboard: uses weekly-reset query pattern (not stored leaderboard — computed on query)

---

## Localization

- 4 languages supported
- Thai language included — client aware of complexities (Thai script rendering in keyboard extension is non-trivial)
- Specific language list to be confirmed by client

---

## iOS Version Nuance

- **iOS 15 minimum** (not 16 as originally stated by client — corrected during discovery)
- Live wallpapers on iOS keyboard: technically limited — implementation approach to be determined during architecture phase
- Wallpaper on iOS home screen / lock screen: separate capability from keyboard background, not in scope