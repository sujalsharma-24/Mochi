import re, sys, json
sys.path.insert(0, "/Users/Tanmay/Desktop/Projects/Mochi/scratchpad")
from theme_color import hex_to_rgb, composited, rel_luminance, contrast_ratio, with_alpha

SRC = "/Users/Tanmay/Desktop/Projects/Mochi/ios/MochiShared/Themes/BuiltInThemes+Batch2.swift"
text = open(SRC).read()
ORIG = text

# ---------------------------------------------------------------- archetypes

ARCHETYPES = {
    "magentaMidnightGlow":  "tintedGlassDeep",
    "midnightOceanVoyage":  "tintedGlassDeep",
    "moonlitMagic":         "tintedGlassDeep",
    "enchantedWitchyNight": "tintedGlassDeep",
    "lavenderParisNight":   "tintedGlassDeep",
    "royalSunsetAtelier":   "tintedGlassDeep",
    "lavenderMoonGarden":   "tintedGlassDeep",

    "auroraWinterWonderland": "frostedGlassLight",
    "starlitDreamCafe":       "frostedGlassLight",
    "moonlitBeachEscape":     "frostedGlassLight",

    "kawaiiStrawberryDream": "softMatteCozy",
    "cozyCountrysideFarm":   "softMatteCozy",
    "autumnCozyCottage":     "softMatteCozy",
    "cozyCottagecoreStudio": "softMatteCozy",
    "midnightCafe":          "softMatteCozy",
    "enchantedGardenCafe":   "softMatteCozy",

    "zenGarden":            "crispOutlineNature",
    "matchaGarden":         "crispOutlineNature",
    "mysticGreenHaven":     "crispOutlineNature",
    "vintageWriterEvening": "crispOutlineNature",

    "mermaidDreamscape": "chunkyPopPlayful",
}
assert len(ARCHETYPES) == 21, len(ARCHETYPES)

# role-indexed corner radius: (input/system, action, space)
RECIPES = {
    "tintedGlassDeep": dict(
        corner=(13.0, 13.0, 15.0), borderAlpha=0.55, borderWidth=1.1,
        shadowOpacity=0.28, shadowRadius=2.2, shadowOffsetY=1.3,
        topHighlightAlpha=0.42, glass=dict(bevelAlpha=0.85, bevelWidth=1.2, falloff=0.42, innerOpacity=0.28, innerRadius=3.2),
        # input / system / action — system and action given more opacity than input: system carries
        # thin SF Symbol glyphs (shift/delete/123/globe/emoji) whose strokes are the least tolerant
        # of the real art's per-pixel worst case (measured against ArtBackdropCheck, not guessed).
        fillAlpha=(0.74, 0.82, 0.82), spaceAlphaDelta=-0.15, spaceAlphaFloor=0.40,
        keyArt=dict(height=0.46, opacity=0.85, lift=0.09),
    ),
    "frostedGlassLight": dict(
        corner=(12.0, 12.0, 14.0), borderAlpha=0.48, borderWidth=1.0,
        shadowOpacity=0.16, shadowRadius=1.8, shadowOffsetY=1.0,
        topHighlightAlpha=0.50, glass=dict(bevelAlpha=0.75, bevelWidth=1.0, falloff=0.35, innerOpacity=0.18, innerRadius=2.5),
        fillAlpha=(0.84, 0.89, 0.89), spaceAlphaDelta=-0.08, spaceAlphaFloor=0.45,
        keyArt=dict(height=0.50, opacity=0.88, lift=0.08),
    ),
    "softMatteCozy": dict(
        corner=(8.0, 8.0, 10.0), borderAlpha=0.35, borderWidth=1.3,
        shadowOpacity=0.22, shadowRadius=3.0, shadowOffsetY=2.0,
        topHighlightAlpha=0.16, glass=None,
        fillAlpha=None, spaceAlphaDelta=None, spaceAlphaFloor=None,
        keyArt=dict(height=0.56, opacity=0.95, lift=0.06),
    ),
    "crispOutlineNature": dict(
        corner=(6.0, 6.0, 8.0), borderAlpha=0.75, borderWidth=1.5,
        shadowOpacity=0.0, shadowRadius=0.0, shadowOffsetY=0.0,
        topHighlightAlpha=None, glass=None,
        fillAlpha=None, spaceAlphaDelta=None, spaceAlphaFloor=None,
        keyArt=dict(height=0.40, opacity=0.78, lift=0.10),
    ),
    "chunkyPopPlayful": dict(
        corner=(18.0, 18.0, 20.0), borderAlpha=0.50, borderWidth=1.6,
        shadowOpacity=0.32, shadowRadius=3.5, shadowOffsetY=2.5,
        topHighlightAlpha=0.55, glass=None,
        fillAlpha=None, spaceAlphaDelta=None, spaceAlphaFloor=None,
        keyArt=dict(height=0.58, opacity=1.0, lift=0.05),
    ),
}

