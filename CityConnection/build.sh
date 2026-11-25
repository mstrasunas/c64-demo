#!/bin/sh
set -eu
cd "$(dirname "$0")"
mkdir -p build
python3 tools/scene.py
python3 tools/car.py
acme -f cbm -o build/v03.tmp -l build/v03.sym src/main.asm
mv build/v03.tmp cityconnection_v03.prg
