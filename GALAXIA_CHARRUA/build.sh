#!/bin/sh
set -eu
cd "$(dirname "$0")"
"${ACME:-acme}" -f cbm -o GALAXIA_CHARRUA.PRG "$@" src/main.asm
