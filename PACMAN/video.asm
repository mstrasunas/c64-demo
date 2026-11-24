render
 lda #0
 sta videoReady
 sta msb
 ldx #0
renderActor
 txa
 asl
 tay
 lda px,x
 clc
 adc #62
 sta spriteXY,y
 bcc +
 lda msb
 ora bits,x
 sta msb
+ lda py,x
 clc
 adc #72
 sta spriteXY+1,y
 cpx #0
 bne ghostGraphic
 lda #7
 sta spriteColor
 lda state
 cmp #3
 bne mouth
 lda #64
 sec
 sbc timer
 lsr
 lsr
 lsr
 clc
 adc #$e8
 bne frameSet
mouth
 lda dirs
 asl
 asl
 sta tmp
 lda px
 ora py ; orthogonal coordinate is a multiple of eight
 lsr
 and #3
 eor #2
 ora tmp
 ora #$c0
 bne frameSet
ghostGraphic
 lda colors-1,x
 sta spriteColor,x
 lda #$d0
 ldy eaten,x
 beq +
 lda #$e0
 bne ghostFrame
+ ldy frightened
 beq ghostFrame
 lda #6
 cpy #61
 bcs +
 tya
 and #8
 beq blueAgain
 lda #1
 bne +
blueAgain
 lda #6
+ sta spriteColor,x
 lda #$d8
ghostFrame
 sta tmp
 lda dirs,x
 asl
 ora tmp
 sta tmp
 lda tick
 lsr
 lsr
 lsr
 and #1
 ora tmp
frameSet
 sta spriteFrame,x
 inx
 cpx #5
 beq +
 jmp renderActor
+
 lda msb
 sta spriteMSB
 ldx fruitKind
 lda fruitFrames,x
 sta spriteFrame+5
 lda #174
 sta spriteXY+10
 lda #168
 sta spriteXY+11
 lda fruitColors,x
 sta spriteColor+5
 lda #31
 ldy fruitTime
 beq +
 ora #32
+ ldy state
 cpy #3
 bne +
 lda #1
+ sta spriteEnable
 ; Pulse only the four energizers, preserving the collision map.
 lda tick
 and #16
 beq +
 lda #7
+
 sta $d800+125+40+1
 sta $d800+125+40+27
 sta $d800+125+16*40+1
 sta $d800+125+16*40+27
 lda #1
 sta videoReady
 rts
bits !byte 1,2,4,8,16
colors !byte 2,10,3,8
msb !byte 0
fruitFrames !byte $f0,$f1,$f2
fruitColors !byte 2,10,8

; Publish one complete snapshot at raster 251, before the next visible field.
publish
 lda videoReady
 bne +
 rts
+
 !for i,0,11 {
 lda spriteXY+i
 sta $d000+i
 }
 !for i,0,5 {
 lda spriteColor+i
 sta $d027+i
 lda spriteFrame+i
 sta $07f8+i
 }
 lda spriteMSB
 sta $d010
 lda spriteEnable
 sta $d015
 lda #0
 sta videoReady
publishDone
 rts
videoReady !byte 0
spriteXY !fill 12
spriteColor !fill 6
spriteFrame !fill 6
spriteMSB !byte 0
spriteEnable !byte 0
