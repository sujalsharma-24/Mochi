import re, sys, subprocess, colorsys
sys.path.insert(0, "/Users/Tanmay/Desktop/Projects/Mochi/scratchpad")
from theme_color import hex_to_rgb, composited, rel_luminance, contrast_ratio, with_alpha

SRC = "/Users/Tanmay/Desktop/Projects/Mochi/ios/MochiShared/Themes/BuiltInThemes+Batch2.swift"
PLATE_DIR = "/tmp/plates"

# ---------------------------------------------------------------------------- config

# id-suffix -> (plate stem, final verticalAnchor, material)
THEMES = {
    "magentaMidnightGlow":   ("magenta_midnight_glow",   0.52, "Inkwell"),
    "midnightOceanVoyage":   ("midnight_ocean_voyage",   0.62, "Inkwell"),
    "enchantedWitchyNight":  ("enchanted_witchy_night",  0.52, "Inkwell"),
    "midnightCafe":          ("midnight_cafe",           0.50, "Pane"),
    "moonlitMagic":          ("moonlit_magic",           0.55, "Pane"),
    "lavenderParisNight":    ("lavender_paris_night",    0.50, "Pane"),
    "auroraWinterWonderland":("aurora_winter_wonderland",0.50, "Pane"),
    "starlitDreamCafe":      ("starlit_dream_cafe",      0.50, "Jelly"),
    "kawaiiStrawberryDream": ("kawaii_strawberry_dream", 0.50, "Jelly"),
    "enchantedGardenCafe":   ("enchanted_garden_cafe",   0.50, "Jelly"),
    "autumnCozyCottage":     ("autumn_cozy_cottage",     0.50, "Clay"),
    "cozyCountrysideFarm":   ("cozy_countryside_farm",   0.30, "Clay"),
    "cozyCottagecoreStudio": ("cozy_cottagecore_studio", 0.54, "Clay"),
    "zenGarden":             ("zen_garden",              0.50, "Letterpress"),
    "matchaGarden":          ("matcha_garden",           0.50, "Letterpress"),
    "vintageWriterEvening":  ("vintage_writer_evening",  0.50, "Letterpress"),
    "lavenderMoonGarden":    ("lavender_moon_garden",    0.50, "Pearl"),
    "moonlitBeachEscape":    ("moonlit_beach_escape",    0.50, "Pearl"),
    "mermaidDreamscape":     ("mermaid_dreamscape",      0.30, "Pearl"),
    "royalSunsetAtelier":    ("royal_sunset_atelier",    0.42, "Keycap"),
    "mysticGreenHaven":      ("mystic_green_haven",      0.55, "Keycap"),
}
assert len(THEMES) == 21

# per-theme tweaks the generic rules get slightly wrong against the actual art
THEME_OVERRIDES = {
    "cozyCountrysideFarm": dict(cap_sat_mul=0.62, cap_hue_deg=7.0),   # raw chartreuse reads acid
    "matchaGarden":        dict(cap_sat_mul=0.78),
}

