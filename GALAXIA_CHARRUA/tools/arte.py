"""Regenera las láminas originales. Sólo usa Python estándar; ACME incluye su salida."""
import math
from pathlib import Path
from random import Random
out = Path(__file__).resolve().parents[1] / 'src'
font = dict(zip("ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789/-.",
["0e11111f111111","1e11111e11111e","0f10101010100f","1e11111111111e","1f10101e10101f","1f10101e101010","0f10101311110f","1111111f111111","0e04040404040e","0702020212120c","11121418141211","1010101010101f","111b1515111111","11191915131311","0e11111111110e","1e11111e101010","0e11111115120d","1e11111e141211","0f10100e01011e","1f040404040404","1111111111110e","11111111110a04","11111115151b11","11110a040a1111","11110a04040404","1f01020408101f","0e11131519110e","040c040404040e","0e11010204081f","1e01010e01011e","02060a121f0202","1f10101e01011e","0e10101e11110e","1f010204080808","0e11110e11110e","0e11110f01010e","01020204080810","0000001f000000","00000000000c0c"]))
lower=dict(zip('acelnorstuz', ['00000e010f110f','00000e1010100e','00000e111f100e','0c04040404040e','00001e11111111','00000e1111110e','00001619101010','00000f100e011e','08081e08080906','0000111111130d','00001f0204081f']))
pixels=[[0]*320 for _ in range(200)]
def dot(x,y,c):
    if 0<=x<320 and 0<=y<200: pixels[y][x]=c
def line(x,y,w,c):
    for i in range(w): dot(x+i,y,c)
def label(s,y,c,x=None,sx=1,sy=1,logo=False):
    if x is None: x=(320-(6*len(s)-1)*sx)//2
    for i,ch in enumerate(s):
        bits=bytes.fromhex((lower|font).get(ch,'00'*7))
        for r,v in enumerate(bits):
            for k in range(5):
                if v & (16>>k):
                    for dy in range(sy):
                        yy=r*sy+dy
                        xx=x+(6*i+k)*sx+((7*sy-yy)//5 if logo else 0)
                        if logo and dy==sy-1 and r in (3,5): continue
                        line(xx,y+yy,sx,(1 if yy<8 else 3 if yy<16 else 14 if yy<24 else 14) if logo else c)
rng=Random(79)
for i in range(175):
    x,y=rng.randrange(320),rng.randrange(200)
    dot(x,y,rng.choice([11,12,14,6]))
    if i%19==0:
        line(x-1,y,3,12);dot(x,y-1,12);dot(x,y+1,12)
for x in (8,270): line(x,12,42,14)
label("ORBITA SUR   /   UY-64",9,3)
label("GALAXIA",26,1,sx=6,sy=4,logo=True)
label("CHARRUA",61,1,sx=6,sy=4,logo=True)
for i in range(5): line(228+i,60-i,6,1) # acento de la U
line(22,99,276,6);line(22,100,50,3)
label("HI-SCORE",111,14)
label("PRESS FIRE TO START",150,7,sx=2,sy=2)
line(50,174,220,6)
label("Marcelo Strasunas 11/2026",183,3)
# Reiniciar el cielo animado en bandas libres del bitmap.
for y in (19,94,140,195):
    for x in range(8,312): pixels[y][x]=0
bitmap=[]; ink=[]
for cy in range(25):
    for cx in range(40):
        tile=[pixels[cy*8+y][cx*8:cx*8+8] for y in range(8)]
        vals=[v for row in tile for v in row if v]
        color=max(set(vals),key=lambda v:(vals.count(v),v)) if vals else 14
        ink.append(color<<4)
        bitmap.extend(sum((1<<(7-x)) for x,v in enumerate(row) if v) for row in tile)
def save(name,data):
    (out/name).write_bytes(bytes(data))
save('titulo.map',ink);save('titulo.bin',bitmap)
# Sprites multicolor, 12 píxeles lógicos por 21 líneas, paleta compartida.
ship=['000001100000','000001100000','000012210000','000012210000','000123321000','001123321100','001123321100','031123321130','031222222130','031222222130','032233332230','132231132231','132210012231','122100001221','110300003011','000200002000']
craft=[['003000003000','000300030000','003322223300','032211112230','322111111223','003222222300','000310013000','003100001300'],['000003300000','000032230000','030322223030','032211112230','322211112223','032222222230','000320023000','003000000300'],['030000000030','003300003300','003233332300','032211112230','322222222223','300322223003','003200002300','032000000230']]
def pack(rows):
    data=[]
    for row in (rows+['0'*12]*21)[:21]:
        for i in (0,4,8):data.append(int(row[i:i+4],4))
    return data+[0]
sprites=[]
for flame in ('000300003000','000100001000'): sprites+=pack(ship+[flame])
for a in craft: sprites+=pack(a)
sprites+=pack(['100000000000']*5)
sprites+=pack(['200000000000','300000000000','200000000000','100000000000'])
for stage in range(3):
    rows=[]
    for y in range(17):
        row=''
        for x in range(12):
            d=math.hypot((x-5.5)*1.7,y-8)
            ray=(abs(y-8)<1.5 or abs(x-5.5)<1 or abs(abs(x-5.5)*1.6-abs(y-8))<1.6)
            row+=str((1 if stage==0 else 2 if stage==1 else 3) if ray and stage*2<=d<4+stage*3 else 0)
        rows.append(row)
    sprites+=pack(rows)
# Bandera de nueve franjas, cantón y Sol de Mayo; cuatro fases, dos sprites por fase.
for phase in range(4):
    flag=[['0']*24 for _ in range(21)]
    for x in range(24):
        wave=round(1.4*math.sin(x/5+phase*math.pi/2))
        for y in range(18):
            c='1' if y//2%2==0 else '2'
            if x<10 and y<10:
                c='1'
                dx,dy=x-4,y-4
                if dx*dx+dy*dy<7 or (dx==0 or dy==0 or abs(dx)==abs(dy)) and max(abs(dx),abs(dy))<=3:c='3'
            flag[2+y+wave][x]=c
    for a in (0,12): sprites+=pack([''.join(r[a:a+12]) for r in flag])
save('sprites.bin',sprites)
# Dos caracteres multicolor de ancho y dos de alto por enemigo.
tiles=[]
for a in craft:
    for half in (0,1):
        for col in (0,1):
            for yy in range(8):
                row=a[(half*8+yy)//2][2:10]
                tiles.append(int(row[col*4:col*4+4],4))
save('enemigos.bin',tiles)
