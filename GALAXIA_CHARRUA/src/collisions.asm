!zone hits
; Coordenadas lógicas semi-X e Y de raster; bordes incluyen el largo del disparo.
hits
 ldy #2
.ray sty shotSlot
 lda shotY,y
 bne +
 jmp .nextRay
+ clc
 adc #4
 sta rayBottom
 lda #1
 sta beam
.tryBeam lda beam
 and shotMask,y
 beq .nextBeam
 lda shotX,y
 ldx beam
 cpx #2
 bne +
 clc
 adc #8
+ sta rayX
 ; Un atacante libre puede cruzar cualquier carril.
 ldx diver
 cpx #$ff
 beq .formation
 sec
 sbc diveX
 cmp #8
 bcs .formation
 lda rayBottom
 sec
 sbc diveY
 cmp #20
 bcs .formation
 lda diveX
 sta targetX
 lda diveY
 sta targetY
 jmp .hit
.formation
 ; En cada fila sólo una de las ocho columnas puede cortar este rayo.
 lda scrollX
 lsr
 sta tempByte
 lda rayX
 sec
 sbc tempByte
 cmp #128
 bcs .nextBeam
 tay
 and #15
 cmp #8
 bcs .nextBeam
 tya
 lsr
 lsr
 lsr
 lsr
 ora #16
 tax
.row lda alive,x
 beq .above
 cpx diver
 beq .above
 lda rayBottom
 sec
 sbc homeY,x
 cmp #20
 bcs .above
 jsr homeXY
 jmp .hit
.above txa
 sec
 sbc #8
 tax
 bpl .row
.nextBeam ldy shotSlot
 lda beam
 cmp #2
 beq .nextRay
 asl
 sta beam
 jmp .tryBeam
.nextRay ldy shotSlot
 dey
 bmi +
 jmp .ray
+
 jmp .player
.hit stx victim
 lda #0
 sta alive,x
 dec remaining
 ldy shotSlot
 lda shotMask,y
 eor beam
 sta shotMask,y
 beq .spent
 tax
 lda beamShape,x
 ldx shotSprite,y
 sta screen+1016,x
 jmp .burst
.spent jsr dropShot
.burst jsr flagDrop
 jsr explosion
 ldx victim
 jsr scoreKill
 ldx victim
 cpx diver
 bne +
 jsr endDive
 jmp .sound
+ jsr eraseSlot
.sound ldx victim
 jsr killSound
 jmp .nextBeam
.player lda immune
 bne .done
 lda bombY
 cmp #219
 bcc .ram
 cmp #241
 bcs .ram
 lda bombX
 sec
 sbc playerX
 cmp #12
 bcs .ram
 jsr clearBomb
 jmp loseLife
.ram lda diver
 cmp #$ff
 beq .done
 lda diveY
 cmp #217
 bcc .done
 cmp #240
 bcs .done
 lda diveX
 sec
 sbc playerX
 clc
 adc #9
 cmp #20
 bcs .done
 ldx diver
 jsr endDive
 jsr paintSlot
 jmp loseLife
.done rts
explosion
 lda #16
 sta blastTime
 ldx #4
 lda targetX
 jsr position
 lda targetY
 sta $d009
 lda #7
 sta $d02b
 lda #112
 sta screen+1020
 lda $d015
 ora #16
 sta $d015
 rts
!zone blast
blastTick
 lda blastTime
 beq .done
 dec blastTime
 beq .off
 lda blastTime
 lsr
 sta tempByte
 lda #119
 sec
 sbc tempByte
 sta screen+1020
.done rts
.off lda $d015
 and #$ef
 sta $d015
 rts
!zone life
loseLife
 dec lives
 lda playerX
 sta targetX
 lda #224
 sta targetY
 jsr explosion
 jsr deathSound
 lda #90
 sta immune
 lda #0
 sta velocity
 sta fraction
 lda #74
 sta playerX
 jsr hud
 lda lives
 beq +
 jmp lifeNotice
+ jmp gameOver
