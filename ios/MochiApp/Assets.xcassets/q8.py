import numpy as np
mx=im.max(axis=2); mn=im.min(axis=2)
dark = mx<205
def R(idx,gap=5):
    out=[]
    if not len(idx): return out
    s=idx[0];p=idx[0]
    for i in idx[1:]:
        if i-p>gap: out.append((int(s),int(p),int(p-s+1))); s=i
        p=i
    out.append((int(s),int(p),int(p-s+1)))
    return out
def cx(y0,y1,x0,x1,l,gap=5,minc=1):
    c=dark[y0:y1,x0:x1].sum(axis=0); print(l,"X:",R(np.where(c>=minc)[0]+x0,gap))
def cy(y0,y1,x0,x1,l,gap=5,minc=1):
    c=dark[y0:y1,x0:x1].sum(axis=1); print(l,"Y:",R(np.where(c>=minc)[0]+y0,gap))

# --- tab bar (white pill 79..2081, y1466..1565)
cx(1480,1552,90,2075,"tabitems",gap=18,minc=1)
cy(1466,1570,90,2075,"tabrow",gap=3,minc=1)
# selected pill (gradient) - find saturated region in the pill band
sat=(mx-mn)
m=(sat>60)&(im[:,:,2]>150)
c=m[1470:1562,:].sum(axis=0); print("selpill X:",R(np.where(c>30)[0],8))
cy(1466,1570,1180,1480,"selpill",gap=3,minc=1)