# per-material knobs. corner is (input/system, action, space).
MATERIAL = {
    "Inkwell": dict(  # dark cap under a dark plate, bright hairline rim, tight bevel glint, press LIGHTENS
        corner=(12.0, 12.0, 14.0), translucent=False,
        border_alpha=0.60, border_width=1.0, border_from="light",
        shadow=(0.32, 2.6, 1.6), shadow_from="dark",
        top_highlight_alpha=0.28,
        glass=dict(bevel_from="light", bevel_alpha=0.62, bevel_width=1.0, falloff=0.12,
                   inner_from="dark", inner_opacity=0.36, inner_radius=3.0),
        scrim=(0.20, 0.06), grad_dL=0.025, press="lighten",
        keyart=dict(h=0.44, inset=0.09, lift=0.14),
    ),
    "Pane": dict(  # translucent — the "art reads through" material
        corner=(13.0, 13.0, 15.0), translucent=True, fill_alpha=(0.73, 0.79, 0.79),
        border_alpha=0.50, border_width=1.05, border_from="light",
        shadow=(0.17, 1.9, 1.1), shadow_from="dark",
        top_highlight_alpha=0.50,
        glass=dict(bevel_from="light", bevel_alpha=0.74, bevel_width=1.1, falloff=0.40,
                   inner_from="dark", inner_opacity=0.18, inner_radius=2.6),
        scrim=(0.46, 0.34), grad_dL=0.05, press="auto",
        keyart=dict(h=0.46, inset=0.09, lift=0.14),
    ),
    "Jelly": dict(  # opaque, inflated: broad top-highlight dome + bright subsurface inner-glow, no bevel
        corner=(19.0, 19.0, 20.0), translucent=False,
        border_alpha=0.40, border_width=1.15, border_from="dark",
        shadow=(0.30, 4.2, 3.0), shadow_from="dark",
        top_highlight_alpha=0.62,
        glass=dict(bevel_from="light", bevel_alpha=0.0, bevel_width=0.0, falloff=0.5,
                   inner_from="light", inner_opacity=0.34, inner_radius=3.2),
        scrim=(0.18, 0.05), grad_dL=0.06, press="auto",
        keyart=dict(h=0.50, inset=0.10, lift=0.15),
    ),
    "Clay": dict(  # opaque matte, zero gloss, soft ambient shadow
        corner=(9.0, 9.0, 11.0), translucent=False,
        border_alpha=0.32, border_width=1.35, border_from="dark",
        shadow=(0.22, 3.6, 2.6), shadow_from="dark",
        top_highlight_alpha=None, glass=None,
        scrim=(0.18, 0.05), grad_dL=0.05, press="auto",
        keyart=dict(h=0.52, inset=0.10, lift=0.15),
    ),
    "Letterpress": dict(  # near-surface fill, bold thin stroke, no shadow, no gloss
        corner=(6.0, 6.0, 8.0), translucent=False,
        border_alpha=0.80, border_width=1.7, border_from="ink",
        shadow=(0.0, 0.0, 0.0), shadow_from="dark",
        top_highlight_alpha=None, glass=None,
        scrim=(0.16, 0.05), grad_dL=0.035, press="auto",
        keyart=dict(h=0.40, inset=0.09, lift=0.13),
    ),
    "Keycap": dict(  # opaque colour block, tight rim glint + short tight shadow
        corner=(8.0, 8.0, 10.0), translucent=False,
        border_alpha=0.55, border_width=1.0, border_from="light",
        shadow=(0.26, 1.6, 1.6), shadow_from="dark",
        top_highlight_alpha=0.34,
        glass=dict(bevel_from="light", bevel_alpha=0.70, bevel_width=1.0, falloff=0.10,
                   inner_from="dark", inner_opacity=0.16, inner_radius=2.0),
        scrim=(0.18, 0.05), grad_dL=0.05, press="auto",
        keyart=dict(h=0.46, inset=0.09, lift=0.14),
    ),
    "Pearl": dict(  # opaque, cross-hue gradient (warm top -> cool bottom), narrow bevel, gentle sheen
        corner=(14.0, 14.0, 16.0), translucent=False,
        border_alpha=0.42, border_width=0.95, border_from="light",
        shadow=(0.15, 2.2, 1.3), shadow_from="dark",
        top_highlight_alpha=0.46,
        glass=dict(bevel_from="light", bevel_alpha=0.60, bevel_width=0.8, falloff=0.18,
                   inner_from="dark", inner_opacity=0.12, inner_radius=2.0),
        scrim=(0.18, 0.05), grad_dL=0.10, press="auto", pearl=True,
        keyart=dict(h=0.48, inset=0.09, lift=0.14),
    ),
}

# ---------------------------------------------------------------------------- colour helpers

def clamp(v, a=0.0, b=1.0): return max(a, min(b, v))

def to_hex(rgb):
    return "#%02X%02X%02X" % tuple(int(round(clamp(c) * 255)) for c in rgb[:3])

def lum(rgb): return rel_luminance((rgb[0], rgb[1], rgb[2], 1.0))

def mix(a, b, t):
    return tuple(a[i] + (b[i] - a[i]) * t for i in range(3))

def target_luminance(rgb, target):
    """Mix rgb toward black or white until luminance ~= target. Luminance is monotonic along
    each segment, so a plain bisection with the right sign works."""
    target = clamp(target, 0.0, 1.0)
    if abs(target - lum(rgb)) < 1e-4:
        return rgb
    toward_black = target < lum(rgb)
    toward = (0.0, 0.0, 0.0) if toward_black else (1.0, 1.0, 1.0)
    lo, hi = 0.0, 1.0
    for _ in range(40):
        mid = (lo + hi) / 2
        lc = lum(mix(rgb, toward, mid))
        # toward black: lc decreases as mid grows. toward white: lc increases as mid grows.
        if (toward_black and lc > target) or ((not toward_black) and lc < target):
            lo = mid
        else:
            hi = mid
    return mix(rgb, toward, (lo + hi) / 2)

