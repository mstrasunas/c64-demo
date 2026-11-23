!zone sprite
; A = posición X en unidades de dos píxeles, X = índice de sprite (0..7).
; Y de hardware queda en 2*X para poder escribir $d001,Y.
position
 ; Incluir el margen VIC de 24 px antes de duplicar; el carry es el bit 8.
 clc
 adc #12
 asl
 sta tempByte
 lda #0
 rol
 sta carryX
 txa
 asl
 tay
 lda tempByte
 sta $d000,y
 lda $d010
 and clearBit,x
 pha
 lda carryX
 beq +
 pla
 ora bitMask,x
 pha
+ pla
 sta $d010
 rts
shipDraw
 ldx #0
 lda playerX
 jsr position
 lda fraction
 and #4
 beq +
 inc $d000
+ lda #224
 sta $d001
 lda frame
 lsr
 lsr
 and #3
 clc
 adc #82
 ldx velocity
 beq +
 adc #4
 cpx #128
 bcs +
 adc #4
+
 sta screen+1016
 lda #3
 sta $d027
 lda immune
 beq .show
 and #4
 beq .hide
.show lda $d015
 ora #1
 sta $d015
 rts
.hide lda $d015
 and #$fe
 sta $d015
 rts
