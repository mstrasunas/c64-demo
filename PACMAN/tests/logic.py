import re,sys,collections,os
from pathlib import Path
from py65.devices.mpu6502 import MPU
os.chdir(Path(__file__).resolve().parents[1])
S={k:int(v,16) for k,v in re.findall(r'^\s*(\w+)\s*= \$([\da-f]+)',Path('symbols.txt').read_text(),re.M)}
m=MPU();ram=m.memory
prg=Path('pacman.prg').read_bytes();ram[2049:2049+len(prg)-2]=prg[2:]
def run(label,limit=100000):
 for _ in range(limit):
    if m.pc==S[label]:return
    m.step()
 raise Exception(label,hex(m.pc))
def call(label):
 m.stPushWord(0x02ef);m.pc=S[label]
 while m.pc!=0x02f0:m.step()
def v(n,i=0):return ram[S[n]+i]
def put(n,a,i=0):ram[S[n]+i]=a
def frame(joy=255):
 m.pc=S['mainLoop'];ram[0xdc00]=joy;put('pending',1);m.step();run('mainLoop')
m.pc=S['start'];run('mainLoop')
assert v('state')==0 and ram[0xd015]==31
frame(239);assert v('lives')==3 and v('state')==1
for _ in range(75):frame()
assert v('state')==2
dirs=[(0,-1),(-1,0),(0,1),(1,0)];keys=[254,251,253,247]
def cell(x,y):return ram[1024+125+y*40+x]
def edges(p):
 for d,(a,b) in enumerate(dirs):
    x=(p[0]+a)%29;y=p[1]+b
    if 0<=y<22 and cell(x,y)<66 and cell(x,y)!=63:yield (x,y),d
def path(p,test):
 q=collections.deque([(p,[])]);seen={p}
 while q:
    p,h=q.popleft()
    if test(*p):return h
    for n,d in edges(p):
        if n not in seen:q.append((n,h+[d]));seen.add(n)
 raise ValueError('no path')
# Held turn against a wall, and buffered turn during the preceding tile.
put('px',8);put('py',8);put('dirs',0);put('want',0);call('movePlayer');assert v('py')==8
put('px',38);put('py',8);put('dirs',3);put('want',2)
for _ in range(3):call('movePlayer')
assert (v('px'),v('py'))==(40,9)
# Cross both seams and check the hardware ninth bit is cleared on return.
put('px',224);put('py',80);put('dirs',3);put('want',3);call('render');call('publish');assert ram[0xd010]&1
for _ in range(8):call('movePlayer')
assert v('px')==0
call('render');call('publish');assert not ram[0xd010]&1
put('want',1)
for _ in range(8):call('movePlayer')
assert v('px')==224
# Each pellet reached by physical one-pixel movement.
while v('state')==2:
 route=path((v('px')//8,v('py')//8),lambda x,y:cell(x,y) in (64,65))
 assert route
 for d in route:
    put('want',d)
    for _ in range(8):call('movePlayer')
assert v('remaining')==0 and v('state')==5
assert sum(v('score',i)*10**(5-i) for i in range(6))==(218-4)*10+4*50
for _ in range(90):frame()
assert v('level')==2 and v('remaining')==218
for _ in range(75):frame()
# Independent ghost navigation over 4000 ticks.
for t in range(4000):
 if t%250==0:
    x,y=[(1,1),(27,20),(5,10),(23,4)][(t//250)%4];put('px',x*8);put('py',y*8)
 call('moveGhosts');call('clocks')
 for i in range(1,5):
    x=v('px',i);y=v('py',i)
    assert x%8==0 or y%8==0
    assert cell(x//8,y//8)<66,(i,t,x,y)
# Returning eyes must recover from each corner.
for i in range(1,5):
 put('eaten',1,i);put('px',8,i);put('py',8,i);put('release',0,i)
for _ in range(400):call('moveGhosts')
assert all(v('eaten',i)==0 for i in range(1,5))
for life in (3,2,1):
 put('frightened',0);put('px',v('px'),1);put('py',v('py'),1);put('release',0,1);call('contacts')
 assert v('state')==3
 for _ in range(64):frame()
 assert v('lives')==life-1
 if life>1:
    for _ in range(75):frame()
assert v('state')==4
frame(239);assert v('level')==1 and v('lives')==3 and any(v('high',i) for i in range(6))
print('PASS: title, fire, READY, wall, buffered turn, tunnels, X MSB, all 218 pellets, score, level, 4000 ghost ticks, eaten routes, deaths, restart, high score')

# Four captures on one energizer, with no double scoring on returning eyes.
for _ in range(75):frame()
def total():return sum(v('score',i)*10**(5-i) for i in range(6))
put('frightened',100);put('chain',0)
for i in range(1,5):
 put('px',v('px'),i);put('py',v('py'),i);put('release',0,i);put('eaten',0,i)
before=total();call('contacts');call('contacts')
assert total()-before==3000 and all(v('eaten',i) for i in range(1,5))
# Three fruit styles and score values. Coordinates remain centred on the aisle.
put('px',112);put('py',96)
for kind,value in enumerate((100,300,500)):
 put('fruitKind',kind);put('fruitTime',100);before=total();call('contacts')
 assert total()-before==value and v('fruitTime')==0
# Validate chase targets and the retreat threshold with known actor positions.
put('px',80);put('py',80);put('dirs',3);put('px',64,1);put('py',48,1)
put('scatter',0);put('frightened',0)
for i,expected in enumerate(((10,10),(14,10),(16,14),(10,10)),1):
 ram[2]=1;ram[3]=1;m.x=i;call('target')
 assert (ram[7],ram[8])==expected
ram[2]=10;ram[3]=11;m.x=4;call('target');assert (ram[7],ram[8])==(1,20)
# The door admits the departing ghosts and blocks the player.
put('px',112);put('py',64);put('dirs',2);put('want',2);call('movePlayer')
assert v('py')==64
print('PASS: capture chain, fruit values, four chase targets, Clyde retreat, pen door')
