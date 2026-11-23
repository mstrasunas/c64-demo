#!/bin/sh
set -eu

cd -- "$(dirname -- "$0")"
assembler=${ACME:-acme}
if ! command -v "$assembler" >/dev/null 2>&1; then
    printf '%s\n' 'No se encontró ACME. Instalalo o indicá su ruta con ACME.' >&2
    exit 127
fi

"$assembler" --format cbm --outfile demo.prg demo.asm
printf '%s\n' 'Compilado: demo.prg'
