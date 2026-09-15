def hex_to_rgb(h):
    h = h.lstrip('#')
    if len(h) == 6:
        r,g,b = int(h[0:2],16)/255, int(h[2:4],16)/255, int(h[4:6],16)/255
        return (r,g,b,1.0)
    else:
        r,g,b,a = int(h[0:2],16)/255, int(h[2:4],16)/255, int(h[4:6],16)/255, int(h[6:8],16)/255
        return (r,g,b,a)

def composited(c, backdrop):
    r,g,b,a = c
    br,bg,bb,ba = backdrop
    if a >= 1: return (r,g,b,1.0)
    return (r*a+br*(1-a), g*a+bg*(1-a), b*a+bb*(1-a), 1.0)

def linearise(v):
    return v/12.92 if v <= 0.03928 else ((v+0.055)/1.055) ** 2.4

def rel_luminance(c):
    r,g,b,a = c
    return 0.2126*linearise(r) + 0.7152*linearise(g) + 0.0722*linearise(b)

def contrast_ratio(a, b):
    la, lb = rel_luminance(a), rel_luminance(b)
    lighter, darker = max(la,lb), min(la,lb)
    return (lighter+0.05)/(darker+0.05)

def with_alpha(c, alpha):
    r,g,b,_ = c
    return (r,g,b,alpha)