# scrim recipe: (topAlpha, bottomAlpha) by whether the archetype's caps are opaque or translucent
def new_scrim_alphas(archetype):
    if RECIPES[archetype]["fillAlpha"] is not None:   # translucent-cap (glass) archetypes
        return (0.44, 0.30)
    return (0.20, 0.06)                                # opaque-cap archetypes

LABEL_LIGHT = "#FBF8FF"
LABEL_DARK = "#241B2E"

# ---------------------------------------------------------------- parsing helpers

def match_paren(s, open_idx):
    depth = 0
    i = open_idx
    while i < len(s):
        if s[i] == '(':
            depth += 1
        elif s[i] == ')':
            depth -= 1
            if depth == 0:
                return i
        i += 1
    raise ValueError("unbalanced")

def match_bracket(s, open_idx):
    depth = 0
    i = open_idx
    while i < len(s):
        if s[i] == '[':
            depth += 1
        elif s[i] == ']':
            depth -= 1
            if depth == 0:
                return i
        i += 1
    raise ValueError("unbalanced bracket")

def theme_span(text, name):
    m = re.search(r'static let %s = MochiKeyboardTheme\(' % name, text)
    open_idx = text.index('(', m.start())
    end_idx = match_paren(text, open_idx)
    return m.start(), end_idx + 1

def role_spans(text, t_start, t_end):
    """Returns dict role -> (kstyle_open_paren_idx, kstyle_close_paren_idx) within [t_start,t_end)."""
    block = text[t_start:t_end]
    spans = {}
    for role_marker, role in [(".input:", "input"), (".system:", "system"), (".action:", "action"), (".space:", "space")]:
        rm = re.search(re.escape(role_marker) + r'\s*KeyStyle\(', block)
        if not rm:
            continue
        open_idx = t_start + block.index('(', rm.end() - 1)
        close_idx = match_paren(text, open_idx)
        spans[role] = (open_idx, close_idx)
    return spans

# ---------------------------------------------------------------- field editors (operate on a role's substring, return new substring)

def set_corner_radius(role_text, value):
    return re.sub(r'cornerRadiusOverride:\s*[\d.]+', 'cornerRadiusOverride: %.1f' % value, role_text)

def set_shadow(role_text, opacity, radius, offsetY):
    pat = re.compile(r'shadow:\s*ThemeShadow\(color:\s*ThemeColor\(hex:\s*"([^"]+)"\)!,\s*opacity:\s*[\d.]+,\s*radius:\s*[\d.]+,\s*offsetY:\s*[\d.]+\)')
    def repl(m):
        color = m.group(1)
        return 'shadow: ThemeShadow(color: ThemeColor(hex: "%s")!, opacity: %.2f, radius: %.2f, offsetY: %.2f)' % (color, opacity, radius, offsetY)
    return pat.sub(repl, role_text)

def set_top_highlight(role_text, alpha):
    pat = re.compile(r'topHighlight:\s*ThemeColor\(hex:\s*"([^"]+)"\)!\.withAlpha\([\d.]+\)')
    if alpha is None:
        return pat.sub('topHighlight: nil', role_text)
    def repl(m):
        return 'topHighlight: ThemeColor(hex: "%s")!.withAlpha(%.2f)' % (m.group(1), alpha)
    return pat.sub(repl, role_text)

def set_border(role_text, alpha, width):
    pat = re.compile(r'border:\s*ThemeBorder\(color:\s*ThemeColor\(hex:\s*"([^"]+)"\)!\.withAlpha\([\d.]+\),\s*width:\s*[\d.]+\)')
    def repl(m):
        return 'border: ThemeBorder(color: ThemeColor(hex: "%s")!.withAlpha(%.2f), width: %.2f)' % (m.group(1), alpha, width)
    return pat.sub(repl, role_text)

def remove_glass(role_text):
    """Delete a trailing `,\n<ws>glass: KeyGlass(...)` argument, if present."""
    m = re.search(r'glass:\s*KeyGlass\(', role_text)
    if not m:
        return role_text
    open_idx = role_text.index('(', m.start())
    close_idx = match_paren(role_text, open_idx)
    # also eat the preceding comma+whitespace
    pre = role_text[:m.start()]
    pre = re.sub(r',\s*$', '', pre)
    return pre + role_text[close_idx+1:]

