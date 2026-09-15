"""Generate BuiltInThemes+Batch5.swift (THH, 19 themes) and +Batch6.swift (Theses10, 25 themes).

Fixes a real bug found this session: the batch3/4 `derive_cap` used a fixed luminance delta
(coreL - 0.13) floored at 0.46, which for light plates produced caps that landed at nearly the same
luminance as bright patches of the actual art -- validated by re-running validate-themes.sh against
a shipped batch4 theme and finding "cap cover 0.00%, worst 1.04:1" (i.e. invisible without the
1px border). This generator instead bisects the cap's luminance against the *local percentile
extremes* of the plate (post scrim), the same worst-case-against-real-pixels idea
ArtBackdropCheck.swift already uses to grade themes, so caps in this batch are chosen to actually
separate from their backdrop rather than snapping into one narrow luminance band.
"""
import re, sys, colorsys, os
import numpy as np
from PIL import Image
sys.path.insert(0, "/Users/Tanmay/Desktop/Projects/Mochi/scratchpad")
from theme_color import rel_luminance, contrast_ratio, composited, with_alpha

XC = "/Users/Tanmay/Desktop/Projects/Mochi/ios/SharedAssets/KeyboardArt.xcassets"

# (display name, keyart prefix, material, effect) -- effect is None or (tint_hex, birthRate)
THEMES_5 = [
    ("Botanical Workshop", "btw", "Clay", None),
    ("Candy Bakery", "cdb", "Jelly", None),
    ("Cosmic Astronaut", "csa", "Pearl", ("#B7C6FF", 6)),
    ("Cozy Cat", "czc", "Clay", None),
    ("Cozy Night Keyboard", "cnk", "Inkwell", None),
    ("Cozy Terrarium", "czt", "Pane", None),
    ("Dreamy Garden", "dmg", "Pearl", None),
    ("Kawaii Cosmic Study", "kcs", "Jelly", ("#FFD9EC", 5)),
    ("Kawaii Ocean Night", "kon", "Jelly", None),
    ("Neon Racing Garage", "nrg", "Inkwell", None),
    ("Pastel Lakeside Carnival", "plc", "Keycap", None),
    ("Pastel Underwater", "ptu", "Pane", None),
    ("Prehistoric Fossil Explorer", "pfe", "Letterpress", None),
    ("Retro Arcade", "rta", "Keycap", None),
    ("Sakura Night Kawaii Landscape", "snk", "Pearl", None),
    ("Seaside Postcard", "ssp", "Letterpress", None),
    ("Sunset Music Studio", "sms", "Pearl", None),
    ("Whimsical World", "whw", "Clay", None),
    ("Witchy Potion Shop", "wps", "Pane", ("#C9A8FF", 6)),
]

THEMES_6 = [
    ("Abyssal Neon Haven", "anh", "Inkwell", ("#37E3C9", 6)),
    ("Adventure Awaits", "adv", "Letterpress", None),
    ("Alien Moonlift", "alm", "Keycap", ("#9CFFB0", 5)),
    ("Blooming Gardenia", "blg", "Pearl", None),
    ("Clockwork Horizon", "ckh", "Letterpress", None),
    ("Cosmic Little Visitors", "clv", "Jelly", ("#FFE38A", 6)),
    ("Cosmic Observatory", "cob", "Inkwell", ("#8FB4FF", 7)),
    ("Cozy Yarn Haven", "cyh", "Clay", None),
    ("Dragonlight Valley", "dlv", "Pearl", ("#FF9E5E", 6)),
    ("Firework Dream Festival", "fdf", "Jelly", ("#FFD24C", 8)),
    ("Forgotten Ruins", "fgr", "Letterpress", None),
    ("Frosted Crystal Cavern", "fcc", "Pane", ("#CFF3FF", 7)),
    ("Jurassic Sunset Park", "jsp", "Keycap", None),
    ("Kitebound Sunset", "kbs", "Pearl", None),
    ("Meadow Morning", "mdm", "Clay", None),
    ("Moonlit Potion Lab", "mpl", "Jelly", ("#B48CFF", 5)),
    ("Mystery at Dusk", "myd", "Inkwell", None),
    ("Neon Code Haven", "nch", "Keycap", None),
    ("Neural Dreamscape", "nrd", "Pane", ("#5EF2FF", 6)),
    ("Oceanic Dreamscape", "ocd", "Pane", None),
    ("Sakura Serenity", "sks", "Jelly", None),
    ("Skyward Explorer", "ske", "Clay", None),
    ("Skyward Reverie", "skr", "Pearl", None),
    ("Starlit Orbit", "sto", "Pane", ("#E6D8FF", 6)),
    ("Wanderlight Loft", "wnl", "Clay", None),
]

