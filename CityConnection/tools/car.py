"""Cada columna representa dos píxeles VIC. El frontal mira a la derecha."""
from pathlib import Path

shape = [
    "............",
    "............",
    "............",
    "...rrrr.....",
    "..rccrcr....",
    "..rccrccr...",
    ".rcccrcccr..",
    "rrrrrrrrrrr.",
    "rrrrrrrrrrrr",
    "wwrrrrrrrwww",
    "rrrrrwrrrrrw",
    "rrrrrrrrrrrr",
    "r...rrrr...r",
    ".www.rr.www.",
    ".wcw....wcw.",
    ".www....www.",
    "..w......w..",
    "............",
    "............",
    "............",
    "............",
]
# . transparente / c cian compartido / r rojo propio / w blanco compartido
inks = ".crw"
data = bytearray()
for left in (False, True):
    for phase in (0, 1):
        rows = shape.copy()
        if phase:
            rows[13:16] = [".wcw.rr.wcw.", ".cwc....cwc.", ".wcw....wcw."]
        for row in rows:
            assert len(row) == 12
            row = row[::-1] if left else row
            for x in range(0,12,4):
                data.append(sum(inks.index(row[x+i]) << (6-i*2) for i in range(4)))
        data.append(0)
assert len(data) == 4*64
Path("build/car.bin").write_bytes(data)

# Patrulla con baliza, gato sentado, lata y destello del accidente.
police = shape.copy()
police[2] = "....wrc....."
police[9] = "wwrrwwwwrwww"
cat = ["............"]*6 + ["....r..r....","....rrrr....","....wrrw....",".....rr.....","....rrrr...r","....rrrr..rr","...rrrrrrrr.","...rwwrrww.."]
can = ["............"]*7 + ["....wwww....","....wrrw....","....rccr....","....rccr....","....wrrw....","....wwww...."]
burst = ["............","..r.....w...","...w.r.w....","r...wcw....r",".wwrcccrww..","..rccwccr...","...wcwcw....","..w.r.r.w...","....r...r..."]
assets = bytearray()
for rows in (police, [r[::-1] for r in police], cat, can, burst):
    for row in rows + ["............"]*(21-len(rows)):
        for x in (0,4,8):
            assets.append(sum(inks.index(row[x+j]) << (6-2*j) for j in range(4)))
    assets.append(0)
Path("build/actors.bin").write_bytes(assets)
