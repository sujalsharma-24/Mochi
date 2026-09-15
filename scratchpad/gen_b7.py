"""Generate BuiltInThemes+Batch7.swift -- the 20 themes ingested from ~/Downloads/THEMES!!.

Reuses gen_b56's machinery verbatim (7-material system, cap luminance bisected against the plate's
own post-scrim percentile extremes, ink solved for a real contrast target). The only new work here
is the per-theme material/effect assignment below, chosen by eye against each background plate:
the material decides key shape, translucency, bevel and shadow, so it is what makes a theme's keys
belong to its artwork rather than being a generic cap with a colour swap.

Note `gen_b56.ka_op` is now a flat 0.90. It used to be `0.15 if is_dark else 0.90`, which is what
made every dark theme in batches 2-6 ship with near-invisible key illustrations.
"""
import sys
sys.path.insert(0, "/Users/Tanmay/Desktop/Projects/Mochi/scratchpad")
from gen_b56 import gen

# (display name, keyart prefix, material, effect) -- effect is None or (tint_hex, birthRate)
THEMES_7 = [
    ("Alien Playtopia",        "alp", "Jelly",       ("#CDB4FF", 5)),
    ("Bubblegum Circuit",      "bgc", "Pearl",       ("#FFB8E6", 5)),
    ("Dreamscape Portal",      "dsp", "Pane",        ("#FFE8B0", 5)),
    ("Dreamy Control Room",    "dcr", "Clay",        None),
    ("Enchanted Glass Garden", "egg", "Pane",        None),
    ("Floating Dreamscape",    "fld", "Pearl",       None),
    ("Glitch Garden",          "glg", "Inkwell",     ("#FF7BD5", 6)),
    ("Holographic Daydream",   "hgd", "Pearl",       None),
    ("Liquid Aurora",          "lqa", "Inkwell",     ("#CFE8FF", 6)),
    ("Miniature Greenhouse",   "mng", "Pane",        ("#BFE8A8", 5)),
    ("Moon Arcade Dreams",     "mad", "Inkwell",     ("#FF6BE0", 7)),
    ("Neon Aquarium",          "naq", "Pane",        ("#5EE8FF", 6)),
    ("Pastel Beyond",          "pbd", "Jelly",       None),
    ("Pixel Pet Dreams",       "ppd", "Keycap",      None),
    ("Pocket City Dreams",     "pcd", "Clay",        None),
    ("Pocket Cosmos",          "pcm", "Letterpress", None),
    ("Prismatic Jelly Dreams", "pjd", "Jelly",       ("#B9F3FF", 6)),
    ("Puzzlewood Adventures",  "pwa", "Inkwell",     ("#FFD98A", 5)),
    ("Reflective Dreamworld",  "rfd", "Pearl",       ("#D9C4FF", 6)),
    ("Ruins & Relics",         "rnr", "Letterpress", None),
]

if __name__ == "__main__":
    rep = gen(THEMES_7, "Batch 7", 7,
              "/Users/Tanmay/Desktop/Projects/Mochi/ios/MochiShared/Themes/BuiltInThemes+Batch7.swift",
              "~/Downloads/THEMES!!")
    print("\n".join(rep))
    print("\nwrote batch7 (%d themes)" % len(THEMES_7))
