"""Generate BuiltInThemes+Batch4.swift — 9 additional built-in themes from the freshly-ingested
themebg_*/keyart_* assets in ~/Downloads/THE. Same 7-material system as batch3."""
import re, sys, colorsys, os
import numpy as np
from PIL import Image
sys.path.insert(0, "/Users/Tanmay/Desktop/Projects/Mochi/scratchpad")
from theme_color import rel_luminance, contrast_ratio, composited, with_alpha

XC = "/Users/Tanmay/Desktop/Projects/Mochi/ios/SharedAssets/KeyboardArt.xcassets"
OUT = "/Users/Tanmay/Desktop/Projects/Mochi/ios/MochiShared/Themes/BuiltInThemes+Batch4.swift"

THEMES = [
    ("Aether Garden", "atg", "Pane"),
    ("Aurora Moonlit Observatory", "amo", "Pane"),
    ("Cosmic Daydream Station", "cds", "Pane"),
    ("Starlit Cozy Village", "scv", "Letterpress"),
    ("Sunset Storybook Journey", "ssj", "Pearl"),
    ("Tidebound Atelier", "tba", "Clay"),
    ("Whispering Lake Cottage", "wlc", "Clay"),
    ("Whispering Moon Harbor", "wmh", "Pearl"),
    ("Willow Moon Cottage", "wmc", "Letterpress"),
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
        scrim=(0.20,0.06), grad_dL=0.025, press="lighten", keyart=dict(h=0.44, inset=0.09, lift=0.14)),
    "Pane": dict(corner=(13.0,13.0,15.0), translucent=True, fill_alpha=(0.73,0.79,0.79),
        border_alpha=0.50, border_width=1.05, border_from="light",
        shadow=(0.17,1.9,1.1), shadow_from="dark", top_highlight_alpha=0.50,
        glass=dict(bevel_from="light", bevel_alpha=0.74, bevel_width=1.1, falloff=0.40,
                   inner_from="dark", inner_opacity=0.18, inner_radius=2.6),
        scrim=(0.46,0.34), grad_dL=0.05, press="auto", keyart=dict(h=0.46, inset=0.09, lift=0.14)),
    "Jelly": dict(corner=(19.0,19.0,20.0), translucent=False,
        border_alpha=0.40, border_width=1.15, border_from="dark",
        shadow=(0.30,4.2,3.0), shadow_from="dark", top_highlight_alpha=0.62,
        glass=dict(bevel_from="light", bevel_alpha=0.0, bevel_width=0.0, falloff=0.5,
                   inner_from="light", inner_opacity=0.34, inner_radius=3.2),
        scrim=(0.18,0.05), grad_dL=0.06, press="auto", keyart=dict(h=0.50, inset=0.10, lift=0.15)),
    "Clay": dict(corner=(9.0,9.0,11.0), translucent=False,
        border_alpha=0.32, border_width=1.35, border_from="dark",
        shadow=(0.22,3.6,2.6), shadow_from="dark", top_highlight_alpha=None, glass=None,
        scrim=(0.18,0.05), grad_dL=0.05, press="auto", keyart=dict(h=0.52, inset=0.10, lift=0.15)),
    "Letterpress": dict(corner=(6.0,6.0,8.0), translucent=False,
        border_alpha=0.80, border_width=1.7, border_from="ink",
        shadow=(0.0,0.0,0.0), shadow_from="dark", top_highlight_alpha=None, glass=None,
        scrim=(0.16,0.05), grad_dL=0.035, press="auto", keyart=dict(h=0.40, inset=0.09, lift=0.13)),
    "Keycap": dict(corner=(8.0,8.0,10.0), translucent=False,
        border_alpha=0.55, border_width=1.0, border_from="light",
        shadow=(0.26,1.6,1.6), shadow_from="dark", top_highlight_alpha=0.34,
        glass=dict(bevel_from="light", bevel_alpha=0.70, bevel_width=1.0, falloff=0.10,
                   inner_from="dark", inner_opacity=0.16, inner_radius=2.0),
        scrim=(0.18,0.05), grad_dL=0.05, press="auto", keyart=dict(h=0.46, inset=0.09, lift=0.14)),
    "Pearl": dict(corner=(14.0,14.0,16.0), translucent=False,
        border_alpha=0.42, border_width=0.95, border_from="light",
        shadow=(0.15,2.2,1.3), shadow_from="dark", top_highlight_alpha=0.46,
        glass=dict(bevel_from="light", bevel_alpha=0.60, bevel_width=0.8, falloff=0.18,
                   inner_from="dark", inner_opacity=0.12, inner_radius=2.0),
        scrim=(0.18,0.05), grad_dL=0.10, press="auto", pearl=True, keyart=dict(h=0.48, inset=0.09, lift=0.14)),
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