def stem_of(name):
    s = name.lower().replace("&", "and").replace("'", "")
    s = re.sub(r"[^a-z0-9]+", "_", s).strip("_")
    return s

def kebab(name):
    s = name.lower().replace("&", "and").replace("'", "")
    s = re.sub(r"[^a-z0-9]+", "-", s).strip("-")
    return s

def camel(name):
    parts = re.sub(r"[^A-Za-z0-9]+", " ", name.replace("&", "and")).split()
    return parts[0].lower() + "".join(p.capitalize() for p in parts[1:])

MATERIAL = {
    "Inkwell": dict(corner=(12.0,12.0,14.0), translucent=False,
        border_alpha=0.60, border_width=1.0, border_from="light",
        shadow=(0.32,2.6,1.6), shadow_from="dark", top_highlight_alpha=0.28,
        glass=dict(bevel_from="light", bevel_alpha=0.62, bevel_width=1.0, falloff=0.12,
                   inner_from="dark", inner_opacity=0.36, inner_radius=3.0),
        scrim=(0.20,0.06), grad_dL=0.025, press="lighten", keyart=dict(h=0.44, inset=0.09, lift=0.14),
        polarity="dark"),
    "Pane": dict(corner=(13.0,13.0,15.0), translucent=True, fill_alpha=(0.73,0.79,0.79),
        border_alpha=0.58, border_width=1.2, border_from="light",
        shadow=(0.17,1.9,1.1), shadow_from="dark", top_highlight_alpha=0.58,
        glass=dict(bevel_from="light", bevel_alpha=0.82, bevel_width=1.3, falloff=0.34,
                   inner_from="dark", inner_opacity=0.20, inner_radius=2.8),
        scrim=(0.26,0.16), grad_dL=0.05, press="auto", keyart=dict(h=0.46, inset=0.09, lift=0.14),
        polarity="light"),
    "Jelly": dict(corner=(19.0,19.0,20.0), translucent=False,
        border_alpha=0.40, border_width=1.15, border_from="dark",
        shadow=(0.30,4.2,3.0), shadow_from="dark", top_highlight_alpha=0.62,
        glass=dict(bevel_from="light", bevel_alpha=0.0, bevel_width=0.0, falloff=0.5,
                   inner_from="light", inner_opacity=0.34, inner_radius=3.2),
        scrim=(0.18,0.05), grad_dL=0.06, press="auto", keyart=dict(h=0.50, inset=0.10, lift=0.15),
        polarity="light"),
    "Clay": dict(corner=(9.0,9.0,11.0), translucent=False,
        border_alpha=0.32, border_width=1.35, border_from="dark",
        shadow=(0.22,3.6,2.6), shadow_from="dark", top_highlight_alpha=None, glass=None,
        scrim=(0.18,0.05), grad_dL=0.05, press="auto", keyart=dict(h=0.52, inset=0.10, lift=0.15),
        polarity="dark"),
    "Letterpress": dict(corner=(6.0,6.0,8.0), translucent=False,
        border_alpha=0.80, border_width=1.7, border_from="ink",
        shadow=(0.0,0.0,0.0), shadow_from="dark", top_highlight_alpha=None, glass=None,
        scrim=(0.16,0.05), grad_dL=0.035, press="auto", keyart=dict(h=0.40, inset=0.09, lift=0.13),
        polarity="dark"),
    "Keycap": dict(corner=(8.0,8.0,10.0), translucent=False,
        border_alpha=0.55, border_width=1.0, border_from="light",
        shadow=(0.26,1.6,1.6), shadow_from="dark", top_highlight_alpha=0.34,
        glass=dict(bevel_from="light", bevel_alpha=0.70, bevel_width=1.0, falloff=0.10,
                   inner_from="dark", inner_opacity=0.16, inner_radius=2.0),
        scrim=(0.18,0.05), grad_dL=0.05, press="auto", keyart=dict(h=0.46, inset=0.09, lift=0.14),
        polarity="auto"),
    "Pearl": dict(corner=(14.0,14.0,16.0), translucent=False,
        border_alpha=0.42, border_width=0.95, border_from="light",
        shadow=(0.15,2.2,1.3), shadow_from="dark", top_highlight_alpha=0.46,
        glass=dict(bevel_from="light", bevel_alpha=0.60, bevel_width=0.8, falloff=0.18,
                   inner_from="dark", inner_opacity=0.12, inner_radius=2.0),
        scrim=(0.18,0.05), grad_dL=0.10, press="auto", pearl=True, keyart=dict(h=0.48, inset=0.09, lift=0.14),
        polarity="auto"),
}

