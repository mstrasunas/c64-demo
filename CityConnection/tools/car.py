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
