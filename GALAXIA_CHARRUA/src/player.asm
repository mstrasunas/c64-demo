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
 cmp #4
 bne .right
 lda playerX
 beq .fire
 dec playerX
 bne .fire
.right cmp #8
 bne .fire
 lda playerX
 cmp #148
 bcs .fire
 inc playerX
.fire
 lda cool
 beq +
 dec cool
+ lda shotY
 bne .move
 lda keys
 and #16
 beq .end
 lda cool
 bne .end
 lda playerX
 clc
 adc #5
 sta shotX
 lda #222
 sta shotY
 lda #13
 sta cool
 jsr laser
.move
 lda shotY
 sec
 sbc #4
 cmp #60
 bcc dropShot
 sta shotY
 ldx #1
 lda shotX
 jsr position
 lda shotY
 sta $d003
 lda #69
 sta screen+1017
 lda #3
 sta $d028
 lda $d015
 ora #2
 sta $d015
.end jmp shipDraw
dropShot
 lda #0
 sta shotY
 lda $d015
 and #$fd
 sta $d015
 rts
