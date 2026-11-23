!zone swarm
; slot 0..23. La formación usa caracteres de 16x16. Un atacante pasa a sprite.
cellAddress
 lda rowLo,x
 sta ptr
 sta colptr
 lda rowHi,x
 sta ptr+1
 clc
 adc #$94
 sta colptr+1
 txa
 and #7
 asl
 asl
 clc
 adc formation
 tay
 rts
homeXY
 txa
 and #7
 asl
 asl
 clc
 adc formation
 asl
 asl
 clc
 adc fineHalf
 sta targetX
 lda homeY,x
 sta targetY
 rts
eraseSlot
 jsr cellAddress
 lda #32
 sta (ptr),y
 iny
 sta (ptr),y
 tya
 clc
 adc #39
 tay
 lda #32
 sta (ptr),y
 iny
 sta (ptr),y
 rts
paintSlot
 lda alive,x
 beq .skip
 cpx diver
 beq .skip
 jsr cellAddress
 lda tileID,x
 sta (ptr),y
 lda enemyColor,x
 sta (colptr),y
 iny
 lda tileID,x
 clc
 adc #1
 sta (ptr),y
 lda enemyColor,x
 sta (colptr),y
 tya
 clc
 adc #39
 tay
 lda tileID,x
 clc
 adc #2
 sta (ptr),y
 lda enemyColor,x
 sta (colptr),y
 iny
 lda tileID,x
 clc
 adc #3
 sta (ptr),y
 lda enemyColor,x
 sta (colptr),y
.skip rts
paintAll
 ldx #23
- jsr paintSlot
 dex
 bpl -
 rts
swarmTick
 ; Acumulador fraccional: entre 1 y 1,75 píxeles por cuadro PAL.
 lda marchPhase
 clc
 adc marchBoost
 sta marchPhase
 lda scrollX
 bcc .one
 clc
 adc marchDir
.one clc
 adc marchDir
.bounded cmp #64
 bcc .low
 lda #$ff
 sta marchDir
 lda #64
.low cmp #9
 bcs .phase
 lda #1
 sta marchDir
 lda #8
.phase sta scrollX
 and #7
 sta fineX
 lsr
 sta fineHalf
 lda scrollX
 lsr
 lsr
 lsr
 cmp formation
 beq .wings
 pha
 ldx #23
- jsr eraseSlot
 dex
 bpl -
 pla
 sta formation
 jsr paintAll
.wings lda frame
 and #3
 bne .attacks
 inc animation
 ldx animation
 cpx #6
 bcc +
 ldx #0
 stx animation
+ lda poseLo,x
 sta ptr
 lda poseHi,x
 sta ptr+1
 ldy #95
- lda (ptr),y
 sta chars+128*8,y
 dey
 bpl -
.attacks
 lda diver
 cmp #$ff
 bne diveTick
 dec diveTimer
 bne .finish
 jsr pickEnemy
 bcs .finish
 stx diver
 jsr eraseSlot
 jsr homeXY
 lda targetX
 sta diveX
 lda targetY
 sta diveY
 lda #0
 sta returning
 jsr diveSound
 jmp drawDive
.finish rts
; Búsqueda acotada: el LFSR selecciona el punto de entrada.
pickEnemy
 lda seed
 asl
 bcc +
 eor #$1d
+ sta seed
 and #31
 cmp #24
 bcc +
 sbc #24
+ tax
 ldy #24
- lda alive,x
 beq +
 cpx diver
 bne .found
+ inx
 cpx #24
 bcc +
 ldx #0
+ dey
 bne -
 sec
 rts
.found clc
 rts
diveTick
 ldx diver
 jsr homeXY
 lda returning
 bne .home
 inc diveY
 lda frame
 and #1
 bne +
 inc diveY
+ lda diveY
 cmp #246
 bcc .steer
 lda #52
 sta diveY
 inc returning
 jmp drawDive
.steer
 lda frame
 and #3
 beq .aim
 lda diveY
 and #$10
 beq .curveLeft
 lda diveX
 cmp #148
 bcs drawDive
 inc diveX
 jmp drawDive
.curveLeft lda diveX
 beq drawDive
 dec diveX
 jmp drawDive
.aim lda playerX
 jsr approachX
 jmp drawDive
.home
 lda targetX
 jsr approachX
 lda diveY
 cmp targetY
 bcs .land
 inc diveY
 jmp drawDive
.land lda diveX
 cmp targetX
 bne drawDive
 jsr endDive
 jsr paintSlot
 rts
approachX
 cmp diveX
 beq .same
 bcc .left
 inc diveX
 rts
.left dec diveX
.same rts
endDive
 lda #$ff
 sta diver
 lda attackDelay
 sta diveTimer
 lda $d015
 and #$fb
 sta $d015
 rts
drawDive
 ldx diver
 lda tileID,x
 sec
 sbc #128
 sta tempByte
 lsr
 clc
 adc tempByte
 adc animation
 adc #94
 sta screen+1018
 lda enemyColor,x
 and #7
 sta $d029
 ldx #2
 lda diveX
 jsr position
 lda diveY
 sta $d005
 lda $d015
 ora #4
 sta $d015
 rts
bombTick
 lda bombY
 bne .move
 dec bombTimer
 beq +
 rts
+
 lda attackDelay
 sta bombTimer
 lda diver
 cmp #$ff
 beq .rank
 lda returning
 bne .rank
 lda diveY
 cmp #211
 bcs .rank
 adc #7
 sta bombY
 lda diveX
 jmp .armed
.rank jsr pickEnemy
 bcs .done
 jsr homeXY
 lda targetY
 clc
 adc #12
 sta bombY
 lda targetX
.armed clc
 adc #4
 sta bombX
 lda #0
 sta bombDir
 lda bombX
 cmp playerX
 beq .move
 lda #1
 bcc +
 lda #$ff
+ sta bombDir
.move lda frame
 and #3
 bne +
 lda bombX
 clc
 adc bombDir
 cmp #159
 bcs +
 sta bombX
+ lda bombY
 clc
 adc bombSpeed
 cmp #246
 bcs clearBomb
 sta bombY
 ldx #3
 lda bombX
 jsr position
 lda bombY
 sta $d007
 lda #70
 sta screen+1019
 lda #2
 sta $d02a
 lda $d015
 ora #8
 sta $d015
.done rts
clearBomb
 lda #0
 sta bombY
 lda $d015
 and #$f7
 sta $d015
 rts
