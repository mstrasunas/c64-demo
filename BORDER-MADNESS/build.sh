#!/usr/bin/env bash
set -eu
cd "$(dirname "$0")"
jar=${KICKASS_JAR:-KickAss.jar}
temp=$(mktemp -d)
trap 'rm -rf "$temp"' EXIT
java -jar "$jar" main.asm -odir "$temp" -o "$temp/demo.prg" -symbolfile
python3 - "$temp" <<'PY'
from pathlib import Path
import re,struct,sys
d=Path(sys.argv[1])
symbols=(d/'main.sym').read_text()
def address(name):
    return int(re.search(r'\.label '+name+r'=\$([0-9a-fA-F]+)',symbols)[1],16)
prg=(d/'demo.prg').read_bytes()
origin=int.from_bytes(prg[:2],'little')
start=0xc000
end=address('musicEnd')
def field(s): return s.encode('ascii').ljust(32,b'\0')
hdr=struct.pack('>4s7HI',b'PSID',2,124,0,start,start+3,1,1,0)
hdr+=field('Undercurrent')+field('Full Border Madness')+field('2026')+struct.pack('>H4B',0x34,0,0,0,0)
Path('music.sid').write_bytes(hdr+struct.pack('<H',start)+prg[2+start-origin:2+end-origin])

PY
python3 pack.py "$temp/demo.prg" "$temp"
cp loader.asm "$temp/"
java -jar "$jar" "$temp/loader.asm" -odir "$temp" -o "$temp/packed.prg"
cp "$temp/packed.prg" demo.prg
