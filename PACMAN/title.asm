title
 jsr clearScreen
 lda #0
 sta state
 ; Each set font pixel becomes a custom bevel tile in the title masthead.
 ldx #0
logoLetter
 lda logo,x
 asl
 asl
 asl
 sta ptr
 lda #$20
 adc #0
 sta ptr+1
 lda logoX,x
 clc
 adc #<($0400+40*4)
 sta dst
 lda #>($0400+40*4)
 adc #0
 sta dst+1
 ldy #0
logoRow
 lda (ptr),y
 asl
 sta glyph
 sty row
 ldy #0
logoBit
 asl glyph
 bcc +
 lda #127
 sta (dst),y
+ iny
 cpy #5
 bne logoBit
 lda dst
 clc
 adc #40
 sta dst
 bcc +
 inc dst+1
+ ldy row
 iny
 cpy #7
 bne logoRow
 inx
 cpx #6
 bne logoLetter
 jsr titleLabels
 ldx #0
- lda #7
 sta $d800+4*40,x
 sta $d800+5*40,x
 sta $d800+6*40,x
 lda #8
 sta $d800+7*40,x
 sta $d800+8*40,x
 sta $d800+9*40,x
 sta $d800+10*40,x
 inx
 cpx #40
 bne -
 ldx #4
- txa
 asl
 tay
 lda titleX,x
 sta $d000,y
 lda #169
 sta $d001,y
 lda titleFrame,x
 sta $07f8,x
 lda titleColor,x
 sta $d027,x
 dex
 bpl -
 lda #16
 sta $d010
 lda #31
 sta $d015
 rts
gameOver
 lda #4
 sta state
 lda #0
 sta videoReady
 sta $d015
 sta fireHeld
 jsr hud
 ldx #8
- lda overText,x
 sta banner,x
 dex
 bpl -
 rts
logo !byte 48,33,35,45,33,46
logoX !byte 2,8,14,20,26,32
titleX !byte 65,112,162,212,6
titleFrame !byte $ce,$d6,$d6,$d6,$d6
titleColor !byte 7,2,10,3,8
glyph !byte 0
row !byte 0
overText !byte 39,33,45,37,0,47,54,37,50
hudLabels
 ldx #4
- lda hudLabels0,x
 sta $0401,x
 lda #3
 sta $d801,x
 dex
 bpl -
 ldx #3
- lda hudLabels1,x
 sta $0411,x
 lda #10
 sta $d811,x
 dex
 bpl -
 ldx #3
- lda hudLabels2,x
 sta $0420,x
 lda #7
 sta $d820,x
 dex
 bpl -
 ldx #4
- lda hudLabels3,x
 sta $0446,x
 lda #15
 sta $d846,x
 dex
 bpl -
 rts
hudLabels0 !byte 51,35,47,50,37
hudLabels1 !byte 34,37,51,52
hudLabels2 !byte 44,41,38,37
hudLabels3 !byte 50,47,53,46,36
titleLabels
 ldx #22
- lda titleLabels0,x
 sta $0431,x
 lda #3
 sta $d831,x
 dex
 bpl -
 ldx #22
- lda titleLabels1,x
 sta $05ea,x
 lda #15
 sta $d9ea,x
 dex
 bpl -
 ldx #5
- lda titleLabels2,x
 sta $06ab,x
 lda #7
 sta $daab,x
 dex
 bpl -
 ldx #5
- lda titleLabels3,x
 sta $06b2,x
 lda #2
 sta $dab2,x
 dex
 bpl -
 ldx #4
- lda titleLabels4,x
 sta $06b9,x
 lda #10
 sta $dab9,x
 dex
 bpl -
 ldx #3
- lda titleLabels5,x
 sta $06c0,x
 lda #3
 sta $dac0,x
 dex
 bpl -
 ldx #4
- lda titleLabels6,x
 sta $06c6,x
 lda #8
 sta $dac6,x
 dex
 bpl -
 ldx #17
- lda titleLabels7,x
 sta $0729,x
 lda #7
 sta $db29,x
 dex
 bpl -
 ldx #20
- lda titleLabels8,x
 sta $0779,x
 lda #12
 sta $db79,x
 dex
 bpl -
 rts
titleLabels0 !byte 35,0,47,0,45,0,45,0,47,0,36,0,47,0,50,0,37,0,0,0,22,0,20
titleLabels1 !byte 52,0,40,0,37,0,0,0,45,0,33,0,58,0,37,0,0,0,50,0,53,0,46
titleLabels2 !byte 50,53,46,46,37,50
titleLabels3 !byte 34,44,41,46,43,57
titleLabels4 !byte 48,41,46,43,57
titleLabels5 !byte 41,46,43,57
titleLabels6 !byte 35,44,57,36,37
titleLabels7 !byte 48,50,37,51,51,0,38,41,50,37,0,52,47,0,48,44,33,57
titleLabels8 !byte 42,47,57,51,52,41,35,43,0,0,41,46,0,0,48,47,50,52,0,0,18
animateTitle
 lda tick
 lsr
 lsr
 lsr
 and #1
 ora #$d6
 ldx #4
- sta $07f8,x
 dex
 bne -
 lda tick
 lsr
 lsr
 and #3
 ora #$cc
 sta $07f8
 rts