def set_glass(role_text, bevelAlpha, bevelWidth, falloff, innerOpacity, innerRadius):
    pat = re.compile(
        r'glass:\s*KeyGlass\(\s*bevelColor:\s*ThemeColor\(hex:\s*"([^"]+)"\)!\.withAlpha\([\d.]+\),\s*'
        r'bevelWidth:\s*[\d.]+,\s*bevelFalloff:\s*[\d.]+,\s*'
        r'innerShadowColor:\s*ThemeColor\(hex:\s*"([^"]+)"\)!,\s*'
        r'innerShadowOpacity:\s*[\d.]+,\s*innerShadowRadius:\s*[\d.]+\s*\)',
        re.S
    )
    def repl(m):
        bevel, inner = m.group(1), m.group(2)
        return ('glass: KeyGlass(\n'
                '                    bevelColor: ThemeColor(hex: "%s")!.withAlpha(%.2f),\n'
                '                    bevelWidth: %.2f,\n'
                '                    bevelFalloff: %.2f,\n'
                '                    innerShadowColor: ThemeColor(hex: "%s")!,\n'
                '                    innerShadowOpacity: %.2f,\n'
                '                    innerShadowRadius: %.2f\n'
                '                )') % (bevel, bevelAlpha, bevelWidth, falloff, inner, innerOpacity, innerRadius)
    new_text, n = pat.subn(repl, role_text)
    if n == 0:
        raise ValueError("glass pattern not found")
    return new_text

def set_fill_alpha_absolute(role_text, field, alpha):
    """Within `field: ThemeFill(stops: [...])` ONLY, set every ThemeColor's alpha to `alpha`,
    whether or not it already carries a `.withAlpha(...)`. Scoped to the bracket span so a sibling
    field (labelColor, pressedLabelColor) is never touched — that was the space-bar bug."""
    fm = re.search(re.escape(field) + r':\s*ThemeFill\(stops:\s*\[', role_text)
    if not fm:
        return role_text
    open_idx = role_text.index('[', fm.start())
    close_idx = match_bracket(role_text, open_idx)
    inner = role_text[open_idx+1:close_idx]
    inner = re.sub(r'(ThemeColor\(hex:\s*"[^"]+"\)!)(?:\.withAlpha\([\d.]+\))?',
                    lambda m: m.group(1) + '.withAlpha(%.2f)' % alpha, inner)
    return role_text[:open_idx+1] + inner + role_text[close_idx:]

def apply_fill_alpha(role_text, field, alpha):
    """Within `field: ThemeFill(stops: [...])`, append .withAlpha(alpha) to every bare
    `ThemeColor(hex: "...")!` that doesn't already carry one."""
    fm = re.search(re.escape(field) + r':\s*ThemeFill\(stops:\s*\[', role_text)
    if not fm:
        return role_text
    open_idx = role_text.index('[', fm.start())
    close_idx = match_bracket(role_text, open_idx)
    inner = role_text[open_idx+1:close_idx]
    def repl(m):
        return m.group(0) if m.group(0).endswith(')') is False else m.group(0)
    # replace each ThemeColor(hex: "...")! not already followed by .withAlpha
    def sub_color(m):
        full_start = m.end()
        already = role_text2 = inner[full_start:full_start+11]
        return m.group(0)
    parts = []
    idx = 0
    for cm in re.finditer(r'ThemeColor\(hex:\s*"[^"]+"\)!', inner):
        parts.append(inner[idx:cm.end()])
        tail = inner[cm.end():cm.end()+11]
        if tail.startswith('.withAlpha'):
            idx = cm.end()
            continue
        parts.append('.withAlpha(%.2f)' % alpha)
        idx = cm.end()
    parts.append(inner[idx:])
    new_inner = ''.join(parts)
    return role_text[:open_idx+1] + new_inner + role_text[close_idx:]

def get_fill_stop_hexes(role_text, field):
    fm = re.search(re.escape(field) + r':\s*ThemeFill\(stops:\s*\[', role_text)
    if not fm:
        return []
    open_idx = role_text.index('[', fm.start())
    close_idx = match_bracket(role_text, open_idx)
    inner = role_text[open_idx+1:close_idx]
    return re.findall(r'#[0-9A-Fa-f]{6,8}', inner)

