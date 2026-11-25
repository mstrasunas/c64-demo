#!/bin/sh
set -eu
cd "$(dirname "$0")"
mkdir -p build
python3 tools/scene.py
acme -f cbm -o build/v01.tmp -l build/v01.sym src/main.asm
mv build/v01.tmp cityconnection_v01.prg
