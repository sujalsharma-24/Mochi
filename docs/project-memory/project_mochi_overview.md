---
name: project-mochi-overview
description: "Mochi keyboard app — client, budget, timeline, platform, tech stack, and delivery terms"
metadata: 
  node_type: memory
  type: project
  originSessionId: f7b11015-d7e5-40a3-9089-fe2f54d48fee
---

# Mochi — Project Overview

**App Name:** Mochi
**GitHub Repo:** https://github.com/sujalsharma-24/Mochi
**App Type:** Custom keyboard replacement (IME) — Android + iOS
**Client:** Australian client (name not disclosed)
**Developer:** Sujal Sharma (freelance, first client)
**Budget:** $425 (fixed price, developer keeps full amount)
**Timeline:** 3 weeks
**Communication:** WhatsApp updates
**Revisions:** 3 included; additional revisions charged extra
**Source Code Delivery:** Yes — full source delivered to client

**Why:** Client wants a premium keyboard theme social app. Developer is building to impress first client and secure repeat work.

---

## Platform & Release Order

| Platform | Min OS | Release Order |
|---|---|---|
| iOS | iOS 15 | First |
| Android | Android 8.0 (API 26) | Second |

**iPad:** Full support, optimized layout
**Huawei (AppGallery):** Separate cost — not in this scope

---

## Tech Stack

| Layer | Technology |
|---|---|
| iOS | Swift |
| Android | Java + Kotlin |
| Database | Firebase Firestore |
| Storage | Firebase Storage |
| Auth | Firebase Auth |
| Push | FCM (Firebase Cloud Messaging) |
| Subscriptions | RevenueCat + Stripe |
| Asset Delivery | Cloudflare / AWS CloudFront (CDN) |
| Image Moderation | Google Cloud Vision API |
| Deep Links | Branch.io or Universal Links / App Links (NOT Firebase Dynamic Links — deprecated Aug 2025) |
| CI/CD | GitHub + GitHub Actions |
| Design | Figma (provided by client) |

**Design Responsibility:** Client provides Figma designs; developer implements them. Client reviews all screens before implementation.

---

## Languages Supported

4 languages (specific languages TBD by client). Thai language support included; client is aware of Thai keyboard complexity.

---

## Required Accounts (Client's Responsibility)

See [[project-mochi-accounts]] for full account list.

---

## Delivery Terms

- App submitted under **client's** developer accounts (Google Play, Apple Developer)
- Client handles post-launch operations
- Running costs (Firebase, CDN, APIs) paid by client
- Source code fully delivered to client on completion
