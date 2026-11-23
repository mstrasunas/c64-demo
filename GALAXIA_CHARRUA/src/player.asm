!zone player
; Joystick 2 en CIA1 PA, teclado A/D/espacio por matriz PA -> PB.
controls
 lda #0
 sta $dc03
 sta $dc02
 lda $dc00
 eor #$ff
 and #$1c
 sta keys
 lda #$fd
 sta $dc00
 lda #$ff
 sta $dc02
 lda $dc01
 and #4
 bne +
 lda keys
 ora #4
 sta keys
+ lda #$fb
 sta $dc00
 lda $dc01
 and #4
 bne +
 lda keys
 ora #8
 sta keys
+ lda #$7f
 sta $dc00
 lda $dc01
 and #16
 bne +
 lda keys
 ora #16
 sta keys
+ lda #$ff
 sta $dc00
 rts
playerTick
 lda immune
 beq +
 dec immune
+ lda keys
 and #12
 tax
 lda desiredSpeed,x
 cmp velocity
 beq .integrate
 sec
 sbc velocity
 bmi .brakeLeft
 inc velocity
 inc velocity
 jmp .integrate
.brakeLeft dec velocity
 dec velocity
.integrate lda velocity
 clc
 adc fraction
 tax
 and #7
 sta fraction
 txa
 eor #$80
 lsr
 lsr
 lsr
 sec
 sbc #16
 clc
 adc playerX
 cmp #149
 bcc .store
 cmp #200
 lda #148
 bcc .edge
 lda #0
.edge ldx #0
 stx fraction
 stx velocity
.store sta playerX
.fire
 lda cool
 beq +
 dec cool
+ lda keys
 and #16
 beq .moveAll
 lda cool
 bne .moveAll
 ldx #0
.find lda shotY,x
 beq .launch
 inx
 cpx #3
 bne .find
 beq .moveAll
.launch lda playerX
 clc
 adc #5
 sta shotX,x
 lda #222
 sta shotY,x
 lda #13
 sta cool
 jsr laser
.moveAll ldx #2
.move stx shotSlot
 lda shotY,x
 beq .next
 sec
 sbc #4
 cmp #60
 bcs .draw
 jsr dropShot
 jmp .next
.draw sta shotY,x
 pha
 lda shotX,x
 ldy shotSlot
 ldx shotSprite,y
 jsr position
 pla
 sta $d001,y
 lda #69
 sta screen+1016,x
 lda #3
 sta $d027,x
 lda $d015
 ora bitMask,x
 sta $d015
.next ldx shotSlot
 dex
 bpl .move
 jmp shipDraw
dropShot
 ldx shotSlot
 lda #0
 sta shotY,x
 ldy shotSprite,x
 lda $d015
 and clearBit,y
 sta $d015
 rts
shotSprite !byte 1,5,6
