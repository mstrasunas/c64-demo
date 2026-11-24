raster
 pha
 lda #1
 sta $d019
 jsr publish
 lda pal
 bne irqTick
 inc phase
 lda phase
 cmp #6
 bne irqTick
 lda #0
 sta phase
 beq irqExit
irqTick
 lda #1
 sta pending
irqExit
 pla
nmi
 rti
pending !byte 0
phase !byte 0
pal !byte 0
