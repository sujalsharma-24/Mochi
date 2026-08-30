# MochiShared

Code compiled into **both** `MochiApp` and the `MochiKeyboard` extension.

## Why source inclusion rather than a framework or SPM package

TRD §ADR lists `MochiShared` as a Swift Package. This directory is laid out package-ready
(isolated, no app-only imports) but is currently included in both targets as **plain sources**
in `project.yml`. The reason is launch cost, not taste:

A keyboard extension is launched and torn down constantly — every time the user taps a text
field in any app. A dynamically-linked framework adds a `dyld` load and rebind on every one of
those launches, and it counts against the same ~30–48 MB dirty-memory budget the renderer needs.
Compiling the sources directly into each target removes that cost entirely. The duplicated code
lives in two separate processes that are never resident together for the same purpose, so the
duplication costs binary size (tens of KB) and nothing at runtime.

Promoting this to a real package later is a `project.yml` change plus adding `public` to the
type declarations — no restructuring — which is why the folder boundary is kept clean now.

## The one rule

Nothing in here may `import UIKit`-only-in-the-app ways, reach for `UIApplication`, or assume a
window scene. The extension has no `UIApplication.shared`. If a file here needs app-only API,
it belongs in `MochiApp`, not here.

## Layout

- `Theme/` — the theme document: tokens, colour model, contrast validation, App Group storage.
- `Layout/` — device-adaptive keyboard metrics and the key layout model.
- `Render/` — the renderer shared by the in-app preview and the real keyboard, so the two
  cannot visually drift apart.
- `Themes/` — built-in theme definitions.
