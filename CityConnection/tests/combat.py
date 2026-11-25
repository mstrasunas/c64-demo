"""Run after ./build.sh with py65 installed. Replay active-low port 2 samples."""
import re
from pathlib import Path
from py65.devices.mpu6502 import MPU

root = Path(__file__).resolve().parents[1]
symbols = dict((name, int(value, 16)) for name, value in re.findall(
    r'^\s*(\w+)\s*= \$(\w+)', (root / 'build/v04.sym').read_text(), re.M))
cpu = MPU()
ram = cpu.memory
prg = (root / 'cityconnection_v04.prg').read_bytes()
base = int.from_bytes(prg[:2], 'little')
ram[base:base+len(prg)-2] = prg[2:]
cpu.pc = symbols['start']
# Raster timing is covered separately in x64sc.
ram[symbols['wait_frame']] = 0x60
ram[0xd012] = 81

def frame(sample):
    ram[0xdc00] = sample
    cpu.step()
    while cpu.pc != symbols['frame']:
        cpu.step()

def word(address):
    return ram[address] + 256 * ram[address+1]

frame(255)
samples = (root / 'tests/combat.joy').read_bytes()
previous = word(symbols['remaining'])
sprite_x = set()
events=set()
for sample in samples[:-2]:
    frame(sample)
    if ram[symbols["crash"]]: events.add("accidente")
    if ram[symbols["score_hundreds"]]: events.add("policía eliminado")
    if ram[symbols["ammo"]] > 5: events.add("lata")
    remaining = word(symbols['remaining'])
    assert previous - remaining in (0, 1)
    previous = remaining
    camera = word(symbols['camera'])
    x = ram[0xd000] + 256 * (ram[0xd010] & 1)
    assert x == word(symbols['player_x']) - camera + 24
    sprite_x.add(x)
    bank = 0x4000 if ram[symbols['active_page']] == 2 else 0x4400
    for row in range(4, 25):
        dest = bank + row*40
        source = symbols['world'] + row*160 + (camera+7)//8
        assert ram[dest:dest+40] == ram[source:source+40]
assert len(events) == 3
assert previous == 0 and {255, 256} <= sprite_x
assert ram[0x4451:0x445c] == list((root / 'build/clear.bin').read_bytes())
frame(samples[-2])
assert word(symbols['remaining']) == 552
print('Manhattan: 552 segmentos, STAGE CLEAR y reinicio verificados.')

# Situaciones de contacto controladas sobre el mismo PRG.
def set_actor(slot, x, y):
    ram[symbols['ax']+slot] = x & 255
    ram[symbols['ah']+slot] = x >> 8
    ram[symbols['ay']+slot] = y
    ram[symbols['active']+slot] = 1

for life in (2, 1, 0):
    frame(255)
    set_actor(3, word(symbols['player_x']), ram[symbols['player_y']])
    ram[symbols['cat_clock']] = 2
    frame(239)  # fire contra el gato
    assert ram[symbols['active']+3] and ram[symbols['active']+4] and ram[symbols['crash']]
    assert ram[symbols['lives']] == life
    for _ in range(32):
        frame(255)
    if life:
        set_actor(3, word(symbols['player_x']), ram[symbols['player_y']])
        frame(255)
        assert ram[symbols['lives']] == life and ram[symbols['shield']]
        ram[symbols['shield']] = 0
assert ram[0x4451:0x445a] == list((root/'build/over.bin').read_bytes())
frame(239)
assert ram[symbols['lives']] == 3 and word(symbols['remaining']) == 552
print('GAME OVER, inmunidad y reinicio verificados.')
