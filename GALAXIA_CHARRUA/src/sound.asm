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
 ; Voz 2 reservada al himno tanto en presentación como en partida.
music
 lda noteTime
 beq .next
 dec noteTime
 lda noteTime
 cmp #2
 bne .done
 lda #$40
 sta $d40b
.done rts
.next ldx songPos
 cpx #anthemEnd-anthem
 bcc +
 ldx #0
+ lda anthem,x
 tay
 lda anthem+1,x
 sec
 sbc #1
 sta noteTime
 inx
 inx
 stx songPos
 lda #$40
 sta $d40b
 cpy #0
 beq .done
 lda anthemLo,y
 sta $d407
 lda anthemHi,y
 sta $d408
 lda #5
 sta $d40a
 lda #$18
 sta $d40c
 lda #$a7
 sta $d40d
 lda #$41
 sta $d40b
 rts

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
 ldx #0
 stx diveTone
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
 lda noiseTime
 beq +
 rts
+ lda #$10
 sta $d412
 lda #$06
 sta $d40f
 lda #$04
 sta $d413
 lda #$39
 sta $d414
 lda #$11
 sta $d412
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
 sta $d40f
 bne +
 lda #$10
 sta $d412
+ rts
