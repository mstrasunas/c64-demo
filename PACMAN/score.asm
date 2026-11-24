; Score in six decimal digits. A contains a number of tens.
addScore
 tax
- ldy #4
carryDigit
 lda score,y
 clc
 adc #1
 sta score,y
 lda score,y
 cmp #10
 bcc digitDone
 lda #0
 sta score,y
 dey
 bpl carryDigit
digitDone
 dex
 bne -
 ldx #0
compareHigh
 lda score,x
 cmp high,x
 bcc hud
 bne copyHigh
 inx
 cpx #6
 bne compareHigh
 beq hud
copyHigh
 lda score,x
 sta high,x
 inx
 cpx #6
 bne copyHigh
hud
 ldx #5
- lda score,x
 ora #16
 sta $0400+7,x
 lda high,x
 ora #16
 sta $0400+23,x
 dex
 bpl -
 lda lives
 ora #16
 sta $0425
 lda level
 ldx #0
- cmp #10
 bcc +
 sec
 sbc #10
 inx
 bne -
+ ora #16
 sta $0400+40+37
 txa
 and #15
 ora #16
 sta $0400+40+36
 rts
score !fill 6
high !fill 6