FORBIDDEN=(0.11,0.45)
def snap_out(Lt):
    if Lt<=FORBIDDEN[0] or Lt>=FORBIDDEN[1]: return Lt
    return FORBIDDEN[0] if (Lt-FORBIDDEN[0])<(FORBIDDEN[1]-Lt) else FORBIDDEN[1]

def load_plate(stem):
    p = os.path.join(XC, f"themebg_{stem}.imageset")
    heic = os.path.join(p, f"themebg_{stem}.heic")
    png = "/tmp/plate_" + stem + ".png"
    if not os.path.exists(png):
        os.system(f'sips -s format png "{heic}" --out "{png}" >/dev/null 2>&1')
    return np.asarray(Image.open(png).convert("RGB"), dtype=float)/255.0

def sample(stem, anchor=0.5):
    a = load_plate(stem); H,W,_ = a.shape
    winH=int(W/1.48); top=int((H-winH)*anchor); band=a[top:top+winH]
    cy0,cy1 = int(winH*0.28), int(winH*0.92); cx0,cx1 = int(W*0.16), int(W*0.84)
    core = band[cy0:cy1, cx0:cx1].reshape(-1,3)
    coreL = float(np.mean(0.2126*core[:,0]+0.7152*core[:,1]+0.0722*core[:,2]))
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
    busy=float(np.std(0.2126*core[:,0]+0.7152*core[:,1]+0.0722*core[:,2]))
    return dict(coreL=coreL, pal=pal, mean=mean, stops=stops, busy=busy)

def derive_cap(info, material):
    coreL,pal = info["coreL"], info["pal"]
    if coreL < 0.31:
        return target_luminance(pal[0], max(0.006, lum(pal[0])*0.8)), True
    Lt = snap_out(coreL - (0.19 if material=="Letterpress" else 0.13))
    Lt = max(Lt, 0.46)
    return target_luminance(pal[2] if lum(pal[2])>Lt else pal[3], Lt), False

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

def build_theme(name, pfx, material):
    stem=stem_of(name)
    info=sample(stem)
    cap_top,is_dark=derive_cap(info,material)
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
    ink=solve_ink(worst, want=5.6, prefer_dark=(not is_dark))

    m=MATERIAL[material]
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

    sc=target_luminance(info["mean"], max(0.02, lum(info["mean"])*0.55))

    base_dark = min(info["stops"], key=lum)
    backdrop = composited(with_alpha((sc[0], sc[1], sc[2], 1.0), m["scrim"][1]), (base_dark[0], base_dark[1], base_dark[2], 1.0))[:3]
    bd_L = lum((backdrop[0], backdrop[1], backdrop[2], 1.0))
    ink_dark = bd_L >= 0.18
    chrome_ink = solve_ink(backdrop, want=6.5, prefer_dark=ink_dark)
    if contrast_ratio((chrome_ink[0], chrome_ink[1], chrome_ink[2], 1.0), (backdrop[0], backdrop[1], backdrop[2], 1.0)) < 4.9:
        chrome_ink = (0.03, 0.02, 0.05) if ink_dark else (0.99, 0.98, 1.0)
    panel_base = target_luminance(backdrop, 0.10 if not ink_dark else 0.97)
    hl = (1, 1, 1) if not ink_dark else (0, 0, 0)

    blur = 3.0 if info["busy"]>0.14 else (2.0 if info["busy"]>0.11 else 0.0)
    ka=m["keyart"]; ka_op = 0.15 if is_dark else 0.90
    appearance = "dark" if is_dark else "light"

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
                topColor: {C(sc, m["scrim"][0])},
                bottomColor: {C(sc, m["scrim"][1])}
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
        effects: .none
    )'''
    return camel(name), lit, dict(material=material, coreL=round(info["coreL"],2), dark=is_dark,
                                  cap=to_hex(cap_top), ink=to_hex(ink), busy=round(info["busy"],3), blur=blur)

names=[]; lits=[]; rep=[]
for name,pfx,material in THEMES:
    cn, lit, r = build_theme(name, pfx, material)
    names.append(cn); lits.append(lit)
    rep.append(f'{cn:26s} {r["material"]:12s} coreL={r["coreL"]:.2f} dark={str(r["dark"]):5s} cap={r["cap"]} ink={r["ink"]} busy={r["busy"]:.3f} blur={r["blur"]}')

header = '''import Foundation

// Batch 4 — 9 additional built-in themes, ingested from ~/Downloads/THE. Same asset pipeline as
// batch 3 (background plate + per-key illustrations), authored on the 7-material system: cap
// colour is derived from each plate, material chosen per theme's mood.

extension BuiltInThemes {

    static let batch4: [MochiKeyboardTheme] = [
        ''' + ", ".join(names) + '''
    ]

''' + "\n\n".join(lits) + '''
}
'''

open(OUT,"w").write(header)
open("/Users/Tanmay/Desktop/Projects/Mochi/scratchpad/report_b4.txt","w").write("\n".join(rep))
print("\n".join(rep))
print("\nwrote", OUT, len(header), "bytes")