def get_label_hex(role_text, field="labelColor"):
    m = re.search(re.escape(field) + r':\s*ThemeColor\(hex:\s*"([^"]+)"\)!(?:\.withAlpha\(([\d.]+)\))?', role_text)
    if not m:
        return None, None
    return m.group(1), (float(m.group(2)) if m.group(2) else 1.0)

def set_label_hex(role_text, field, new_hex):
    pat = re.compile(re.escape(field) + r':\s*ThemeColor\(hex:\s*"[^"]+"\)!((?:\.withAlpha\([\d.]+\))?)')
    def repl(m):
        return '%s: ThemeColor(hex: "%s")!%s' % (field, new_hex, m.group(1))
    return pat.sub(repl, role_text, count=1)

def set_scrim(text, t_start, t_end, top_hex, top_alpha, bottom_hex, bottom_alpha):
    block = text[t_start:t_end]
    pat = re.compile(
        r'scrim:\s*ThemeScrim\(\s*topColor:\s*ThemeColor\(hex:\s*"[^"]+"\)!\.withAlpha\([\d.]+\),\s*'
        r'bottomColor:\s*ThemeColor\(hex:\s*"[^"]+"\)!\.withAlpha\([\d.]+\)\s*\)',
        re.S
    )
    def repl(m):
        return ('scrim: ThemeScrim(\n'
                '                topColor: ThemeColor(hex: "%s")!.withAlpha(%.2f),\n'
                '                bottomColor: ThemeColor(hex: "%s")!.withAlpha(%.2f)\n'
                '            )') % (top_hex, top_alpha, bottom_hex, bottom_alpha)
    new_block, n = pat.subn(repl, block)
    if n != 1:
        raise ValueError("scrim not found/ambiguous for span")
    return text[:t_start] + new_block + text[t_end:]

def set_keyart(text, t_start, t_end, height, opacity, lift):
    block = text[t_start:t_end]
    pat = re.compile(r'heightFraction:\s*[\d.]+,(\s*)bottomInsetFraction:\s*[\d.]+,(\s*)opacity:\s*[\d.]+,')
    def repl(m):
        return 'heightFraction: %.2f,%sbottomInsetFraction: 0.0,%sopacity: %.2f,' % (height, m.group(1), m.group(2), opacity)
    block2, n1 = pat.subn(repl, block)
    pat2 = re.compile(r'labelLiftFraction:\s*[\d.]+')
    block3, n2 = pat2.subn('labelLiftFraction: %.2f' % lift, block2)
    if n1 != 1 or n2 != 1:
        raise ValueError("keyArt fields not found (%d,%d)" % (n1, n2))
    return text[:t_start] + block3 + text[t_end:]

# ---------------------------------------------------------------- driver

report = []

