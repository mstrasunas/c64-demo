"""Generate original VIC-II tiles, hardware sprite frames and maze tables."""
from pathlib import Path
from collections import deque
M = [
"#############################",
"#o...........###...........o#",
"#.###.######.###.######.###.#",
"#.###.######.###.######.###.#",
"#...........................#",
"#.###.##.###########.##.###.#",
"#.....##.....###.....##.....#",
"#####.#####. ### .#####.#####",
"    #.##             ##.#    ",
"#####.## ###     ### ##.#####",
"     .   #         #   .     ",
"#####.## ########### ##.#####",
"    #.##             ##.#    ",
"#####.##.###########.##.#####",
"#............###............#",
"#.###.######.###.######.###.#",
"#o..#........ ..........#..o#",
"###.#.##.###########.##.#.###",
"#.....##.....###.....##.....#",
"#.##########.###.##########.#",
"#...........................#",
"#############################"]
M[9]=M[9][:12]+'##=##'+M[9][17:]
# Empty exterior pockets are solid. The centre aisle is the ghost home.
M=[list(r) for r in M]
for y in (8,12):
    for x in (*range(4),*range(25,29)): M[y][x]='X'
assert all(len(r)==29 for r in M)
W,H=29,len(M)
def emit(rows):return ''.join('!byte '+','.join(map(str,r))+'\n' for r in rows)
def solid(x,y):return 0<=x<W and 0<=y<H and M[y][x] in '#X'
def nb(x,y,d):
    a,b=((0,-1),(-1,0),(0,1),(1,0))[d]
    return ((x+a)%W,y+b)
# Screen codes 0..63 are printable ASCII minus 32.
font={'A':'0e11111f111111','B':'1e11111e11111e','C':'0f10101010100f','D':'1e11111111111e','E':'1f10101e10101f','F':'1f10101e101010','G':'0f10101311110f','H':'1111111f111111','I':'1f04040404041f','J':'0702020212120c','K':'11121418141211','L':'1010101010101f','M':'111b1515111111','N':'11191915131311','O':'0e11111111110e','P':'1e11111e101010','Q':'0e11111115120d','R':'1e11111e141211','S':'0f10100e01011e','T':'1f040404040404','U':'1111111111110e','V':'11111111110a04','W':'11111115151b11','X':'11110a040a1111','Y':'11110a04040404','Z':'1f01020408101f','0':'0e11131519110e','1':'040c040404040e','2':'0e11010204081f','3':'1e01010e01011e','4':'02060a121f0202','5':'1f10101e01011e','6':'0e10101e11110e','7':'1f010204080808','8':'0e11110e11110e','9':'0e11110f01010e','-':'0000001e000000'}
tiles=[[0]*8 for _ in range(67)]
for c,s in font.items():tiles[ord(c)-32]=[v<<2 for v in bytes.fromhex(s)]+[0]
tiles[63]=[0,0,0,255,255,0,0,0]
tiles[64]=[0,0,0,24,24,0,0,0]
tiles[65]=[0,24,60,126,126,60,24,0]
rows=[]; homes=[];seen={(14,10):0};q=deque(seen)
while q:
    p=q.popleft()
    for d in range(4):
        x,y=nb(*p,d)
        if 0<=y<H and not solid(x,y) and (x,y) not in seen:
            seen[x,y]=d^2;q.append((x,y))
for y,row in enumerate(M):
    line=[]
    for x,c in enumerate(row):
        if c in '.o ':assert (x,y) in seen,(x,y)
        if c=='#':
            # Rounded borders follow exposed faces, including concave corners.
            grid=[[0]*8 for _ in range(8)]
            for ax,ay in [(-1,-1),(1,-1),(-1,1),(1,1)]:
                a=not solid(x+ax,y); b=not solid(x,y+ay)
                for i in range(4):
                    for j in range(4):
                        ink=((i,j) in [(1,3),(1,2),(2,1),(3,1)] if a and b else
                             (a and i==1) or (b and j==1) or
                             (not a and not b and not solid(x+ax,y+ay) and i==j==0))
                        if ink:grid[j if ay<0 else 7-j][i if ax<0 else 7-i]=1
            tile=[sum(v<<(7-i) for i,v in enumerate(r)) for r in grid]
            if tile not in tiles[67:]:tiles.append(tile)
            k=tiles.index(tile,67)
        else:k={'=':63,'X':66,'.':64,'o':65,' ':0}[c]
        line.append(k)
    rows.append(line);homes.append([seen.get((x,y),0) for x in range(W)])
Path('charset.asm').write_text(emit(tiles))
Path('board.inc').write_text('pellets = '+str(sum(c in '.o' for r in M for c in r))+'\nboard\n'+emit(rows)+'homeDirections\n'+emit(homes))
from math import atan2,pi
frames=[]
def sprite(fn,multi=False):
    raw=[]
    for y in range(21):
        v=0
        for x in range(12 if multi else 24):v=(v<<(2 if multi else 1))|int(fn(x,y))
        raw+=list(v.to_bytes(3,'big'))
    frames.append(raw+[0])
for angle in [-pi/2,pi,pi/2,0]:
    for gape in [0,.39,.82,.39]:
        sprite(lambda x,y:(x-5.5)**2+(y-5.5)**2<=36 and abs((atan2(y-5.5,x-5.5)-angle+pi)%(2*pi)-pi)>=gape)
for mode in range(3):
    for d in range(4):
        for step in range(2):
            def ghost(x,y):
                if x>=7 or y>=13:return 0
                if mode!=1 and x in (1,2,4,5) and 3<=y<=6:
                    pupilx=(1 if x<3 else 4)+(d==3)
                    return 3 if x==pupilx and y in (4+(d==2)-(d==0),5+(d==2)-(d==0)) else 1
                if mode==2:return 0
                if y<3 and (x in (0,6) or (y==0 and x in (1,5))):return 0
                if y>10 and (x+step)%3==0:return 0
                if mode==1 and ((x in (2,4) and y==4) or (1<=x<=5 and y==8+x%2)):return 1
                return 2
            sprite(ghost,True)
for phase in range(8):
    sprite(lambda x,y:(x-5.5)**2+(y-5.5)**2<36 and abs((atan2(y-5.5,x-5.5)+1.5*pi)%(2*pi)-pi)>phase*.44)
def cherry(x,y):
    if (x,y) in [(4,0),(4,1),(3,2),(2,3),(5,2),(5,3),(5,4)]:return 3
    if (x,y) in [(1,5),(4,7)]:return 1
    return 2 if ((x-1.8)*2)**2+(y-7)**2<12 or ((x-4.8)*2)**2+(y-9)**2<12 else 0
sprite(cherry,True)
def berry(x,y):
    if y in (1,2) and 1<=x<=5:return 1 if (x+y)%2 else 2
    if 3<=y<=12 and abs(x-3)<=min(3,(13-y)//2):
        return 1 if (x*3+y)%7==0 else 2
    return 0
def orange(x,y):
    if y<=2 and 3<=x<=4:return 1
    if ((x-3)*2)**2+(y-7)**2<31:return 1 if x==2 and y in (4,5) else 2
    return 0
sprite(berry,True)
sprite(orange,True)
Path('sprites.asm').write_text(emit(frames))
assert len(tiles)<=127
with Path('charset.asm').open('a') as f:
    f.write('!fill '+str((127-len(tiles))*8)+'\n'+emit([[126,255,255,255,255,255,255,126]]))
