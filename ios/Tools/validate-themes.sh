#!/bin/bash
# Compiles and runs the host-side theme legibility check.
#
# No Xcode project, simulator or signing identity involved — the theme model is Foundation-only by
# design so this can run anywhere, including CI.
set -euo pipefail

cd "$(dirname "$0")/.."
OUT="$(mktemp -d)/validate-themes"

swiftc -O \
  MochiShared/Theme/ThemeColor.swift \
  MochiShared/Theme/ThemeTokens.swift \
  MochiShared/Theme/MochiKeyboardTheme.swift \
  MochiShared/Theme/ThemeValidator.swift \
  MochiShared/Layout/KeyboardMetrics.swift \
  MochiShared/Layout/KeyboardLayout.swift \
  MochiShared/Input/AccentMap.swift \
  MochiShared/Themes/BuiltInThemes.swift \
  MochiShared/Themes/BuiltInThemes+Batch2.swift \
  MochiShared/Themes/BuiltInThemes+Batch3.swift \
  MochiShared/Themes/BuiltInThemes+Batch4.swift \
  MochiShared/Themes/BuiltInThemes+Batch5.swift \
  MochiShared/Themes/BuiltInThemes+Batch6.swift \
  MochiShared/Themes/BuiltInThemes+Batch7.swift \
  MochiShared/Themes/BuiltInThemes+Batch8.swift \
  Tools/ThemeValidationCLI/ArtBackdropCheck.swift \
  Tools/ThemeValidationCLI/main.swift \
  -o "$OUT"

"$OUT"