def solve_ink(cap_rgb, want_ratio=6.0, prefer_dark=None):
    """Return an ink colour (slightly tinted, not pure black/white) that hits ~want_ratio
    against cap_rgb. Direction chosen by feasibility unless forced."""
    Lc = lum(cap_rgb)
    if prefer_dark is None:
        prefer_dark = Lc > 0.42
    # a faintly warm-neutral dark and a faintly cool-neutral light, both real colours not #000/#fff
    dark = (0x22/255, 0x1c/255, 0x28/255)
    light = (0xF2/255, 0xEC/255, 0xF0/255)
    base = dark if prefer_dark else light
    tw = (0.0, 0.0, 0.0) if prefer_dark else (1.0, 1.0, 1.0)
    def ratio(t):
        c = mix(base, tw, t)
        return contrast_ratio((c[0], c[1], c[2], 1.0), (cap_rgb[0], cap_rgb[1], cap_rgb[2], 1.0))
    # ratio increases monotonically with t (ink moves away from the cap toward the extreme)
    if ratio(1.0) <= want_ratio:
        return mix(base, tw, 1.0)
    lo, hi = 0.0, 1.0
    for _ in range(34):
        mid = (lo + hi) / 2
        if ratio(mid) < want_ratio:
            lo = mid
        else:
            hi = mid
    return mix(base, tw, (lo + hi) / 2)

def shift_hue(rgb, deg, sat_mul=1.0):
    h, l, s = colorsys.rgb_to_hls(*rgb)
    h = (h + deg / 360.0) % 1.0
    s = clamp(s * sat_mul)
    return colorsys.hls_to_rgb(h, l, s)

def sample_plate(stem, anchor):
    from PIL import Image
    import numpy as np
    im = Image.open(f"{PLATE_DIR}/themebg_{stem}.png").convert("RGB")
    a = np.asarray(im, dtype=float); H, W, _ = a.shape
    winH = int(W / 1.48); top = int((H - winH) * anchor)
    band = a[top:top+winH]
    cy0, cy1 = int(winH*0.28), int(winH*0.92)   # skip the top decorative shelf, weight the key rows
    cx0, cx1 = int(W*0.16), int(W*0.84)
    core = band[cy0:cy1, cx0:cx1].reshape(-1, 3) / 255.0
    coreL = float(np.mean(0.2126*core[:,0] + 0.7152*core[:,1] + 0.0722*core[:,2]))
    # k-means (k=4) darkest -> lightest
    rng = np.random.default_rng(0)
    pts = core[rng.choice(len(core), min(6000, len(core)), replace=False)]
    cen = pts[rng.choice(len(pts), 4, replace=False)].copy()
    for _ in range(15):
        d = ((pts[:, None, :] - cen[None, :, :])**2).sum(2); lab = d.argmin(1)
        for k in range(4):
            if (lab == k).any(): cen[k] = pts[lab == k].mean(0)
    cen = sorted([tuple(c) for c in cen], key=lum)
    mean = tuple(core.mean(0))
    return dict(coreL=coreL, pal=cen, mean=mean)

# ---------------------------------------------------------------------------- cap / role derivation

FORBIDDEN = (0.11, 0.45)

def snap_out(Lt):
    if Lt <= FORBIDDEN[0] or Lt >= FORBIDDEN[1]:
        return Lt
    # push to whichever edge is nearer
    return FORBIDDEN[0] if (Lt - FORBIDDEN[0]) < (FORBIDDEN[1] - Lt) else FORBIDDEN[1]

def derive_cap(info, material, ov):
    """Return (cap_top_rgb, is_dark_cap)."""
    coreL, pal = info["coreL"], info["pal"]
    if coreL < 0.31:
        # dark plate: cap sits BELOW the plate, carried by the rim. Use the plate's own darkest
        # cluster, nudged a hair darker so a shallow gradient still separates.
        cap = target_luminance(pal[0], max(0.006, lum(pal[0]) * 0.8))
        return cap, True
    # light plate: cap a touch darker than the core, snapped out of the forbidden band, built by
    # darkening the plate's OWN light cluster (never lightening a raw saturated hue).
    Lt = snap_out(coreL - 0.13)
    if material == "Letterpress":
        Lt = snap_out(coreL - 0.19)      # pressed further into the "paper"
    Lt = max(Lt, 0.46)
    cap = target_luminance(pal[2] if lum(pal[2]) > Lt else pal[3], Lt)
    if "cap_hue_deg" in ov or "cap_sat_mul" in ov:
        cap = shift_hue(cap, ov.get("cap_hue_deg", 0.0), ov.get("cap_sat_mul", 1.0))
        cap = target_luminance(cap, Lt)   # hue/sat shift can move luminance — pin it back
    return cap, False

