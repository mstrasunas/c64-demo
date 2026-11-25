#!/bin/sh
set -eu
cd "$(dirname "$0")"
mkdir -p build
python3 tools/scene.py
python3 tools/car.py
acme -f cbm -o build/v02.tmp -l build/v02.sym src/main.asm
mv build/v02.tmp cityconnection_v02.prg
