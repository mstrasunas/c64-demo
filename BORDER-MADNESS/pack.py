"""Encode the high-memory payload in reverse order for in-place 6510 loading."""
from pathlib import Path
import sys

raw = Path(sys.argv[1]).read_bytes()
base = int.from_bytes(raw[:2], "little")
source = raw[2 + 0x1000 - base:][::-1]
tokens = bytearray()
pending = bytearray()
last = {}

def flush():
    if pending:
        tokens.append(len(pending) - 1)
        tokens.extend(pending)
        pending.clear()

pos = 0
while pos < len(source):
    key = source[pos:pos + 3]
    prev = last.get(key)
    count = 0
    if prev is not None:
        limit = min(130, len(source) - pos)
        while count < limit and source[prev + count] == source[pos + count]:
            count += 1
    if count >= 4:
        flush()
        tokens.append(128 + count - 3)
        tokens.extend((pos - prev).to_bytes(2, "little"))
    else:
        count = 1
        pending.append(source[pos])
        if len(pending) == 128:
            flush()
    for i in range(pos, pos + count):
        last[source[i:i + 3]] = i
    pos += count
flush()
directory = Path(sys.argv[2])
(directory / "payload.bin").write_bytes(tokens[::-1])
(directory / "end.asm").write_text(f".const endAddress=${0xfff + len(source):04x}\n")