def role_variants(cap_top, is_dark, info, material):
    m = MATERIAL[material]
    pal = info["pal"]
    # gradient bottom stop
    dL = m["grad_dL"]
    if m.get("pearl"):
        top = shift_hue(cap_top, +10, 1.05)                     # warm
        bot = target_luminance(shift_hue(cap_top, -18, 1.10), max(0.02, lum(cap_top) - dL))  # cool + darker
    else:
        top = cap_top
        bot = target_luminance(cap_top, clamp(lum(cap_top) + (dL if is_dark else -dL), 0.02, 0.98))
    # system: a step deeper than input
    sys_top = target_luminance(cap_top, clamp(lum(cap_top) + (0.05 if is_dark else -0.06), 0.01, 0.98))
    sys_bot = target_luminance(sys_top, clamp(lum(sys_top) + (dL if is_dark else -dL), 0.01, 0.98))
    # action: pull toward the plate's most saturated cluster (accent), keep the cap's luminance band
    acc_src = max(pal, key=lambda c: colorsys.rgb_to_hls(*c)[2])
    acc_top = target_luminance(mix(cap_top, acc_src, 0.5), lum(cap_top))
    acc_bot = target_luminance(acc_top, clamp(lum(acc_top) + (dL if is_dark else -dL), 0.02, 0.98))
    return dict(input=(top, bot), system=(sys_top, sys_bot), action=(acc_top, acc_bot))

# ---------------------------------------------------------------------------- swift emission

def C(rgb, alpha=None):
    h = to_hex(rgb)
    return f'ThemeColor(hex: "{h}")!' + (f'.withAlpha({alpha:.2f})' if alpha is not None else '')

def fill(stops, alpha=None):
    inner = ",\n                    ".join(C(s, alpha) for s in stops)
    return f'ThemeFill(stops: [\n                    {inner}\n                ])'

def emit_role(role, tops, ink_rgb, is_dark, info, material, very_dark=False):
    m = MATERIAL[material]
    a = m.get("fill_alpha")
    fa = None
    if m["translucent"] and role != "space":
        fa = {"input": a[0], "system": a[1], "action": a[2]}[role]

    top, bot = tops

    # border colour + strength. A near-black cap (`very_dark`) leans hard on a bright hairline rim —
    # it's the only thing saying "key".
    border_alpha = m["border_alpha"]
    if m["border_from"] == "ink":
        bcol = ink_rgb
    elif m["border_from"] == "dark":
        bcol = target_luminance(top, max(0.02, lum(top) * 0.45))
    else:  # light
        lift = 0.55 if is_dark else 0.35
        if very_dark:
            lift = 0.68
            border_alpha = min(0.9, border_alpha + 0.25)
        bcol = target_luminance(top, clamp(lum(top) + lift, 0, 0.98))

    # shadow colour
    scol = (0.06, 0.04, 0.09) if m["shadow_from"] == "dark" else (1, 1, 1)
    so, sr, sy = m["shadow"]

    # pressed
    if is_dark or m["press"] == "lighten":
        pr_top = target_luminance(top, clamp(lum(top) + 0.10, 0.02, 0.5))
        pr_bot = target_luminance(bot, clamp(lum(bot) + 0.10, 0.02, 0.5))
        pr_ink = ink_rgb
    else:
        pr_top = target_luminance(top, clamp(lum(top) - 0.09, 0.06, 0.98))
        pr_bot = target_luminance(bot, clamp(lum(bot) - 0.09, 0.06, 0.98))
        pr_ink = ink_rgb

    lines = []
    lines.append(f'                fill: {fill([top, bot], fa)}')
    if role == "space":
        lines.append(f'                labelColor: {C(ink_rgb, 0.0)}')
    else:
        lines.append(f'                labelColor: {C(ink_rgb)}')
    lines.append(f'                pressedFill: {fill([pr_top, pr_bot], (min(1.0, fa+0.12) if fa else None))}')
    if role != "space":
        lines.append(f'                pressedLabelColor: {C(pr_ink)}')
    lines.append(f'                border: ThemeBorder(color: {C(bcol, border_alpha)}, width: {m["border_width"]:.2f})')
    lines.append(f'                shadow: ThemeShadow(color: {C(scol)}, opacity: {so:.2f}, radius: {sr:.2f}, offsetY: {sy:.2f})')
    if m["top_highlight_alpha"] is not None:
        hi = (1, 1, 1) if not is_dark else target_luminance(top, clamp(lum(top) + 0.5, 0, 1))
        lines.append(f'                topHighlight: {C(hi, m["top_highlight_alpha"])}')
    else:
        lines.append(f'                topHighlight: nil')
    corner = m["corner"][0 if role in ("input", "system") else (1 if role == "action" else 2)]
    lines.append(f'                cornerRadiusOverride: {corner:.1f}')
    g = m["glass"]
    if g is not None and role != "space":
        bev = target_luminance(top, clamp(lum(top) + (0.45 if not is_dark else 0.55), 0, 1)) if g["bevel_from"] == "light" else target_luminance(top, lum(top)*0.4)
        inn = target_luminance(top, clamp(lum(top) + 0.5, 0, 1)) if g["inner_from"] == "light" else (0.04, 0.03, 0.06)
        lines.append(
            '                glass: KeyGlass(\n'
            f'                    bevelColor: {C(bev, g["bevel_alpha"])},\n'
            f'                    bevelWidth: {g["bevel_width"]:.2f},\n'
            f'                    bevelFalloff: {g["falloff"]:.2f},\n'
            f'                    innerShadowColor: {C(inn)},\n'
            f'                    innerShadowOpacity: {g["inner_opacity"]:.2f},\n'
            f'                    innerShadowRadius: {g["inner_radius"]:.2f}\n'
            '                )'
        )
    body = ",\n".join(lines)
    return f'            .{role}: KeyStyle(\n{body}\n            )'

