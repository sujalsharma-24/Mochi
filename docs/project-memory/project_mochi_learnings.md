---
name: project-mochi-learnings
description: "Self-improving knowledge base — lessons learned each session about the client, project patterns, and what to anticipate"
metadata: 
  node_type: memory
  type: project
  originSessionId: f7b11015-d7e5-40a3-9089-fe2f54d48fee
---

# Mochi — Learnings & Self-Improvement Log

This file compounds across sessions. Each session adds new insights so the next session starts sharper. Read this at the start of every session.

---

## About the Client (Australian)

- **Hands-off style:** Client provides Figma and high-level direction, then delegates. Don't expect granular answers — expect to make recommendations.
- **Design-first:** Client has strong design opinions (Figma provided, app icon provided). Design decisions should defer to Figma.
- **Trusts delegation:** When client says "you decide" on pricing, moderation, etc. — commit to a specific recommendation, don't return options. Client doesn't want to be asked again.
- **Typos happen:** Client made a pricing typo ($199/$999 for a keyboard app). When something looks clearly wrong, call it out and propose the fix rather than implementing the wrong thing.
- **Contradicts themselves:** Client said "no gallery uploads" but Figma shows gallery picker. Always cross-reference Figma against verbal answers — Figma wins when there's a conflict.

---

## About Sujal (Developer)

- First freelance client — eager to impress, motivated to do this right
- Wants to finalize everything before touching code — correct approach, support it
- Prefers interactive sessions over long documents — keep responses conversational and structured
- Delegates decisions back to assistant when overwhelmed — give confident, specific answers
- Tends to say "discuss later" when something is non-blocking — honor that, don't push
- Communication is informal and fast-moving — match that pace

---

## Process Patterns That Worked

- **Iterative Q&A** worked better than one massive question dump — client got overwhelmed with 100 questions at once
- **15–20 grouped questions** was the sweet spot for a single round
- **Fable advisory agent** was valuable for trimming and prioritizing questions — use it again for feature review
- **Changelog thinking** caught the free/premium reversal early — always track what changed from what

---

## Things to Anticipate in Future Sessions

- **Figma will be the ground truth** — before any screen is built, cross-check feature spec against Figma
- **iOS first** — when there's ambiguity about platform-specific behavior, default to iOS behavior first
- **Effects tab memory risk** — iOS keyboard extension has a 60-70MB ceiling; effects must be tested for memory impact early
- **Stickers source still open** — first agenda item of next session if not resolved async
- **4 languages** — specific languages not yet confirmed; get this before localization work begins
- **Branch.io setup** — needs to happen early in development (deep links take time to configure and verify)
- **Apple Developer account** — takes 1-2 days for approval; Sujal should remind client to set it up immediately

---

## Red Flags to Watch For

- Client verbal answers contradicting Figma → check Figma
- Scope creep attempts post-contract → enforce 3-revision rule
- "Can we add X?" after spec is locked → document as V2 candidate, don't add to V1
- Huawei / AppGallery mentions → out of scope, separate cost
- iPad UI — full support required, must be optimized (not just scaled)

---

## Session Improvement Notes

### After Session 1
- Discovery session ran too long (context limit hit) — in future, aim to resolve blocking decisions within one focused session
- The 100-question research dump wasted time — the 14-question focused round was far more effective
- Free/premium split was recorded incorrectly in early summary (70/30 → should have been 30/70) — always double-check ratios by asking "which direction is the majority?"

