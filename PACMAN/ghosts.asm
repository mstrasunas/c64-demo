; Each actor has an 8-bit fractional speed accumulator (256 = 1 pixel/tick).
moveGhosts
 ldx #1
ghostLoop
 stx actor
 lda release,x
 beq released
 dec release,x
 jmp nextGhost
released
 lda eaten,x
 beq living
 jsr ghostPixel
 ldx actor
 lda release,x
 bne nextGhost
 jsr ghostPixel
 jmp nextGhost
living
 lda frightened
 beq normalSpeed
 lda #132
 bne scaleSpeed
normalSpeed
 lda speed
scaleSpeed
 clc
 adc fraction,x
 sta fraction,x
 bcc nextGhost
 jsr ghostPixel
nextGhost
 ldx actor
 inx
 cpx #5
 bne ghostLoop
 rts
ghostPixel
 jsr position
 beq +
 jmp ghostStep
+
 lda eaten,x
 beq plan
 lda cx
 cmp #14
 bne returnHome
 lda cy
 cmp #10
 bne returnHome
 lda #0
 sta eaten,x
 lda #35
 sta release,x
 rts
returnHome
 ldy cy
 lda homeLo,y
 sta ptr
 lda homeHi,y
 sta ptr+1
 ldy cx
 lda (ptr),y
 sta dirs,x
 jmp ghostStep
plan
 ; Leaving the pen takes precedence over steering towards a chase target.
 lda cy
 cmp #9
 bne checkPen
 lda cx
 cmp #14
 beq leaveUp
 bne steer
checkPen
 cmp #10
 bne steer
 lda cx
 cmp #10
 bcc steer
 cmp #19
 bcs steer
 cmp #14
 beq leaveUp
 bcc leaveRight
 lda #1
 bne exitPen
leaveRight
 lda #3
 bne exitPen
leaveUp
 lda #0
exitPen
 sta dirs,x
 jmp advance
steer
 jsr target
 lda #255
 sta best
 sta choice
 lda #0
 sta candidate
scan
 ldx actor
 lda dirs,x
 eor #2
 cmp candidate
 beq skip
 lda candidate
 jsr probe
 bcc skip
 lda nx
 sec
 sbc targetX
 jsr absolute
 tay
 lda squares,y
 sta tmp
 lda ny
 sec
 sbc targetY
 jsr absolute
 tay
 lda squares,y
 clc
 adc tmp
 bcc +
 lda #254
+ ldy frightened
 beq +
 eor #255
+ ldy choice
 cpy #255
 beq takeDirection
 cmp best
 bcs skip
takeDirection
 sta best
 lda candidate
 sta choice
skip
 inc candidate
 lda candidate
 cmp #4
 bne scan
 ldx actor
 lda choice
 cmp #255
 bne chosen
 lda dirs,x
 eor #2
chosen
 sta dirs,x
ghostStep
 jmp advance
absolute
 bpl +
 eor #255
 clc
 adc #1
+ rts
; Scaled quadratic cost keeps the hot comparison within one byte.
squares !for i,0,63 { !byte (i*i+3)/4 & 255 }
target
 lda px
 lsr
 lsr
 lsr
 sta targetX
 lda py
 lsr
 lsr
 lsr
 sta targetY
 lda frightened
 bne targetDone
 lda scatter
 bne corner
 cpx #1
 beq targetDone
 cpx #4
 bne project
 lda targetX
 sec
 sbc cx
 jsr absolute
 sta tmp
 lda targetY
 sec
 sbc cy
 jsr absolute
 clc
 adc tmp
 cmp #8
 bcs targetDone
corner
 lda cornersX-1,x
 sta targetX
 lda cornersY-1,x
 sta targetY
targetDone
 rts
project
 ldy dirs
 lda offsetX,y
 cpx #2
 bne +
 asl
+ clc
 adc targetX
 sta targetX
 lda offsetY,y
 cpx #2
 bne +
 asl
+ clc
 adc targetY
 sta targetY
 cpx #3
 bne clamp
 lda px+1
 lsr
 lsr
 lsr
 sta tmp
 lda targetX
 asl
 sec
 sbc tmp
 sta targetX
 lda py+1
 lsr
 lsr
 lsr
 sta tmp
 lda targetY
 asl
 sec
 sbc tmp
 sta targetY
clamp
 lda targetX
 jsr clampX
 sta targetX
 lda targetY
 jsr clampX
 cmp #22
 bcc +
 lda #21
+ sta targetY
 rts
clampX
 bpl +
 lda #0
+ cmp #29
 bcc +
 lda #28
+ rts
offsetX !byte 0,254,0,2
offsetY !byte 254,0,2,0
cornersX !byte 27,1,27,1
cornersY !byte 1,1,20,20
reverseGhosts
 ldx #4
- lda eaten,x
 ora release,x
 bne +
 lda dirs,x
 eor #2
 sta dirs,x
+ dex
 bne -
 rts
release !fill 5
fraction !fill 5
eaten !fill 5