def build_keystyles(name):
    stem, anchor, material = THEMES[name]
    ov = THEME_OVERRIDES.get(name, {})
    info = sample_plate(stem, anchor)
    cap_top, is_dark = derive_cap(info, material, ov)
    very_dark = info["coreL"] < 0.13
    rv = role_variants(cap_top, is_dark, info, material)

    # The ink must clear 4.5:1 on EVERY cap surface it will ever sit on — resting + pressed, all
    # three roles, both gradient stops. Collect them all and solve against the single worst one.
    def pressed_pair(top, bot):
        if is_dark or MATERIAL[material]["press"] == "lighten":
            return (target_luminance(top, clamp(lum(top) + 0.10, 0.02, 0.5)),
                    target_luminance(bot, clamp(lum(bot) + 0.10, 0.02, 0.5)))
        return (target_luminance(top, clamp(lum(top) - 0.09, 0.06, 0.98)),
                target_luminance(bot, clamp(lum(bot) - 0.09, 0.06, 0.98)))
    surfaces = []
    for role in ("input", "system", "action"):
        surfaces += list(rv[role])
        surfaces += list(pressed_pair(*rv[role]))
    # dark cap -> light ink -> worst is the LIGHTEST surface; light cap -> dark ink -> DARKEST.
    worst = max(surfaces, key=lum) if is_dark else min(surfaces, key=lum)
    ink = solve_ink(worst, want_ratio=5.6, prefer_dark=(not is_dark))

    roles = []
    for role in ("input", "system", "action"):
        roles.append(emit_role(role, rv[role], ink, is_dark, info, material, very_dark=very_dark))
    # space: translucent + hidden label, of-the-scene
    m = MATERIAL[material]
    sp_alpha = 0.42 if not is_dark else 0.5
    sp_top = rv["input"][0]; sp_bot = rv["input"][1]
    sp_lines = [
        f'                fill: {fill([sp_top, sp_bot], sp_alpha)}',
        f'                labelColor: {C(ink, 0.0)}',
        f'                pressedFill: {fill([target_luminance(sp_top, clamp(lum(sp_top)+(0.08 if is_dark else -0.08),0.02,0.98)), target_luminance(sp_bot, clamp(lum(sp_bot)+(0.08 if is_dark else -0.08),0.02,0.98))], sp_alpha)}',
        f'                border: ThemeBorder(color: {C(target_luminance(sp_top, clamp(lum(sp_top)+(0.35 if not is_dark else 0.5),0,0.98)), m["border_alpha"])}, width: {m["border_width"]:.2f})',
        f'                shadow: ThemeShadow(color: {C((0.06,0.04,0.09))}, opacity: {m["shadow"][0]:.2f}, radius: {m["shadow"][1]:.2f}, offsetY: {m["shadow"][2]:.2f})',
        (f'                topHighlight: {C((1,1,1) if not is_dark else target_luminance(sp_top, clamp(lum(sp_top)+0.5,0,1)), m["top_highlight_alpha"])}' if m["top_highlight_alpha"] is not None else '                topHighlight: nil'),
        f'                cornerRadiusOverride: {m["corner"][2]:.1f}',
    ]
    roles.append('            .space: KeyStyle(\n' + ",\n".join(sp_lines) + '\n            )')

    ks = "        keyStyles: [\n" + ",\n".join(roles) + "\n        ]"
    scrim_top, scrim_bot = m["scrim"]
    # scrim hue: the plate mean, darkened
    sc = target_luminance(info["mean"], max(0.02, lum(info["mean"]) * 0.55))
    scrim = ('scrim: ThemeScrim(\n'
             f'                topColor: {C(sc, scrim_top)},\n'
             f'                bottomColor: {C(sc, scrim_bot)}\n'
             '            )')
    ka = dict(m["keyart"])
    # keyArt opacity: bright on light caps (reads as cute decoration), but a whisper on dark caps —
    # several illustration sets have near-opaque light backgrounds that turn into glaring blocks on a
    # dark cap (the validators can't see keyArt, so this is caught by eye, not by them).
    ka["op"] = 0.15 if is_dark else 0.90
    return ks, scrim, anchor, ka, dict(material=material, coreL=info["coreL"], cap=to_hex(cap_top), ink=to_hex(ink), dark=is_dark)