for theme_name, archetype in ARCHETYPES.items():
    recipe = RECIPES[archetype]
    t_start, t_end = theme_span(text, theme_name)

    # --- scrim: recompute against this theme's OWN scrim hues (already sampled from its art),
    # only changing alpha per archetype.
    scrim_m = re.search(
        r'scrim:\s*ThemeScrim\(\s*topColor:\s*ThemeColor\(hex:\s*"([^"]+)"\)!\.withAlpha\([\d.]+\),\s*'
        r'bottomColor:\s*ThemeColor\(hex:\s*"([^"]+)"\)!\.withAlpha\([\d.]+\)',
        text[t_start:t_end], re.S)
    top_hex, bottom_hex = scrim_m.group(1), scrim_m.group(2)
    top_alpha, bottom_alpha = new_scrim_alphas(archetype)
    text = set_scrim(text, t_start, t_end, top_hex, top_alpha, bottom_hex, bottom_alpha)
    t_start, t_end = theme_span(text, theme_name)  # re-anchor (length may have changed)

    # baseFill representative (min-luminance stop, mirrors ThemeFill.contrastRepresentative)
    bf_m = re.search(r'baseFill:\s*ThemeFill\(stops:\s*\[(.*?)\]\s*\)', text[t_start:t_end], re.S)
    basefill_hexes = re.findall(r'#[0-9A-Fa-f]{6,8}', bf_m.group(1))
    basefill_rgbs = [hex_to_rgb(h) for h in basefill_hexes]
    basefill_repr = min(basefill_rgbs, key=rel_luminance) if len(basefill_rgbs) > 1 else basefill_rgbs[0]
    backdrop = composited(with_alpha(hex_to_rgb(bottom_hex), bottom_alpha), basefill_repr)  # weakest = lower alpha end; here bottom<top always after our recipe

    spans = role_spans(text, t_start, t_end)
    for role in ["input", "system", "action", "space"]:
        if role not in spans:
            continue
        o, c = spans[role]
        role_text = text[o:c+1]

        idx = 0 if role in ("input", "system") else (1 if role == "action" else None)
        corner = recipe["corner"][0 if role in ("input", "system") else (1 if role == "action" else 2)]
        role_text = set_corner_radius(role_text, corner)
        role_text = set_shadow(role_text, recipe["shadowOpacity"], recipe["shadowRadius"], recipe["shadowOffsetY"])
        role_text = set_top_highlight(role_text, recipe["topHighlightAlpha"])
        role_text = set_border(role_text, recipe["borderAlpha"], recipe["borderWidth"])

        if recipe["glass"] is None:
            role_text = remove_glass(role_text)
        elif role != "space":  # space never had glass in batch2; leave as-is if absent
            if "glass:" in role_text:
                role_text = set_glass(role_text, recipe["glass"]["bevelAlpha"], recipe["glass"]["bevelWidth"],
                                       recipe["glass"]["falloff"], recipe["glass"]["innerOpacity"], recipe["glass"]["innerRadius"])

        # translucency + label re-check, glass archetypes only
        if recipe["fillAlpha"] is not None:
            if role in ("input", "system", "action"):
                alpha = recipe["fillAlpha"][("input", "system", "action").index(role)]
                role_text = set_fill_alpha_absolute(role_text, "fill", alpha)
                role_text = set_fill_alpha_absolute(role_text, "pressedFill", min(1.0, alpha + 0.10))

                fill_hexes = get_fill_stop_hexes(role_text, "fill")
                fill_rgbs = [hex_to_rgb(h) for h in fill_hexes]
                cap_repr = min(fill_rgbs, key=rel_luminance)  # ThemeFill.contrastRepresentative = darkest stop
                cap_on_backdrop = composited(with_alpha(cap_repr, alpha), backdrop)

                label_hex, label_alpha = get_label_hex(role_text, "labelColor")
                if label_hex and label_alpha and label_alpha > 0:
                    label_rgb = hex_to_rgb(label_hex)
                    ratio = contrast_ratio(label_rgb, cap_on_backdrop)
                    if ratio < 4.6:
                        # pick whichever fixed candidate wins
                        light_ratio = contrast_ratio(hex_to_rgb(LABEL_LIGHT), cap_on_backdrop)
                        dark_ratio = contrast_ratio(hex_to_rgb(LABEL_DARK), cap_on_backdrop)
                        best_hex = LABEL_LIGHT if light_ratio >= dark_ratio else LABEL_DARK
                        best_ratio = max(light_ratio, dark_ratio)
                        role_text = set_label_hex(role_text, "labelColor", best_hex)
                        role_text = set_label_hex(role_text, "pressedLabelColor", best_hex)
                        report.append("%s.%s: label flipped %s->%s (was %.2f:1, now %.2f:1)" % (theme_name, role, label_hex, best_hex, ratio, best_ratio))
                    else:
                        report.append("%s.%s: label kept %s (%.2f:1 on translucent cap)" % (theme_name, role, label_hex, ratio))
            else:  # space: deepen existing translucency a bit. labelColor is untouched (alpha 0,
                # hidden, by construction on every batch2 space bar) — scoping to the `fill:` bracket
                # only is what keeps that true; a blanket regex here previously un-hid the label.
                fh = get_fill_stop_hexes(role_text, "fill")
                fm = re.search(r'fill:\s*ThemeFill\(stops:\s*\[', role_text)
                open_idx = role_text.index('[', fm.start())
                close_idx = match_bracket(role_text, open_idx)
                am = re.search(r'\.withAlpha\(([\d.]+)\)', role_text[open_idx:close_idx])
                cur_alpha = float(am.group(1)) if am else 0.6
                new_alpha = max(recipe["spaceAlphaFloor"], cur_alpha + recipe["spaceAlphaDelta"])
                role_text = set_fill_alpha_absolute(role_text, "fill", new_alpha)

        text = text[:o] + role_text + text[c+1:]
        # re-anchor spans since role_text length may differ
        t_start, t_end = theme_span(text, theme_name)
        spans = role_spans(text, t_start, t_end)

    # keyArt tweak
    ka = recipe["keyArt"]
    text = set_keyart(text, t_start, t_end, ka["height"], ka["opacity"], ka["lift"])

open("/Users/Tanmay/Desktop/Projects/Mochi/scratchpad/report.txt", "w").write("\n".join(report))
open(SRC, "w").write(text)
print("done. %d report lines. new length=%d (was %d)" % (len(report), len(text), len(ORIG)))
