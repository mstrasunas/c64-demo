"""Boot a D64 in PAL and NTSC VICE, press fire and check memory at milestones."""
from pathlib import Path
import os
import re
import subprocess
import tempfile

root = Path(__file__).resolve().parents[1]
symbols = dict(re.findall(r'^\s*(\w+)\s*= \$([\da-f]+)',
                          (root / 'symbols.txt').read_text(), re.M))

def verify(model, folder):
    commands = folder / 'test.mon'
    active, collision, over = (folder / n for n in ('active.bin','contact.bin','over.bin'))
    commands.write_text(f'''delete 1
> dc00 00
> dc02 10
until {symbols["beginPlay"]}
> dc02 00
until {symbols["playTick"]}
bsave "{active}" 0 0000 ffff
until {symbols["fatal"]}
bsave "{collision}" 0 0000 ffff
until {symbols["gameOver"]}
until {symbols["menuTick"]}
bsave "{over}" 0 0000 ffff
quit
''')
    # Pull CIA port A bit 4 low for the fire press, then release it.
    subprocess.run([os.environ.get('X64SC','x64sc'), '-console', '-'+model,
                    '-warp','-sounddev','dummy','+confirmonexit','+drive8truedrive',
                    '-initbreak','0x'+symbols['mainLoop'],'-moncommands',str(commands),
                    '-limitcycles','160000000',str(root/'pacman.d64')],check=True,timeout=90)
    def byte(dump,key):return dump.read_bytes()[int(symbols[key],16)]
    assert byte(active,'pal') == (model=='pal')
    assert byte(active,'state')==2 and byte(active,'lives')==3
    assert byte(collision,'remaining')<218
    assert byte(over,'state')==4 and byte(over,'lives')==0
    print(model.upper(), 'OK')

for standard in ('pal','ntsc'):
    with tempfile.TemporaryDirectory() as directory:
        verify(standard,Path(directory))
