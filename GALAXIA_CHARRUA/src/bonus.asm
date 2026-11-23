!zone bonus
; Después de varias bajas se desprende la bandera del puesto destruido.
flagDrop
 lda doubleGun
 ora flagY
 bne .done
 dec killsToFlag
 bne .done
 lda targetX
 sta flagX
 lda targetY
 sta flagY
scheduleFlag
 lda seed
 eor frame
 and #3
 clc
 adc #3
 sta killsToFlag
.done rts

flagTick
 lda flagY
 beq .doneFlag
 lda frame
 and #1
 bne .draw
 inc flagY
.draw lda flagY
 cmp #244
 bcs hideFlag
 cmp #208
 bcc .paint
 lda flagX
 sec
 sbc playerX
 clc
 adc #10
 cmp #21
 bcs .paint
 lda #1
 sta doubleGun
 lda #7
 sta $d800+40+31
 lda #$18
 sta screen+40+31
 lda #50
 sta screen+40+32
 jmp hideFlag
.paint lda flagX
 ldx #7
 jsr position
 lda flagY
 sta $d00f
 lda frame
 lsr
 lsr
 lsr
 and #3
 clc
 adc #124
 sta screen+1023
 lda #7
 sta $d02e
 lda $d015
 ora #128
 sta $d015
.doneFlag rts
hideFlag
 lda #0
 sta flagY
 lda $d015
 and #127
 sta $d015
 rts
