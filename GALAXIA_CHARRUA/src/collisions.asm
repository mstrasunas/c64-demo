!zone hits
; Coordenadas lógicas semi-X e Y de raster; bordes incluyen el largo del disparo.
hits
 ldy #2
.ray sty shotSlot
 lda shotY,y
 beq .nextRay
 clc
 adc #4
 sta rayBottom
 lda shotX,y
 sta rayX
 ldx #23
.search lda alive,x
 beq .next
 cpx diver
 beq .diving
 ; Descartar primero por fila sin calcular las 24 posiciones completas.
 lda rayBottom
 sec
 sbc homeY,x
 cmp #20
 bcs .next
 jsr homeXY
 jmp .checkX
.diving lda rayBottom
 sec
 sbc diveY
 cmp #20
 bcs .next
 lda diveX
 sta targetX
 lda diveY
 sta targetY
.checkX lda rayX
 sec
 sbc targetX
 cmp #8
 bcc .hit
.next dex
 bpl .search
.nextRay ldy shotSlot
 dey
 bpl .ray
 jmp .player
.hit stx victim
 lda #0
 sta alive,x
 dec remaining
 jsr dropShot
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
 jmp .nextRay
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
 bne .done
 jmp gameOver
.done rts
