ACME ?= acme
C1541 ?= c1541

all: pacman.prg

pacman.prg: $(wildcard *.asm) board.inc
	$(ACME) -f cbm -o $@ -l symbols.txt main.asm

disk: pacman.d64

pacman.d64: pacman.prg
	$(C1541) -format "maze run,89" d64 $@ -write $< pacman

graphics:
	python3 graphics.py

.PHONY: all disk graphics