# ---------------------------------------------------------------------------- source rewrite

def match_bracket(s, i, op='[', cl=']'):
    depth = 0
    while i < len(s):
        if s[i] == op: depth += 1
        elif s[i] == cl:
            depth -= 1
            if depth == 0: return i
        i += 1
    raise ValueError("unbalanced")

def match_paren(s, i): return match_bracket(s, i, '(', ')')

def theme_span(text, name):
    m = re.search(r'static let %s = MochiKeyboardTheme\(' % re.escape(name), text)
    o = text.index('(', m.start()); return m.start(), match_paren(text, o) + 1

text = open(SRC).read()
report = []
for name in THEMES:
    ks, scrim, anchor, ka, rep = build_keystyles(name)
    t0, t1 = theme_span(text, name)
    block = text[t0:t1]

    # replace keyStyles: [...]
    km = re.search(r'\n {8}keyStyles:\s*\[', block)
    ko = block.index('[', km.start()); kc = match_bracket(block, ko)
    block = block[:km.start()] + "\n" + ks + block[kc+1:]

    # replace scrim: ThemeScrim(...) — paren-balanced, not regex (nested ThemeColor parens)
    sm = re.search(r'scrim:\s*ThemeScrim\(', block)
    so = block.index('(', sm.start()); sc = match_paren(block, so)
    block = block[:sm.start()] + scrim + block[sc+1:]

    # verticalAnchor
    block = re.sub(r'verticalAnchor:\s*[\d.]+', f'verticalAnchor: {anchor}', block, count=1)

    # keyArt: rewrite fields inside the KeyArtSet(...) paren span only (opacity also appears in
    # shadow/glass, so scope it).
    am = re.search(r'keyArt:\s*KeyArtSet\(', block)
    ao = block.index('(', am.start()); ac = match_paren(block, ao)
    kb = block[ao:ac+1]
    kb = re.sub(r'heightFraction:\s*[\d.]+', f'heightFraction: {ka["h"]:.2f}', kb, count=1)
    kb = re.sub(r'bottomInsetFraction:\s*[\d.]+', f'bottomInsetFraction: {ka["inset"]:.2f}', kb, count=1)
    kb = re.sub(r'labelLiftFraction:\s*[\d.]+', f'labelLiftFraction: {ka["lift"]:.2f}', kb, count=1)
    kb = re.sub(r'\bopacity:\s*[\d.]+', f'opacity: {ka["op"]:.2f}', kb, count=1)
    block = block[:ao] + kb + block[ac+1:]

    text = text[:t0] + block + text[t1:]
    report.append(f'{name:24s} {rep["material"]:12s} coreL={rep["coreL"]:.2f} dark={str(rep["dark"]):5s} cap={rep["cap"]} ink={rep["ink"]} anchor={anchor}')

open(SRC, "w").write(text)
open("/Users/Tanmay/Desktop/Projects/Mochi/scratchpad/report_v2.txt", "w").write("\n".join(report))
print("\n".join(report))
print("\nwritten.")
