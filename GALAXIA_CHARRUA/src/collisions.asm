!zone hits
; Coordenadas lógicas semi-X e Y de raster; bordes incluyen el largo del disparo.
hits
 lda shotY
 bne +
 jmp .player
+
 ldx #23
.search lda alive,x
 beq .next
 cpx diver
 bne .rank
 lda diveX
 sta targetX
 lda diveY
 sta targetY
 lda #16
 sta height
 lda #8
 sta width
 bne .check
.rank jsr homeXY
 lda #16
 sta height
 lda #8
 sta width
.check lda shotX
 sec
 sbc targetX
 cmp width
 bcs .next
 lda shotY
 clc
 adc #4
 sec
 sbc targetY
 cmp height
 bcc .hit
 sbc height
 cmp #4
 bcc .hit
.next dex
 bpl .search
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
