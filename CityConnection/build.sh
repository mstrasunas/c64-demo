#!/bin/sh
set -eu
cd "$(dirname "$0")"
mkdir -p build
python3 tools/scene.py
python3 tools/car.py
acme -f cbm -o build/v04.tmp -l build/v04.sym src/main.asm
mv build/v04.tmp cityconnection_v04.prg
