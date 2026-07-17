---
name: user-sujal
description: "Profile of Sujal Sharma — freelance developer, first client, working style and preferences"
metadata: 
  node_type: memory
  type: user
  originSessionId: f7b11015-d7e5-40a3-9089-fe2f54d48fee
---

# User Profile — Sujal Sharma

**Role:** Freelance software developer
**Experience level:** Developer with technical skills; first freelance client engagement
**Email:** sujalsharma24624@gmail.com
**Platform:** Windows 11, VSCode with Claude Code extension

---

## Current Work

Building "Mochi" — a keyboard theme replacement app for Android + iOS — for an Australian client at $425 fixed price. Goal is to impress first client and secure repeat work.

See [[project-mochi-overview]] for full project context.

---

## Working Style

- **Wants to finalize before building** — prefers locking all requirements before any technical decisions
- **Informal and fast-moving** — short messages, expects direct answers
- **Delegates hard calls** — when overwhelmed, says "you decide" and means it; give confident specific answers
- **Defers gracefully** — comfortable saying "let's discuss later" for non-blocking items; respect this
- **Interactive over documents** — prefers back-and-forth conversation over being handed a long spec to read
- **Updates via WhatsApp** — that's how he communicates with the client

---

## What to Avoid

- Overwhelming with options when he delegates a decision — just make the call
- Large question dumps — he gets overwhelmed; 10-15 focused questions is the sweet spot
- Premature technical decisions — he explicitly wants to separate requirements from architecture
- Verbose summaries at the end of responses — get to the point, show the key info

## Communication & Review Style (UI implementation phase)

- **Switches to Hinglish** during hands-on UI review sessions (mixing Hindi and English mid-conversation) and expects replies to match that tone once he does — don't stay in pure English after he's switched.
- **Reviews via screenshot, iteratively, one round at a time** — sends a screenshot of the current build alongside (or referencing) the Figma reference, expects a direct comparison and fix, then sends a fresh screenshot of the result. Each round is judged against Figma directly, not against how close the previous round got — don't treat earlier progress as having earned leniency on the current comparison.
- **Genuinely means pixel-perfect**, not "close enough" — will keep sending correction rounds (icon sizes, line spacing, exact aspect ratios, gap sizes) until the build matches the Figma export almost exactly. Expect many rounds per screen; see [[project-mochi-learnings]]'s Session 6 entry for how a single screen took 9+ rounds.
- **Provides real assets when asked** — when told an icon/image is needed, he'll place the actual file in the right folder and say so, rather than asking for a placeholder to stay in.
- **Defers full device (phone) verification** until "all the screens" are built — for now, Android Studio's `@Preview` panel is his actual day-to-day review surface, even on days when the app is also confirmed working live on his phone.
- **As of Session 8, actively drives real on-device testing** — plugs/unplugs his phone on request, tolerates repeated `adb` reconnects without frustration, and lets a real build→install→screenshot loop run rather than only reviewing static screenshots.

## Session 8 Process Update — explicit, non-negotiable rules he now enforces

At the start of Session 8 he set hard rules for how this project should be worked, unprompted by anything going wrong yet: every change must be a real, verifiable code diff (never describe work that wasn't actually done — he once lost 5 hours to that and it nearly cost him the client), no sugarcoating when something's broken, accuracy over speed, show-don't-tell, and stop-and-ask when blocked on a missing asset or ambiguous instruction. Partway through the same session he added a further constraint: **one change at a time, sent by him individually, verified by him before the next one** — this directly overrode an earlier assumption (also from him, earlier in the same session) that handing over a full list meant delegated autonomy to work through it independently. Don't assume a delegated list is an invitation to batch-process it; wait for it to be walked through one item at a time unless he says otherwise.

- **Provides real assets, but they don't always match Figma** — he's reliably willing to place PNG files at exact paths when asked, but multiple times this session his provided asset (Create FAB icon, Keyboard tab icon) turned out to be stylistically or structurally different from what Figma actually shows (glossy 3D vs. flat, different icon proportions). He's receptive to being told this directly and, when offered the choice, prefers extracting the real asset from the Figma export over using his mismatched one — don't silently use a provided asset without checking it against Figma first.
- **Generous/non-blaming under a real mistake**: when an automated tap (mine, not his) accidentally opened WhatsApp on his phone mid-session, he took the blame himself ("my mistake I opened whatsapp") rather than pointing it out as my error. Don't take this as license to be careless — hold the same safety bar regardless of whether he'd notice or object.
- **Terse, imperative instruction style continues to intensify** — messages are now short commands ("remove the boundary of that create FAB", "keep some gap between...") with no elaboration; expected to infer intent from Figma comparison rather than ask for spec detail on every word choice, but still expected to flag genuine ambiguity per his stop-and-ask rule.
