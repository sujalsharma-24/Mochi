---
name: project-mochi-accounts
description: "All required external accounts for Mochi — who creates them, who pays, and what they're for"
metadata: 
  node_type: memory
  type: project
  originSessionId: f7b11015-d7e5-40a3-9089-fe2f54d48fee
---

# Mochi — Required Accounts

All accounts except GitHub are created under the **client's name and ownership**. Developer does not hold any credentials.

---

| Account | Who Creates | Who Pays | Cost | Purpose |
|---|---|---|---|---|
| Firebase (Spark → Blaze) | Client | Client | Free → usage-based | Database, Storage, Auth, FCM, hosting |
| Google Play Console | Client | Client | $25 one-time | Android app submission |
| Apple Developer Program | Client | Client | $99/year | iOS app submission + Apple Sign-In |
| RevenueCat | Client | Client | Free tier (scales) | Subscription management, paywall analytics |
| Stripe | Client | Client | % per transaction | Payment processing (through RevenueCat) |
| Cloudflare / AWS CloudFront | Client | Client | Usage-based | CDN for theme images + font delivery |
| Branch.io | Client | Client | Free tier available | Deep links (replaces Firebase Dynamic Links) |
| Google Cloud Vision API | Client | Client | 1000 free/month then ~$1.50/1000 | UGC image moderation |
| GitHub / GitLab | Developer | Developer | Free | Source code repo + CI/CD (GitHub Actions) |

---

## Notes

- All store submissions go through client's accounts (app appears under client's developer identity)
- Client must set up Firebase before development can begin — developer needs Firebase config files
- Apple Developer account setup takes 1–2 days for approval — must be done early
- RevenueCat connects to both App Store Connect and Google Play Console — needs access to both
- Running costs (Firebase, CDN, Vision API) are entirely client's responsibility post-launch
