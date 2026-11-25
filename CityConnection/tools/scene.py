"""Dibujo original en píxeles multicolor y rótulos monocromos de 5×7."""
from pathlib import Path

out = Path("build")
pixels = [bytearray(160) for _ in range(200)]
colors = bytearray([11] * 1000)
letters = {
    "P": [30,17,17,30,16,16,16], "T": [31,4,4,4,4,4,4],
    "S": [15,16,16,14,1,1,30], "V": [17,17,17,17,17,10,4],
    "I": [14,4,4,4,4,4,14], "D": [30,17,17,17,17,17,30],
    "A": [14,17,17,31,17,17,17], "C": [15,16,16,16,16,16,15],
    "E": [31,16,16,30,16,16,31], "0": [14,17,19,21,25,17,14],
    "3": [30,1,1,14,1,1,30], "5": [31,16,16,30,1,1,30],
}

def box(x, y, w, h, ink):
    for row in pixels[y:y+h]:
        row[x:x+w] = bytes([ink]) * w

def tint(x, y, color):
    colors[(y//8)*40 + x//4] = 8 + color

# Cielo de medianoche con luna y estrellas fijas.
for i in range(39):
    x, y = (i*43+7)%160, 35+(i*23)%51
    pixels[y][x] = 3
    tint(x, y, 1)
for y in range(39, 58):
    for x in range(118, 130):
        if ((x-124)/6)**2 + ((y-48)/10)**2 < 1 and ((x-128)/6)**2 + ((y-45)/10)**2 >= 1:
            pixels[y][x] = 3
            tint(x, y, 7)

# Siluetas lejanas, luego fachadas con cornisas, antenas y ventanas.
for i in range(20):
    top = 78 + (i*13)%32
    box(i*8, top, 8, 144-top, 1)
for i,(x,w,top) in enumerate([(0,18,98),(21,14,86),(39,20,105),(62,16,74),
                                (82,24,98),(109,15,87),(128,16,103),(147,13,92)]):
    box(x,top,w,144-top,0)
    box(x,top,w,2,2)
    box(x+w//2,top-6,1,6,2)
    for y in range(top+6,140,8):
        for xx in range(x+2,x+w-1,4):
            lit = (xx//4 + y//8 + i)%4 != 0
            box(xx,y,2,3,3 if lit else 1)
            tint(xx,y,7 if i%3==0 else 3)
box(0,24,160,1,3)
for x in range(0,160,4):
    tint(x,24,3)

glyphs = []
indices = {}
def tile(rows):
    key = bytes(rows)
    if key not in indices:
        indices[key] = len(glyphs)
        glyphs.append(key)
    return indices[key]

screen = bytearray()
for cy in range(25):
    for cx in range(40):
        screen.append(tile(sum(pixels[y][cx*4+i] << (6-2*i) for i in range(4))
                           for y in range(cy*8, cy*8+8)))

def label(col, text, color):
    for pos, ch in enumerate(text):
        addr = 40 + col + pos
        screen[addr] = tile([v << 2 for v in letters[ch]] + [0])
        colors[addr] = color

for col, name, value in [(1,"PTS","000000"),(15,"VIDAS","03"),(26,"ACEITE","05")]:
    label(col,name,3)
    label(col+len(name)+1,value,1)
letters.update({
    "1":[4,12,4,4,4,4,14], "2":[14,17,1,2,4,8,31],
    "4":[2,6,10,18,31,2,2], "6":[6,8,16,30,17,17,14],
    "7":[31,1,2,4,8,8,8], "8":[14,17,17,14,17,17,14],
    "9":[14,17,17,15,1,2,12], "%":[17,2,4,8,16,17,0],
    "G":[14,17,16,23,17,17,14], "L":[16,16,16,16,16,16,31],
    "R":[30,17,17,30,20,18,17], " ":[0]*7})
def codes(text):
    return bytes(tile([v << 2 for v in letters[ch]]+[0]) for ch in text)
(out/"digits.bin").write_bytes(codes("0123456789"))
(out/"clear.bin").write_bytes(codes("STAGE CLEAR"))
screen[115]=codes("%")[0]
colors[112:116]=bytes([1])*4
(out/"road.bin").write_bytes(bytes([tile([255,170,85,0,0,0,0,0]),
                                    tile([255,255,170,0,0,0,0,0])]))
assert len(glyphs) <= 256 and len(colors) == len(screen) == 1000
(out/"charset.bin").write_bytes(b"".join(glyphs).ljust(2048,b"\0"))
(out/"scene.bin").write_bytes(screen+colors)