def clamp(v,a=0.0,b=1.0): return max(a,min(b,v))
def to_hex(rgb): return "#%02X%02X%02X" % tuple(int(round(clamp(c)*255)) for c in rgb[:3])
def lum(rgb): return rel_luminance((rgb[0],rgb[1],rgb[2],1.0))
def mix(a,b,t): return tuple(a[i]+(b[i]-a[i])*t for i in range(3))
def shift_hue(rgb,deg,sat_mul=1.0):
    h,l,s = colorsys.rgb_to_hls(*rgb); h=(h+deg/360.0)%1.0; s=clamp(s*sat_mul)
    return colorsys.hls_to_rgb(h,l,s)

def target_luminance(rgb,target):
    target=clamp(target,0.0,1.0)
    if abs(target-lum(rgb))<1e-4: return rgb
    tb = target<lum(rgb); toward=(0.,0.,0.) if tb else (1.,1.,1.)
    lo,hi=0.,1.
    for _ in range(40):
        mid=(lo+hi)/2; lc=lum(mix(rgb,toward,mid))
        if (tb and lc>target) or ((not tb) and lc<target): lo=mid
        else: hi=mid
    return mix(rgb,toward,(lo+hi)/2)

def solve_ink(cap,want=6.0,prefer_dark=None):
    if prefer_dark is None: prefer_dark = lum(cap)>0.42
    dark=(0x22/255,0x1c/255,0x28/255); light=(0xF2/255,0xEC/255,0xF0/255)
    base = dark if prefer_dark else light
    tw=(0.,0.,0.) if prefer_dark else (1.,1.,1.)
    def r(t):
        c=mix(base,tw,t); return contrast_ratio((c[0],c[1],c[2],1.),(cap[0],cap[1],cap[2],1.))
    if r(1.0)<=want: return mix(base,tw,1.0)
    lo,hi=0.,1.
    for _ in range(34):
        mid=(lo+hi)/2
        if r(mid)<want: lo=mid
        else: hi=mid
    return mix(base,tw,(lo+hi)/2)

def load_plate(stem):
    p = os.path.join(XC, f"themebg_{stem}.imageset")
    heic = os.path.join(p, f"themebg_{stem}.heic")
    png = "/Users/Tanmay/Desktop/Projects/Mochi/scratchpad/_plate_" + stem + ".png"
    os.system(f'sips -s format png "{heic}" --out "{png}" >/dev/null 2>&1')
    return np.asarray(Image.open(png).convert("RGB"), dtype=float)/255.0

