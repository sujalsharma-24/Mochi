# Mochi Project — Memory Index

## Project
- [project_mochi_overview.md](project_mochi_overview.md) — Client, budget ($425), timeline (3wk), platform (iOS first → Android), tech stack, delivery terms
- [project_mochi_features.md](project_mochi_features.md) — Complete locked V1 feature spec: all 10 screens, every feature, monetization, effects, stickers
- [project_mochi_decisions.md](project_mochi_decisions.md) — All 14 locked decisions + 1 deferred (stickers source); pricing $2.99/$19.99; no comments; iOS first
- [project_mochi_constraints.md](project_mochi_constraints.md) — iOS ~40MB keyboard memory ceiling (corrected), Full Access req, no Firebase Dynamic Links, no Branch.io
- [project_mochi_accounts.md](project_mochi_accounts.md) — Required accounts (Firebase, Apple Dev, Google Play, RevenueCat, etc.) — all under client's name
- [project_mochi_trd.md](project_mochi_trd.md) — TRD: serverless BaaS architecture, Firestore schema, no REST/GraphQL, ADRs, compliance gaps (Block-user feature added)
- [project_mochi_devenv.md](project_mochi_devenv.md) — No Mac/no cloud Mac budget: iOS previewed via CI screenshots only; Android now primarily verified via a real adb build/install/screenshot loop on Sujal's phone (not just Compose Preview)

## Session Log & Changes
- [project_mochi_sessions.md](project_mochi_sessions.md) — Chronological session log: Sessions 1–8 logged; Home screen Figma-parity STILL NOT fully confirmed after 4 sessions (Session 8 = real Android build/adb loop unlocked, many fixes landed, nav-bar-thinning round unconfirmed, lots of uncommitted work)
- [project_mochi_changelog.md](project_mochi_changelog.md) — 14 corrections: 7 from discovery, 6 from TRD v2 redo (CHANGE-008–014), SpriteKit→CoreAnimation reversal

## Self-Improving
- [project_mochi_learnings.md](project_mochi_learnings.md) — Compounding lessons: client patterns, what worked, red flags; Session 8 = ratio-based sizing beats absolute px→dp, extract mismatched assets from Figma directly, always verify adb foreground app before tap/screenshot (WhatsApp incident)

## User
- [user_sujal.md](user_sujal.md) — Sujal Sharma: first-time freelancer, informal pace, delegates decisions, switches to Hinglish during UI review, genuinely means pixel-perfect
