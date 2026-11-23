screen=$4400
chars=$4800
spriteMem=$5000
bitmap=$6000
ptr=$fb
colptr=$fd
!zone video
initVic
 lda $dd02
 ora #3
 sta $dd02
 lda $dd00
 and #$fc
 ora #2
 sta $dd00
 lda #0
 sta $d020
 sta $d021
 sta $d015
 sta $d010
 sta $d017
 sta $d01b
 sta $d01d
 lda #$ff
 sta $d01c
 lda #1
 sta $d025
 lda #3
 sta $d026
 ; Leer caracteres de la ROM, escribiendo en RAM del banco VIC 1.
 lda #$33
 sta $01
 ldx #0
- !for p,0,7 { lda $d000+p*256,x : sta chars+p*256,x }
 inx
 bne -
 lda #$37
 sta $01
 ldx #95
- lda enemyTiles,x
 sta chars+128*8,x
 dex
 bpl -
 rts
title
 lda #0
 sta noteTime
 sta songPos
 sta mode
 lda #$18
 sta $d018
 lda #$3b
 sta $d011
 lda #8
 sta $d016
 ldx #0
- !for p,0,2 { lda titleInk+p*256,x : sta screen+p*256,x }
 lda titleInk+744,x
 sta screen+744,x
 inx
 bne -
 lda #%01100000
 sta $d017
 lda #0
 sta $d01d
 lda #1
 sta $d025
 lda #14
 sta $d02c
 sta $d02d
 lda #7
 sta $d026
 lda #3
 sta $d027
 lda #59
 sta $d00a
 lda #83
 sta $d00c
 lda #150
 sta $d00b
 sta $d00d
 lda #163
 sta $d001
 lda #$61
 sta $d015
 ldx #5
 lda #$10
- sta screen+15*40+17,x
 dex
 bpl -
 jsr titleScore
 rts
titleAnim
 lda frame
 lsr
 lsr
 lsr
 and #3
 asl
 clc
 adc #74
 sta screen+1021
 clc
 adc #1
 sta screen+1022
 lda frame
 lsr
 lsr
 and #3
 clc
 adc #82
 sta screen+1016
 lda frame
 lsr
 and #63
 tax
 lda bob,x
 clc
 adc #19
 sta $d000
 lda #1
 sta $d010
 ; Cuatro líneas de bitmap reservadas a las estrellas móviles.
 lda frame
 and #3
 bne .done
 ldx starPhase
 lda #0
 jsr titleBands
 txa
 clc
 adc #8
 and #248
 tax
 stx starPhase
 lda #$44
 jsr titleBands
.done rts
titleBands
 sta bitmap+2*320+3,x
 sta bitmap+11*320+6+56,x
 sta bitmap+17*320+4,x
 sta bitmap+24*320+3+32,x
 rts
titleScore
 ldx #0
.loop
 lda high,x
 lsr
 lsr
 lsr
 lsr
 jsr .digit
 lda high,x
 and #15
 jsr .digit
 inx
 cpx #3
 bne .loop
 lda #0
 sta digitPos
 rts
.digit
 asl
 asl
 asl
 tay
 stx savedX
 ldx digitPos
 !for i,0,7 { lda chars+48*8+i,y : sta bitmap+15*320+17*8+i,x }
 txa
 clc
 adc #8
 sta digitPos
 ldx savedX
 rts
playVideo
 lda #0
 sta $d015
 sta $d01d
 sta $d017
 sta $d010
 lda #$1b
 sta $d011
 lda #$12
 sta $d018
 lda #$18
 sta $d016
 lda #14
 sta $d022
 lda #1
 sta $d023
 sta $d025
 lda #14
 sta $d026
 ldx #0
- lda #32
 !for p,0,2 { sta screen+p*256,x }
 sta screen+744,x
 lda #3
 !for p,0,2 { sta $d800+p*256,x }
 sta $d800+744,x
 inx
 bne -
 ldx #0
- lda starLo,x
 sta ptr
 lda starHi,x
 sta ptr+1
 clc
 adc #$94
 sta colptr+1
 lda ptr
 sta colptr
 ldy #0
 txa
 and #3
 ora #144
 sta (ptr),y
 txa
 and #3
 tay
 lda starColors,y
 ldy #0
 sta (colptr),y
 inx
 cpx #starCount
 bne -
 ldx #39
- lda #148
 sta screen+80,x
 lda #6
 sta $d800+80,x
 dex
 bpl -
 ldx #7
 lda #0
- sta chars+148*8,x
 dex
 bpl -
 lda #$ff
 sta chars+148*8+4
 rts
stars
 lda frame
 and #3
 bne .skip
 lda frame
 lsr
 lsr
 and #7
 tax
 lda #0
 ldy #31
- sta chars+144*8,y
 dey
 bpl -
 lda #8
 sta chars+144*8,x
 lda #$10
 sta chars+146*8,x
 txa
 eor #7
 tax
 lda #$40
 sta chars+145*8,x
 lda #2
 sta chars+147*8,x
.skip rts