### After Session 2 (TRD / Deep Research)
- **Client-stated technical constraints need independent verification before being locked into architecture.** Two of the client's original technical facts turned out to be off: the 60-70MB keyboard memory ceiling (real-world empirical data says ~40MB) and "Core Animation preferred over SpriteKit" (production apps do the opposite). Neither was a client lie — just secondhand/outdated technical info passed through the proposal. Treat client-provided technical specifics (not product decisions) as needing a research pass before committing code architecture to them.
- **Vendor pricing changes fast — verify before locking a vendor into the stack, even one the client already named.** Branch.io was in the original locked stack list from Session 1; by Session 2 it had lost its free tier and become cost-prohibitive. A stack decision made months before a build starts should be re-verified at build time, not assumed still valid.
- **The deep-research skill's default outline.yaml/fields.yaml pipeline is for comparing N independent items — it doesn't fit a single interdependent system design (one project's architecture, where data model depends on API layer depends on backend choice).** For a TRD-style request, running targeted parallel research agents on the specific open factual questions, then synthesizing directly, worked better than forcing the comparative-items template.

### After Session 2b (TRD full redo, same day as Session 2)
- **When a user asks to redo research that was seemingly just completed, flag the duplication first — but if they still want the redo, do it for real (fresh agents, not a reuse of prior conclusions) rather than a token pass.** Sujal was told v1 already covered everything he was asking for and chose "full redo from scratch" anyway. That was the right call to honor: the redo caught six real corrections (SpriteKit reversed back to Core Animation, tighter memory figures, a time-sensitive Firebase deprecation `functions.config()` that was entirely missing from v1, a CI cost trap, a wrong age-rating number, and a schema N+1 gap). **A same-day re-verification pass is not automatically wasted work** — technical research has a real error rate even a few hours apart, especially for narrow claims (exact framework recommendations, precise memory figures) where the first pass's sourcing was thinner than a dedicated second pass's.
- **Confirming a same-day "redo" wastes less than it looks like if you frame it as verification, not repetition.** The five agents this time were scoped more narrowly and pointedly (e.g., "does SpriteKit specifically fail in extensions, cite a bug report" rather than a broad open question) than Session 2's agents, precisely because v1 gave a starting hypothesis to confirm or overturn — worth doing next time too: point redo-agents at falsifying the prior conclusion, not just re-researching the topic blind.
- **Track corrections with an explicit "v1 said X, v2 says Y, here's why the confidence changed" format** in both the TRD document itself and memory — this is what let six real changes surface clearly instead of being buried in a wall of reconfirmed content. Reuse this pattern for any future TRD revision.

### After Session 3 (UI-first build kickoff)
- **Figma frames can contain unmodified template cruft, not just client intent — check anything that looks like boilerplate (payment forms, generic pricing tiers) against locked decisions and platform rules before building it as-is.** The paywall frames showed $199/$999/$1999 pricing with a UPI/PhonePe/Paytm payment form — inconsistent with the already-locked $2.99/$19.99 RevenueCat decision, and a custom payment form would fail Apple review outright (Guideline 3.1.1). This wasn't a client contradiction to resolve via "Figma wins" — it was template leftovers a design tool/AI likely generated, never customized. When something in Figma conflicts with a *locked* decision (not just an earlier verbal answer) or a hard platform rule, flag it and default to the locked spec/platform rule rather than blindly trusting the design file.
- **This developer's setup is Windows-only; iOS development requires a Mac for anything beyond writing text files.** Confirmed Sujal has Mac/cloud-Mac access, but code written in this environment is always compiled/run blind — no local verification possible here. Expect the first real Xcode open on his end to surface issues (typos, API misuse, XcodeGen quirks) that couldn't be caught ahead of time. Don't overstate confidence that unverified Swift code "works" — say clearly that it's unverified until he reports back from Xcode.
- **XcodeGen (`project.yml` → generated `.xcodeproj`) is the right call for authoring an iOS project outside Xcode** — a hand-written `.xcodeproj` (binary/plist format) is not reliably authorable by hand. This pattern should carry forward for the rest of iOS scaffolding (adding the keyboard extension target, Swift Package for MochiShared, etc.).
- **Sujal's "start from UI, move to backend" choice reverses the TRD session's original recommended order (security rules first).** Worth remembering this was his explicit call against the earlier recommendation, not a forgotten plan — don't push back toward the original order without him raising it.

### After Session 4 (Home screen Figma parity)
- **Pixel-parity passes are their own discrete sessions** — this was a focused single-component pass (action cards) rather than a feature build. Expect more sessions like this as Figma measurements get verified screen by screen.
- **Material defaults rarely match Figma custom designs** — the pill button replacement was needed because Material's default button overflowed the action card. Treat Material components as a starting point, not a final pixel match.
- **Commit message format with `session:` marker** (`6cf4b0f session: home-screen-figma-parity [standalone-ef2fd53b]`) is a useful convention for identifying session boundaries in git log — can be used to reconstruct what happened when sessions aren't logged.

### After Session 5 (Memory system + product finalization)
- **Explaining features in plain terms unlocks decisions.** The Effects tab was listed as an open decision for sessions, but the client couldn't decide because the term was unclear. Once explained (sparkles, hearts, ripples), the decision was instant. For any technical-sounding feature, offer a plain-language explanation before asking for a decision.
- **Memory file accuracy degrades between sessions** — the constraints file had the wrong animation framework (SpriteKit from v1 TRD, not Core Animation from v2 TRD). Running a memory sync pass to check for contradictions between files is worth doing at the start of each session, not just at the end.
- **Context-limit breaks lose momentum** — when a session runs out of context, the resumed session needs to recap decisions before moving forward. A handoff note or session summary committed to memory before context runs out would eliminate the recap overhead.

### After Session 6 (Device testing + extended Home screen Figma-parity loop) — an honest limitation, not a success story
- **Getting one screen to genuinely pixel-perfect Figma parity took far more iteration than expected, and still wasn't fully achieved by the end of this session** — roughly 9 distinct rounds of fixes in this session alone, on top of earlier rounds from Session 4, and the final fix pushed was never confirmed by Sujal before the session closed. Don't assume any given "I fixed it" round is the last one; don't tell the user a screen "matches Figma" unless he's actually confirmed it against a fresh screenshot. This directly corrects an overconfident claim recorded after Session 4 ("Home screen action-card component matches Figma at pixel level") that turned out to be premature.
- **Eyeballing a screenshot against Figma converges much more slowly than precise pixel measurement.** Early rounds this session tried to match spacing/sizing by visual comparison alone and repeatedly got corrected ("still not exact"). Once the approach switched to cropping a clean, isolated region of the Figma PNG and measuring exact pixel bounds with Python/PIL (aspect ratios, icon-to-card-width ratios, algebraic solving for exact "peek" percentages on scrollable rows), fixes started landing correctly on the first or second try instead of the fourth or fifth. **Default to pixel measurement over eyeballing for any further Figma-matching work**, on any screen, not just Home.
- **Android's Material components (`TextButton`, `Button`) carry hidden minimum-size behavior that silently overrides explicit `Modifier.height()`/size overrides.** This caused two separate real bugs this session that looked like "the AI isn't listening to feedback" from the user's side, when actually the code intent was correct but Material was overriding it invisibly at render time. When a Compose screen needs to go smaller/slimmer than Material's defaults allow, build a plain `Box`-based component instead of trying to shrink a Material `Button`/`TextButton` — don't keep fighting the same internal constraint with different override attempts.
- **A single shared-component bug can silently affect every screen at once.** The `SectionHeader` "see all" link's oversized Material touch-target was padding out section headers on every screen using that component, not just the one screen being actively worked on — found only because Home's specific complaint ("gap is too big") prompted a deep-enough investigation to trace it to a shared component. When a spacing complaint doesn't resolve after a plausible-looking fix, consider that the root cause might be one layer up, in a shared component, not the screen-specific code being edited.
- **The user's pixel-perfect standard doesn't relax as rounds accumulate.** Each new round judged the current build against Figma directly, not against how close the previous round got — earlier progress doesn't buy leniency on the next comparison. Treat every "still not matching" message as a fresh, full comparison, not evidence that prior fixes were wasted or that the bar is being raised unfairly.
- **A physical Android phone (once USB debugging is set up) is faster and more reliable than setting up an emulator from scratch** — the emulator system-image download alone took many minutes and was ultimately abandoned in favor of the phone. If Sujal has a phone on hand in a future session, prefer that path first and treat the emulator as a fallback-only option (SDK components are already installed from this session, just missing an AVD).

### After Session 7 (Home screen Figma parity, round 3 — still unresolved)
- **A Figma export can contain canvas/bezel outside the actual screen, and it silently breaks absolute px→dp scale calculations without breaking ratio-based ones.** `docs/figma/13.png` has a full-height black frame on its right edge that isn't part of the screen; `docs/figma/1.png` is the clean equivalent. Any measurement that divides one pixel distance by another *within the same file* (aspect ratios, "icon is X% of card width") stayed valid across both files; anything that assumed a specific px-per-dp scale for the whole image was at risk. **Default to `docs/figma/1.png`, not `13.png`, for this project** — confirmed by Sujal directly.
- **A cap-height-to-font-size conversion constant guessed from typography convention (used 0.72) is not reliable enough to derive a shippable sp value from a Figma pixel crop.** It produced a title size (10sp) that looked defensible on paper but was empirically ~15-20% too small once actually rendered and compared. **The fix: never ship a size derived purely from Figma-crop math. Render it, screenshot it (or ask for a screenshot), then do a dp-scale-matched crop-and-resize comparison against the Figma source** (crop each image to the same dp range using that image's own px-per-dp ratio, resize both to a common width — this makes two wildly-different-resolution sources directly pixel-comparable). This should be standard practice going forward for every sizing change on this project, not just when something's flagged wrong.
- **Pixel-threshold text detection (checking for "dark" pixels) silently fails on lighter-colored text.** The action-card subtitle uses a lighter gray (`textSecondary`) than the title/button's near-black text, and a dark-pixel threshold that worked fine for the title undercounted the subtitle's height badly, producing an unusable measurement. When measuring text that isn't the darkest color on the page, either loosen the threshold substantially or fall back to direct visual inspection rather than trusting the bounding-box number.
- **When asked to find "the screenshot you just saved" without a path, check `~/Pictures/Screenshots` by recency — but verify each hit is actually relevant before using it.** One of two recent screenshots found this way was an unrelated personal document (an internship application form with employer/personal details). It was correctly set aside without commenting on its contents — worth remembering that a recency-based file search can surface unrelated, potentially sensitive material, and that should be silently skipped, not narrated.
- **The honest bottom line, stated plainly because Sujal asked for it directly: as of this session, the Home screen action cards + toggle are *still* not confirmed to match Figma, despite this being roughly the third distinct session-level pass (Session 4, Session 6's ~9 rounds, Session 7's 3 more commits) and well over a dozen total iteration rounds on one screen's one component.** A real, specific gap (button text rendering smaller than Figma) was identified but not fixed before this session's memory update was requested — don't let a future session assume "measured and shipped" means "correct." Also: no rigor has yet been applied this pass to the header, Recently Applied row, Popular Themes row, or Font Collection row — the user's "even small details should be same" standard applies to the whole screen, and only one region of it has had real scrutiny.
- **Consider proposing a different information source before another round of PNG reverse-engineering.** Every round so far has measured a flattened raster export with Python/PIL, which has inherent error (anti-aliasing, guessed font metrics, resolution limits on the build-side screenshot). If Sujal has access to Figma's own inspector (exact dp/px values, exact font sizes, exact spacing tokens) rather than just PNG exports, getting those numbers directly would likely close this out far faster than continuing to reverse-engineer them — worth asking next session rather than defaulting straight back into another measurement round.

### After Session 8 (Home screen, round 4 — real device build loop unlocked)
- **This machine can actually build and run the Android app** (`%LOCALAPPDATA%\Android\Sdk` platform-tools + `gradlew installDebug` both work) — this was not obvious/assumed going in, given the whole project's iOS side is permanently blind-coded on this Windows machine. Default to the real build→install→`adb`-screenshot→measure loop for any future Android UI work instead of waiting on Sujal's screenshots; it's strictly more reliable and was the difference between guessing and actually landing several fixes correctly this session (e.g. the Mochi wordmark size).
- **Safety-critical: never send a blind `adb input tap` at a fixed coordinate assuming you know the current nav/app state.** Mid-session, a coordinate tap intended for an onboarding "Next" button instead landed on the phone's home screen and opened WhatsApp (app process state after `installDebug` was inconsistent all session — sometimes resumed mid-navigation, sometimes cold-started, with no reliable way to predict which). Sujal took the blame for this himself, which he didn't need to — the tap sequence was mine. **Always confirm the foreground app first** with `adb shell dumpsys window | Select-String mCurrentFocus` (and check `dumpsys power` for screen wakefulness) before any screenshot or tap, especially right after a reinstall or reconnect. Adopted as standing discipline for the rest of this session; carry it into every future session that touches this phone.
- **When a client/dev-provided asset doesn't visually match the actual Figma pixels (different style or different shape), the reliable fix is to extract the real asset directly from the `docs/figma/*.png` files already in the repo — not to use the mismatched asset, and not to ask for yet another one.** This worked three separate times this session: Popular Themes card art (wrong 2.3:1 crop), the Create FAB (Sujal's asset was a glossy 3D render, Figma is flat), and the Keyboard tab badge (Sujal's asset was a 6×2 wide key-grid, Figma's is a near-square 4×3 grid). Once framed as an explicit choice via AskUserQuestion, Sujal picked "extract from Figma yourself" over "use my asset as-is" — treat this as the default recommendation going forward, not just an option to offer neutrally.
- **Ratio-based sizing (element A's size ÷ a known-fixed element B's size, measured identically in both the Figma export and a real device screenshot) is meaningfully more reliable than absolute px→dp conversion or an assumed cap-height/em constant.** Used this to size the Mochi wordmark (via the Create Custom icon's fixed 48dp as the anchor) and the Create FAB (via screen width as the anchor), landing within ~1.6% of Figma's actual proportions both times, each confirmed by pulling a real screenshot after building rather than assuming the math was right. This directly fixes the exact failure mode that cost so many rounds in Sessions 6–7 (a cap-height→sp constant that was quietly ~15–20% wrong). **Prefer this technique for any future sizing dispute on this project.**
- **Pixel-threshold color detection still fails/gets noisy on soft, light, or low-contrast art** (confirms Session 7's finding, now also seen on the palette icon's pastel body and on Figma-export "frame edge" artifacts near canvas boundaries causing false edges in row/column brightness scans). When a mask gives an implausible bounding box (e.g. touching the edge of the search window, or wildly larger than expected), don't trust it — narrow the search region, cross-check with a second method (row-mean brightness scan vs. 2D color mask), or fall back to visual crop inspection.
- **The phone's `adb` connection was flaky all session** — it dropped to "no devices" repeatedly and needed Sujal to physically reconnect it multiple times. Expect this on future sessions with this same device; don't assume a connection drop is a one-off fluke, and re-check `adb devices` before any build/install command rather than assuming the last-known state still holds.
- **Sujal changed the working process mid-session, and it's now the standing rule**: originally this session opened with him handing over a 12-item list to work through, but partway in he explicitly stopped that and required one change at a time, sent by him individually, with his own verification before the next one — correcting an assumption that a delegated list meant autonomy to work through it. Don't revert to batch-processing a list of UI fixes on this project again without him explicitly re-authorizing it.
- **Only commit/push when explicitly asked, even after many rounds of real, verified changes** — this session did one commit early on (`e6dbac2`) and then made roughly a dozen more real changes without another commit, because Sujal never asked for one. This left a large amount of uncommitted work sitting in the tree at session end. Don't let "lots of good work has piled up" become a reason to commit unprompted — but do proactively mention the pile-up to Sujal, since he can't see it unless told.

---

<!-- Template for future sessions:

### After Session N
[What worked, what didn't, what to do differently next time]
[Any new patterns observed about client or project]

-->
