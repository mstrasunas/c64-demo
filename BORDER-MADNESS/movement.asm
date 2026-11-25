// Q10.6 phase, 768 pixels to a horizontal round trip and 448 vertically.
// A group of four pixels never straddles a reflection or the VIC X wrap.
// XOR with the two fine pixel bits therefore works on either slope.
.var spinSteps=List().add(5,9,249,6,247,4,7,251,6,248,5,7,252,6,9,249)
move:
.for(var i=0;i<16;i++) {
    clc
    lda xPhaseLo+i
    adc xSpeed+i
    sta xPhaseLo+i
    tax
    lda xPhaseHi+i
    adc #0
    cmp #192
    bcc !x+
    lda #0
!x: sta xPhaseHi+i
    tay
    lda xBase,y
    eor finePixel,x
    sta px+i
    lda xBit,y
    sta hi+i
    clc
    lda yPhaseLo+i
    adc ySpeed+i
    sta yPhaseLo+i
    tax
    lda yPhaseHi+i
    adc #0
    cmp #112
    bcc !y+
    lda #0
!y: sta yPhaseHi+i
    tay
    lda yBase,y
    eor finePixel,x
    clc
    adc #26
    sta py+i
    clc
    lda phase+i
    adc #spinSteps.get(i)
    sta phase+i
    tay
    lda animationPointers+mod(i,4)*256,y
    sta currentPtr+i
}
    rts