def sample(stem, anchor=0.5):
    a = load_plate(stem); H,W,_ = a.shape
    winH=int(W/1.48); top=int((H-winH)*anchor); band=a[top:top+winH]
    cy0,cy1 = int(winH*0.28), int(winH*0.92); cx0,cx1 = int(W*0.16), int(W*0.84)
    core = band[cy0:cy1, cx0:cx1].reshape(-1,3)
    coreL = float(np.mean(0.2126*core[:,0]+0.7152*core[:,1]+0.0722*core[:,2]))
    Lvec = 0.2126*core[:,0]+0.7152*core[:,1]+0.0722*core[:,2]
    p5, p95 = float(np.percentile(Lvec,5)), float(np.percentile(Lvec,95))
    rng=np.random.default_rng(0)
    pts=core[rng.choice(len(core), min(6000,len(core)), replace=False)]
    cen=pts[rng.choice(len(pts),4,replace=False)].copy()
    for _ in range(15):
        d=((pts[:,None,:]-cen[None,:,:])**2).sum(2); lab=d.argmin(1)
        for k in range(4):
            if (lab==k).any(): cen[k]=pts[lab==k].mean(0)
    pal=sorted([tuple(c) for c in cen], key=lum)
    mean=tuple(core.mean(0))
    stops=[tuple(band[int(winH*f), W//2]) for f in (0.15,0.5,0.85)]
    busy=float(np.std(Lvec))
    return dict(coreL=coreL, pal=pal, mean=mean, stops=stops, busy=busy, p5=p5, p95=p95)

def hue_preserving_target(rgb, target, min_sat=0.40, sat_boost=1.55):
    """Places a colour at an exact WCAG luminance the same way `target_luminance` does, but by
    bisecting HLS lightness at a fixed (boosted) saturation instead of linearly mixing toward pure
    black/white. Linear-mixing toward black/white is what was crushing every cap to grey/cream/
    charcoal regardless of the source photo's actual hue -- an "icy" theme's cap read as plain grey
    because the mix path passes through grey on the way to any luminance target. This keeps the
    theme's own hue and a real saturation level at whatever luminance the contrast math needs."""
    h, l0, s0 = colorsys.rgb_to_hls(*rgb)
    s = clamp(max(s0 * sat_boost, min_sat if s0 > 0.03 else 0.0), 0.0, 1.0)
    lo, hi = 0.0, 1.0
    for _ in range(30):
        mid = (lo + hi) / 2
        if lum(colorsys.hls_to_rgb(h, mid, s)) < target: lo = mid
        else: hi = mid
    return colorsys.hls_to_rgb(h, (lo + hi) / 2, s)

def solve_L_below(danger_L, want):
    def c(L): return (max(L,danger_L)+0.05)/(min(L,danger_L)+0.05)
    if c(0.0) < want: return 0.0
    lo,hi=0.0,danger_L
    for _ in range(40):
        mid=(lo+hi)/2
        if c(mid) >= want: lo=mid
        else: hi=mid
    return lo

def solve_L_above(danger_L, want):
    def c(L): return (max(L,danger_L)+0.05)/(min(L,danger_L)+0.05)
    if c(1.0) < want: return 1.0
    lo,hi=danger_L,1.0
    for _ in range(40):
        mid=(lo+hi)/2
        if c(mid) >= want: hi=mid
        else: lo=mid
    return hi

def derive_cap(info, material, scrim_color, scrim_alpha_avg, want=3.6):
    """Bisects the cap's luminance against the plate's own 5th/95th-percentile luminance
    (composited under the theme's own scrim, so a strong scrim earns real credit) instead of the
    old fixed-delta-plus-floor, which is what let caps land at the same luminance as bright art."""
    pal = info["pal"]
    sL = lum(scrim_color)
    a = scrim_alpha_avg
    p5_post  = a*sL + (1-a)*info["p5"]
    p95_post = a*sL + (1-a)*info["p95"]

    dark_L  = solve_L_below(p95_post, want)
    light_L = solve_L_above(p5_post, want)
    dark_margin  = (max(dark_L,p5_post)+0.05)/(min(dark_L,p5_post)+0.05)
    light_margin = (max(light_L,p95_post)+0.05)/(min(light_L,p95_post)+0.05)

    pol = MATERIAL[material]["polarity"]
    coreL = info["coreL"]
    if pol == "auto":
        # Follow the scene by default (light plate -> light cap) rather than a raw margin
        # comparison: contrast(0, X) always has far more headroom than contrast(1, X), so a
        # margin race collapses every "auto" material into dark caps regardless of material intent.
        # Margin only overrides when the natural choice can't clear a sane safety floor.
        natural = "dark" if coreL < 0.45 else "light"
        natural_margin = dark_margin if natural == "dark" else light_margin
        pol = natural if natural_margin >= 1.6 else ("light" if natural == "dark" else "dark")

    if pol == "dark":
        # `dark_L` (bisected against just the local backdrop) is only the MINIMUM luminance that
        # clears backdrop separation -- for Botanical Workshop it solved to 0.183, comfortably
        # dark-looking on its own. But `role_variants`/`pp` add up to +0.15 for the system role's
        # pressed state, landing at ~0.38: right in the middle-gray zone where neither black nor
        # white ink reaches 4.5:1 (measured: white ink only hit 2.4:1 there). The old shipped
        # themes' dark caps all sit near-black (~0.02-0.05) for exactly this reason -- there's
        # headroom under the escalation before it reaches the dead zone. So the dark branch doesn't
        # use `dark_L` for placement, only to help decide polarity above; it forces a true near-black
        # placement, which also only strengthens backdrop separation (darker cap vs any backdrop
        # that isn't itself near-black = more contrast, not less).
        Lc = clamp(lum(pal[0]) * 0.22, 0.004, 0.025)
        return hue_preserving_target(pal[0], Lc), True
    else:
        # Translucent (Pane) fills render blended with the art behind them at ~0.73-0.79 alpha,
        # which this flat-luminance model doesn't simulate -- Neural Dreamscape's real validator
        # run measured system-pressed at 4.41:1 where the opaque-cap math here predicted ~5:1.
        # Extra floor headroom covers that gap without needing to model alpha compositing here.
        floor = 0.46 if MATERIAL[material]["translucent"] else 0.40
        Lc = clamp(light_L, floor, 0.90)
        return hue_preserving_target(pal[-1], Lc), False

def role_variants(cap_top, is_dark, info, material):
    m=MATERIAL[material]; pal=info["pal"]; dL=m["grad_dL"]
    if m.get("pearl"):
        top=shift_hue(cap_top,+10,1.05)
        bot=target_luminance(shift_hue(cap_top,-18,1.10), max(0.02, lum(cap_top)-dL))
    else:
        top=cap_top
        bot=target_luminance(cap_top, clamp(lum(cap_top)+(dL if is_dark else -dL),0.02,0.98))
    sys_top=target_luminance(cap_top, clamp(lum(cap_top)+(0.05 if is_dark else -0.06),0.01,0.98))
    sys_bot=target_luminance(sys_top, clamp(lum(sys_top)+(dL if is_dark else -dL),0.01,0.98))
    acc_src=max(pal, key=lambda c: colorsys.rgb_to_hls(*c)[2])
    acc_top=target_luminance(mix(cap_top,acc_src,0.5), lum(cap_top))
    acc_bot=target_luminance(acc_top, clamp(lum(acc_top)+(dL if is_dark else -dL),0.02,0.98))
    return dict(input=(top,bot), system=(sys_top,sys_bot), action=(acc_top,acc_bot))

def C(rgb, alpha=None):
    return f'ThemeColor(hex: "{to_hex(rgb)}")!' + (f'.withAlpha({alpha:.2f})' if alpha is not None else '')
def fillstr(stops, alpha=None):
    inner=",\n                    ".join(C(s,alpha) for s in stops)
    return f'ThemeFill(stops: [\n                    {inner}\n                ])'

def emit_role(role, tops, ink, is_dark, material, very_dark):
    m=MATERIAL[material]
    fa=None
    if m["translucent"] and role!="space":
        fa={"input":m["fill_alpha"][0],"system":m["fill_alpha"][1],"action":m["fill_alpha"][2]}[role]
    top,bot=tops
    border_alpha=m["border_alpha"]
    if m["border_from"]=="ink": bcol=ink
    elif m["border_from"]=="dark": bcol=target_luminance(top, max(0.02,lum(top)*0.45))
    else:
        lift=0.55 if is_dark else 0.35
        if very_dark: lift=0.68; border_alpha=min(0.9,border_alpha+0.25)
        bcol=target_luminance(top, clamp(lum(top)+lift,0,0.98))
    scol=(0.06,0.04,0.09) if m["shadow_from"]=="dark" else (1,1,1)
    so,sr,sy=m["shadow"]
    if is_dark or m["press"]=="lighten":
        pr_top=target_luminance(top, clamp(lum(top)+0.10,0.02,0.5))
        pr_bot=target_luminance(bot, clamp(lum(bot)+0.10,0.02,0.5))
    else:
        pr_top=target_luminance(top, clamp(lum(top)-0.09,0.06,0.98))
        pr_bot=target_luminance(bot, clamp(lum(bot)-0.09,0.06,0.98))
    L=[]
    L.append(f'                fill: {fillstr([top,bot],fa)}')
    L.append(f'                labelColor: {C(ink, 0.0 if role=="space" else None)}')
    L.append(f'                pressedFill: {fillstr([pr_top,pr_bot], (min(1.0,fa+0.12) if fa else None))}')
    if role!="space": L.append(f'                pressedLabelColor: {C(ink)}')
    L.append(f'                border: ThemeBorder(color: {C(bcol,border_alpha)}, width: {m["border_width"]:.2f})')
    L.append(f'                shadow: ThemeShadow(color: {C(scol)}, opacity: {so:.2f}, radius: {sr:.2f}, offsetY: {sy:.2f})')
    if m["top_highlight_alpha"] is not None:
        hi=(1,1,1) if not is_dark else target_luminance(top, clamp(lum(top)+0.5,0,1))
        L.append(f'                topHighlight: {C(hi, m["top_highlight_alpha"])}')
    else:
        L.append(f'                topHighlight: nil')
    corner=m["corner"][0 if role in ("input","system") else (1 if role=="action" else 2)]
    L.append(f'                cornerRadiusOverride: {corner:.1f}')
    g=m["glass"]
    if g is not None and role!="space":
        bev=target_luminance(top, clamp(lum(top)+(0.45 if not is_dark else 0.55),0,1)) if g["bevel_from"]=="light" else target_luminance(top, lum(top)*0.4)
        inn=target_luminance(top, clamp(lum(top)+0.5,0,1)) if g["inner_from"]=="light" else (0.04,0.03,0.06)
        L.append('                glass: KeyGlass(\n'
                 f'                    bevelColor: {C(bev,g["bevel_alpha"])},\n'
                 f'                    bevelWidth: {g["bevel_width"]:.2f},\n'
                 f'                    bevelFalloff: {g["falloff"]:.2f},\n'
                 f'                    innerShadowColor: {C(inn)},\n'
                 f'                    innerShadowOpacity: {g["inner_opacity"]:.2f},\n'
                 f'                    innerShadowRadius: {g["inner_radius"]:.2f}\n'
                 '                )')
    return f'            .{role}: KeyStyle(\n' + ",\n".join(L) + "\n            )"

# Themes whose art has high *local* dynamic range under individual keys (both deep shadow and a
# highlight within one key's footprint) that the global busy-luminance heuristic under-weights --
# found via the real per-pixel validator, not the coarse Python sampler. Extra scrim pushes those
# hotspots down before the cap has to fight them (no blur -- product preference, never blur the art).
EXTRA_SCRIM = {
    "Wanderlight Loft": dict(scrim_boost=0.20),
    # These three landed within ~0.3:1 of the 4.5 bar on system-pressed / chrome ink specifically
    # (worst-case ink is already at the black/white extreme, so raising `want` had nothing left to
    # give) -- a bit more scrim moves the surface luminance they're solved against, not the ink.
    "Seaside Postcard": dict(scrim_boost=0.10),
    "Meadow Morning": dict(scrim_boost=0.22),
    "Neural Dreamscape": dict(scrim_boost=0.10),
    "Kawaii Ocean Night": dict(scrim_boost=0.10),
}

def build_theme(name, pfx, material, effect):
    stem=stem_of(name)
    info=sample(stem)

    m=MATERIAL[material]
    # Each material's own scrim tuple (as tuned across all prior batches) is the baseline -- a
    # blanket floor was tried here and reined back in because it visibly dimmed the art across
    # every theme ("bg ka occupacity full hona chahiye"). Legibility now comes from the cap-colour
    # bisection above, not from flattening the photo; only busy scenes and the handful of themes in
    # EXTRA_SCRIM (found through the real validator) get anything added on top.
    busy_boost = clamp((info["busy"]-0.13)/0.08, 0.0, 1.0) * 0.08
    extra = EXTRA_SCRIM.get(name)
    if extra: busy_boost += extra["scrim_boost"]
    scrim_alpha_top = clamp(m["scrim"][0] + busy_boost, 0.0, 0.75)
    scrim_alpha_bot = clamp(m["scrim"][1] + busy_boost*0.6, 0.0, 0.60)
    scrim_alpha_avg = (scrim_alpha_top+scrim_alpha_bot)/2

    # A genuinely light cap has to beat the SAME bright local hotspots a dark cap coasts past for
    # free -- and no achievable scrim alpha closes that gap when the scrim's own colour is only
    # mildly darkened. Light-polarity themes get a much darker scrim base colour so the composited
    # backdrop the light cap actually has to clear is meaningfully lower, not just more opaque.
    natural_pol_hint = MATERIAL[material]["polarity"]
    darken_factor = 0.30 if natural_pol_hint in ("light", "auto") else 0.55
    sc0=target_luminance(info["mean"], max(0.02, lum(info["mean"])*darken_factor))

    cap_top,is_dark=derive_cap(info,material,sc0,scrim_alpha_avg)
    very_dark=info["coreL"]<0.13
    rv=role_variants(cap_top,is_dark,info,material)
    def pp(top,bot):
        if is_dark or MATERIAL[material]["press"]=="lighten":
            return (target_luminance(top,clamp(lum(top)+0.10,0.02,0.5)), target_luminance(bot,clamp(lum(bot)+0.10,0.02,0.5)))
        return (target_luminance(top,clamp(lum(top)-0.09,0.06,0.98)), target_luminance(bot,clamp(lum(bot)-0.09,0.06,0.98)))
    surf=[]
    for r in ("input","system","action"):
        surf+=list(rv[r]); surf+=list(pp(*rv[r]))
    worst=max(surf,key=lum) if is_dark else min(surf,key=lum)
    ink=solve_ink(worst, want=7.2, prefer_dark=(not is_dark))

    roles=[emit_role(r, rv[r], ink, is_dark, material, very_dark) for r in ("input","system","action")]
    sp_alpha=0.42 if not is_dark else 0.5
    sp_top,sp_bot=rv["input"]
    spL=[
        f'                fill: {fillstr([sp_top,sp_bot], sp_alpha)}',
        f'                labelColor: {C(ink, 0.0)}',
        f'                pressedFill: {fillstr([target_luminance(sp_top,clamp(lum(sp_top)+(0.08 if is_dark else -0.08),0.02,0.98)), target_luminance(sp_bot,clamp(lum(sp_bot)+(0.08 if is_dark else -0.08),0.02,0.98))], sp_alpha)}',
        f'                border: ThemeBorder(color: {C(target_luminance(sp_top,clamp(lum(sp_top)+(0.35 if not is_dark else 0.5),0,0.98)), m["border_alpha"])}, width: {m["border_width"]:.2f})',
        f'                shadow: ThemeShadow(color: {C((0.06,0.04,0.09))}, opacity: {m["shadow"][0]:.2f}, radius: {m["shadow"][1]:.2f}, offsetY: {m["shadow"][2]:.2f})',
        (f'                topHighlight: {C((1,1,1) if not is_dark else target_luminance(sp_top,clamp(lum(sp_top)+0.5,0,1)), m["top_highlight_alpha"])}' if m["top_highlight_alpha"] is not None else '                topHighlight: nil'),
        f'                cornerRadiusOverride: {m["corner"][2]:.1f}',
    ]
    roles.append('            .space: KeyStyle(\n'+",\n".join(spL)+'\n            )')

    sc=sc0
    base_dark = min(info["stops"], key=lum)
    backdrop = composited(with_alpha((sc[0], sc[1], sc[2], 1.0), scrim_alpha_bot), (base_dark[0], base_dark[1], base_dark[2], 1.0))[:3]
    bd_L = lum((backdrop[0], backdrop[1], backdrop[2], 1.0))
    ink_dark = bd_L >= 0.18
    chrome_ink = solve_ink(backdrop, want=6.5, prefer_dark=ink_dark)
    if contrast_ratio((chrome_ink[0], chrome_ink[1], chrome_ink[2], 1.0), (backdrop[0], backdrop[1], backdrop[2], 1.0)) < 5.6:
        chrome_ink = (0.03, 0.02, 0.05) if ink_dark else (0.99, 0.98, 1.0)
    panel_base = target_luminance(backdrop, 0.10 if not ink_dark else 0.97)
    hl = (1, 1, 1) if not ink_dark else (0, 0, 0)

    # No background blur, ever -- explicit product preference (also applied to all prior batches
    # in an earlier session; batch5/6 had regressed it back in via the busy-scene heuristic).
    blur = 0.0
    ka=m["keyart"]; ka_op = 0.90  # was `0.15 if is_dark else 0.90` -- dimming art on dark
    # plates made the illustrations effectively invisible (51 shipped themes had to be repaired).
    # Art legibility does not depend on plate polarity; the cap gradient under it already does that work.
    appearance = "dark" if is_dark else "light"

    if effect is not None:
        tint_hex, rate = effect
        effects_lit = (f'ThemeEffects(\n            isEnabled: true,\n            birthRate: {rate:.1f},\n'
                        f'            particleImageName: nil,\n            tint: ThemeColor(hex: "{tint_hex}")!\n        )')
    else:
        effects_lit = ".none"

    lit = f'''    static let {camel(name)} = MochiKeyboardTheme(
        id: "mochi.{kebab(name)}",
        name: "{name}",
        authorName: "Mochi",
        appearance: .{appearance},
        surface: ThemeSurface(
            baseFill: {fillstr(info["stops"])},
            backgroundImage: ThemeBackgroundImage(
                source: .bundled(name: "themebg_{stem}"),
                scalesToFill: true,
                verticalAnchor: 0.5,
                blurRadius: {blur:.1f}
            ),
            scrim: ThemeScrim(
                topColor: {C(sc, scrim_alpha_top)},
                bottomColor: {C(sc, scrim_alpha_bot)}
            )
        ),
        keyStyles: [
{",\n".join(roles)}
        ],
        typography: ThemeTypography(fontFamily: nil, weightRawValue: 0.34, sizeMultiplier: 1.0),
        chrome: ThemeChrome(
            inkColor: {C(chrome_ink)},
            mutedInkColor: {C(chrome_ink, 0.55)},
            panelFill: {fillstr([panel_base], 0.55)},
            highlightFill: {fillstr([hl], 0.16)}
        ),
        keyArt: KeyArtSet(
            assetPrefix: "keyart_{pfx}_",
            heightFraction: {ka["h"]:.2f},
            bottomInsetFraction: {ka["inset"]:.2f},
            opacity: {ka_op:.2f},
            fillKeys: ["space"],
            labelLiftFraction: {ka["lift"]:.2f}
        ),
        effects: {effects_lit}
    )'''
    rep = dict(material=material, coreL=round(info["coreL"],2), dark=is_dark,
               cap=to_hex(cap_top), ink=to_hex(ink), busy=round(info["busy"],3), blur=blur,
               scrimA=round(scrim_alpha_top,2))
    return camel(name), lit, rep

def gen(themes, batch_label, batch_num, out_path, src_note):
    names=[]; lits=[]; rep=[]
    for name,pfx,material,effect in themes:
        cn, lit, r = build_theme(name, pfx, material, effect)
        names.append(cn); lits.append(lit)
        rep.append(f'{cn:28s} {r["material"]:12s} coreL={r["coreL"]:.2f} dark={str(r["dark"]):5s} '
                    f'cap={r["cap"]} ink={r["ink"]} busy={r["busy"]:.3f} blur={r["blur"]} scrimA={r["scrimA"]}')

    header = f'''import Foundation

// {batch_label} -- {len(themes)} additional built-in themes, ingested from {src_note}. Same asset
// pipeline as batch 3/4 (background plate + per-key illustrations), authored on the 7-material
// system. Cap luminance is solved by bisecting real contrast against the plate's own post-scrim
// 5th/95th-percentile luminance (see `derive_cap` in scratchpad/gen_b56.py) rather than a fixed
// offset, so caps in this batch separate from their backdrop instead of matching it.

extension BuiltInThemes {{

    static let batch{batch_num}: [MochiKeyboardTheme] = [
        ''' + ", ".join(names) + '''
    ]

''' + "\n\n".join(lits) + '''
}
'''
    open(out_path,"w").write(header)
    return rep

if __name__ == "__main__":
    rep5 = gen(THEMES_5, "Batch 5", 5,
               "/Users/Tanmay/Desktop/Projects/Mochi/ios/MochiShared/Themes/BuiltInThemes+Batch5.swift",
               "~/Downloads/THH")
    rep6 = gen(THEMES_6, "Batch 6", 6,
               "/Users/Tanmay/Desktop/Projects/Mochi/ios/MochiShared/Themes/BuiltInThemes+Batch6.swift",
               "~/Downloads/Theses10")
    open("/Users/Tanmay/Desktop/Projects/Mochi/scratchpad/report_b56.txt","w").write("\n".join(rep5+["---"]+rep6))
    print("\n".join(rep5))
    print("---")
    print("\n".join(rep6))
    print("\nwrote batch5 (%d) + batch6 (%d)" % (len(THEMES_5), len(THEMES_6)))
