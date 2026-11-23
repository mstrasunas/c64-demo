!zone sid
silence
 lda #0
 ldx #24
- sta $d400,x
 dex
 bpl -
 lda #15
 sta $d418
 rts
; Dos voces en presentación: motivo de pulso y bajo triangular.
music
 lda frame
 and #7
 bne .leave
 lda songPos
 and #31
 tax
 lda #$40
 sta $d404
 lda #$10
 sta $d40b
 lda #$09
 sta $d403
 lda #$06
 sta $d405
 lda #$59
 sta $d406
 lda #$16
 sta $d40c
 lda #$79
 sta $d40d
 lda melody,x
 beq .bass
 tay
 lda freqLo,y
 sta $d400
 lda freqHi,y
 sta $d401
 lda #$41
 sta $d404
.bass txa
 lsr
 lsr
 tay
 ldx bass,y
 lda freqHi,x
 lsr
 sta $d408
 lda freqLo,x
 ror
 sta $d407
 lda #$11
 sta $d40b
 inc songPos
.leave rts
laser
 lda #$20
 sta $d404
 lda #$28
 sta $d401
 lda #$01
 sta $d405
 lda #$68
 sta $d406
 lda #$21
 sta $d404
 lda #8
 sta laserTime
 rts
killSound
 lda tileID,x
 sec
 sbc #118
 asl
 bne noise
deathSound
 lda #52
noise
 sta noiseTime
 sta $d40f
 lda #$80
 sta $d412
 lda #$03
 sta $d413
 lda #$88
 sta $d414
 lda #$81
 sta $d412
 rts
diveSound
 lda #$10
 sta $d40b
 lda #$06
 sta $d408
 lda #$04
 sta $d40c
 lda #$39
 sta $d40d
 lda #$11
 sta $d40b
 lda #18
 sta diveTone
 rts
audioTick
 lda laserTime
 beq +
 dec laserTime
 lda laserTime
 asl
 asl
 sta $d401
 bne +
 lda #$20
 sta $d404
+ lda noiseTime
 beq +
 dec noiseTime
 lda noiseTime
 sta $d40f
 bne +
 lda #$80
 sta $d412
+ lda diveTone
 beq +
 dec diveTone
 lda diveTone
 sta $d408
 bne +
 lda #$10
 sta $d40b
+ rts
