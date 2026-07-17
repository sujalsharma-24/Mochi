---
name: project-mochi-trd
description: "Mochi Technical Requirements Document v2 — architecture, data model, API layer, and ADRs, fully re-verified via a from-scratch research redo"
metadata: 
  node_type: memory
  type: project
  originSessionId: f126648b-e079-4a79-8478-a063017b8174
---

# Mochi — TRD & Architecture (v2, same-day full redo, 2026-07-09)

Full TRD is at `C:\Users\ACER\Desktop\Mochi\docs\TRD.md` (v2) and published as an Artifact. v1 was written earlier the same day; Sujal asked for a full from-scratch redo (not incremental review) rather than reusing v1's conclusions, so five parallel research agents re-verified every claim independently. This memory captures only what's surprising/non-obvious and what changed — read the TRD itself before implementation.

## Key architecture calls (reconfirmed from v1, still current)
- **No custom backend, no Firebase Data Connect either** (Data Connect reached GA April 2025 but is Postgres-backed with an always-on paid instance — evaluated and rejected as wrong fit). Clients talk directly to Firestore/Storage/Auth; Cloud Functions handle only privileged logic.
- **No REST/GraphQL API** — Firestore SDK + Security Rules + App Check is the API contract.
- **Keyboard extension: no Firebase SDK ever runs in the extension process** — confirmed with concrete GitHub issue citations (firebase-ios-sdk #12992, #6211, #8445). Reads cached state from App Group container; auth shared via Keychain (`useUserAccessGroup`) — note this does NOT sync in real time across processes, design for "app writes, extension reads on next activation."

## What changed from v1 to v2 (six corrections — full detail in [[project-mochi-changelog]] CHANGE-008 through CHANGE-014)
1. **Particle effects reversed back to Core Animation (`CAEmitterLayer`), not SpriteKit** — v1 had corrected the client's original assumption to SpriteKit; v2 reverses that correction again with better sourcing (SKScene render-loop overhead vs. CAEmitterLayer's direct view-hierarchy compositing). Flagged as medium confidence — no direct evidence SpriteKit crashes in extensions, this is architectural reasoning. Prototype either on-device before fully committing.
2. **Memory ceiling tightened**: ~30-40MB dirty memory (not a flat "~40MB"), ~77MB total hard cap, memory warning fires ~55MB. Sourced from a dated Nov 2024 CoreText/emoji-glyph-cache production postmortem directly relevant to Mochi's Unicode-lookalike custom fonts.
3. **App Check is now a concrete decision** (App Attest iOS + Play Integrity Android, free at Mochi's scale) — v1 had only flagged it as a gap.
4. **New, time-sensitive finding entirely absent from v1**: `functions.config()` is deprecated — underlying API shuts down 2025-12-31, deployments fail after March 2027. Must use `defineSecret()`/Secret Manager + `.env` from the first line of Functions code, since code is being written now.
5. **New cost trap**: GitHub Actions macOS runners bill at ~10x the Linux rate. Every CI workflow must be path-filtered per platform from day one or an Android-only commit burns 10x-cost macOS minutes for nothing.
6. **Age rating corrected**: v1's ADR-009 said target "13+" — should be 17+/18+-equivalent under Apple's new (July 2025) rating system, standard practice for open-publish UGC apps. Store-metadata-only fix, no feature impact, but wrong initial submission risks resubmission.

## Everything else reconfirmed unchanged from v1
Serverless BaaS architecture, no REST/GraphQL, Firestore schema shape (with one addition, below), Cloudflare over CloudFront (sharper reason: Cloudflare Free has *unmetered* bandwidth vs CloudFront's 1TB-then-metered), no Branch.io (still no permanent free tier since ~July 2025, reconfirmed independently), RevenueCat free until $2,500 MTR, two environments not three (refined — see below), Firestore pricing corrected slightly cheaper than v1 modeled (reads are $0.06/100k not $0.18/100k; v1 conflated the read and write price).

## Schema addition (new in v2, not a correction — a gap v1 missed)
`themes/{id}` now also stores `creatorDisplayName`/`creatorAvatarUrl` (denormalized, not just `creatorUid`), kept in sync by a new `onProfileUpdate` Cloud Function fan-out trigger. v1's schema would have forced an extra per-card user-doc read to render theme feed cards (N+1 read problem at feed scale) — caught by this pass's architecture research into Firestore's lack of joins.

## Environment strategy refined (not reversed)
v1: two Firebase projects (`mochi-dev`, `mochi-prod`), no staging. v2 refines: use the **Firebase Emulator Suite as the primary local-dev environment** (free, fast, tests Security Rules pre-deploy); keep `mochi-dev` cloud project only for what the emulator can't cover — FCM push and RevenueCat webhook testing specifically. Still no staging tier.

## New compliance item surfaced this pass
**Apple's Sticker Guidelines apply directly** (Mochi ships stickers/emoji in the keyboard panel) — this is a concrete reason to resolve the still-deferred stickers-source decision (see [[project-mochi-decisions]]) before the sticker panel is built, since licensed-pack or user-uploaded options carry IP/rights compliance obligations that client-provided original art doesn't. Recommend Sujal raise this with the client soon rather than deferring further.

**Why:** This TRD exists so implementation sessions don't reinvent or contradict these calls, and this v2 exists so a from-scratch verification pass catches drift/errors from v1 before any code is written against it. See [[project-mochi-decisions]], [[project-mochi-constraints]], [[project-mochi-features]] for the product-level spec this bridges from, and [[project-mochi-changelog]] for the full before/after on every correction.
**How to apply:** Before writing iOS/Android/Cloud Functions code, check this file and the full TRD v2 first — especially the Firestore schema (§03), the "no Firebase in the keyboard extension" rule (§01/ADR-006), the CAEmitterLayer-not-SpriteKit call (§02/ADR-002, but treat as medium-confidence and prototype first), and the `functions.config()` ban (§07/ADR-012), since violating any of these is expensive to unwind later.
