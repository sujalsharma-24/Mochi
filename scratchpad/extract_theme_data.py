import re, json

SRC = "/Users/Tanmay/Desktop/Projects/Mochi/ios/MochiShared/Themes/BuiltInThemes+Batch2.swift"
text = open(SRC).read()

def match_paren(s, i):
    depth = 0
    while i < len(s):
        if s[i] == '(': depth += 1
        elif s[i] == ')':
            depth -= 1
            if depth == 0: return i
        i += 1
    raise ValueError("unbalanced paren from %d" % i)

# find each theme block
theme_starts = [(m.group(1), m.start(), m.end()) for m in re.finditer(r'static let (\w+) = MochiKeyboardTheme\(', text)]

results = {}
for name, start, open_paren_search_start in theme_starts:
    open_idx = text.index('(', open_paren_search_start - 1)
    end_idx = match_paren(text, open_idx)
    block = text[start:end_idx+1]

    appearance = re.search(r'appearance:\s*\.(\w+)', block).group(1)
    # baseFill stops
    bf_m = re.search(r'baseFill:\s*ThemeFill\(stops:\s*\[(.*?)\]\s*\)', block, re.S)
    basefill_hexes = re.findall(r'#[0-9A-Fa-f]{6,8}', bf_m.group(1)) if bf_m else []
    # scrim
    scrim_m = re.search(r'scrim:\s*ThemeScrim\(\s*topColor:\s*ThemeColor\(hex:\s*"(#[0-9A-Fa-f]+)"\)!\.withAlpha\(([\d.]+)\),\s*bottomColor:\s*ThemeColor\(hex:\s*"(#[0-9A-Fa-f]+)"\)!\.withAlpha\(([\d.]+)\)', block, re.S)
    results[name] = {
        "appearance": appearance,
        "baseFillHexes": basefill_hexes,
        "scrimTop": scrim_m.group(1) if scrim_m else None,
        "scrimTopAlpha": float(scrim_m.group(2)) if scrim_m else None,
        "scrimBottom": scrim_m.group(3) if scrim_m else None,
        "scrimBottomAlpha": float(scrim_m.group(4)) if scrim_m else None,
    }

print(json.dumps(results, indent=1))
