"""Ingest the 40 new theme folders (~/Downloads/{THEMESSSSSSS,THemeeeee,Theme7}) into
ios/SharedAssets/KeyboardArt.xcassets, matching the batch-2 asset conventions exactly:

  themebg_<name>.imageset/  -> one .heic, 1448px long side, lossless Contents.json
  keyart_<pfx>_<key>.imageset/ -> one .png, trimmed to alpha bbox then scaled to a
      per-key-type width (letters 140 / function 180 / return 360 / space 620)
"""
import os, json, subprocess, sys
from PIL import Image

SRC_DIRS = [
    "/Users/Tanmay/Downloads/THEMESSSSSSS",
    "/Users/Tanmay/Downloads/THemeeeee",
    "/Users/Tanmay/Downloads/Theme7",
]
XC = "/Users/Tanmay/Desktop/Projects/Mochi/ios/SharedAssets/KeyboardArt.xcassets"

FUNCTION = {"shift", "backspace", "globe", "emoji", "123"}
def key_width(key):
    if key == "space":  return 620
    if key == "return": return 360
    if key in FUNCTION: return 180
    return 140  # a-z

def write_contents(folder, filename, lossless=False):
    c = {"images": [{"filename": filename, "idiom": "universal"}],
         "info": {"author": "xcode", "version": 1}}
    if lossless:
        c["properties"] = {"compression-type": "lossless"}
    with open(os.path.join(folder, "Contents.json"), "w") as f:
        json.dump(c, f, indent=2)

def ingest_bg(src_png, name):
    folder = os.path.join(XC, f"themebg_{name}.imageset")
    os.makedirs(folder, exist_ok=True)
    heic = os.path.join(folder, f"themebg_{name}.heic")
    im = Image.open(src_png).convert("RGB")
    w, h = im.size
    if max(w, h) != 1448:
        s = 1448 / max(w, h)
        im = im.resize((round(w*s), round(h*s)), Image.LANCZOS)
    tmp = os.path.join(folder, "_tmp.png")
    im.save(tmp)
    subprocess.run(["sips", "-s", "format", "heic", "-s", "formatOptions", "90",
                    tmp, "--out", heic], check=True, capture_output=True)
    os.remove(tmp)
    write_contents(folder, f"themebg_{name}.heic", lossless=True)

def ingest_key(src_png, pfx, key):
    folder = os.path.join(XC, f"keyart_{pfx}_{key}.imageset")
    os.makedirs(folder, exist_ok=True)
    out = os.path.join(folder, f"keyart_{pfx}_{key}.png")
    im = Image.open(src_png)
    tw = key_width(key)
    if key == "space":
        im = im.convert("RGB")
        w, h = im.size
        im = im.resize((tw, max(1, round(h * tw / w))), Image.LANCZOS)
        im.save(out)
    else:
        im = im.convert("RGBA")
        import numpy as _np
        if (_np.asarray(im)[:, :, 3] > 250).mean() > 0.90:
            # Fully-opaque illustration — the AI generator lost the alpha channel. It would paint a
            # solid rectangle over the cap (a black or white block, depending on the art). Skip it;
            # KeyArtStore returns nil for a missing asset and KeyView just draws a clean cap.
            return
        bbox = im.getbbox()  # bbox of non-zero-alpha (and non-black-opaque, but these have alpha)
        # getbbox on RGBA uses any non-zero channel incl alpha; good enough — pad 1px
        if bbox:
            x0, y0, x1, y1 = bbox
            x0 = max(0, x0-1); y0 = max(0, y0-1)
            x1 = min(im.width, x1+1); y1 = min(im.height, y1+1)
            im = im.crop((x0, y0, x1, y1))
        w, h = im.size
        im = im.resize((tw, max(1, round(h * tw / w))), Image.LANCZOS)
        im.save(out)
    write_contents(folder, f"keyart_{pfx}_{key}.png")

def main():
    total = 0
    for d in SRC_DIRS:
        for theme in sorted(os.listdir(d)):
            tdir = os.path.join(d, theme)
            if not os.path.isdir(tdir):
                continue
            files = os.listdir(tdir)
            bg = next((f for f in files if f.startswith("themebg_")), None)
            if not bg:
                print("!! no themebg in", tdir); continue
            name = bg[len("themebg_"):].rsplit(".", 1)[0]
            pfx = None
            for f in files:
                if f.startswith("keyart_"):
                    pfx = f.split("_")[1]; break
            ingest_bg(os.path.join(tdir, bg), name)
            n = 0
            for f in files:
                if not f.startswith("keyart_"):
                    continue
                key = f[len(f"keyart_{pfx}_"):].rsplit(".", 1)[0]
                ingest_key(os.path.join(tdir, f), pfx, key)
                n += 1
            total += 1
            print(f"[{total:2d}] {name:32s} pfx={pfx} keys={n}")
    print("done:", total, "themes")

if __name__ == "__main__":
    main()
