"""Ingest ~/Downloads/THEMES!! (batch7, 20 themes) into ios/SharedAssets/KeyboardArt.xcassets,
matching the batch2-6 asset conventions exactly (see ingest_batch56.py)."""
import os, sys
sys.path.insert(0, "/Users/Tanmay/Desktop/Projects/Mochi/scratchpad")
from ingest_batch56 import ingest_bg, ingest_key

SRC = "/Users/Tanmay/Downloads/THEMES!!"

def main():
    total = 0
    for theme in sorted(os.listdir(SRC)):
        tdir = os.path.join(SRC, theme)
        if not os.path.isdir(tdir):
            continue
        files = os.listdir(tdir)
        bg = next((f for f in files if f.startswith("themebg_")), None)
        if not bg:
            print("!! no themebg in", tdir); continue
        name = bg[len("themebg_"):].rsplit(".", 1)[0]
        pfx = next((f.split("_")[1] for f in files if f.startswith("keyart_")), None)
        ingest_bg(os.path.join(tdir, bg), name)
        n = dropped = 0
        for f in files:
            if not f.startswith("keyart_"):
                continue
            key = f[len(f"keyart_{pfx}_"):].rsplit(".", 1)[0]
            if ingest_key(os.path.join(tdir, f), pfx, key): n += 1
            else: dropped += 1
        total += 1
        print(f"[{total:2d}] {theme:28s} bg={name:28s} pfx={pfx:4s} keys={n} dropped={dropped}", flush=True)
    print("done:", total, "themes")

if __name__ == "__main__":
    main()
