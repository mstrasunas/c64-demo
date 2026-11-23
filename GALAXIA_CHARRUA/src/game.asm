!zone game
newGame
 lda #0
 ldx #runEnd-runStart-1
- sta runStart,x
 dex
 bpl -
 lda #1
 sta mode
 sta wave
 lda #74
 sta playerX
 lda #3
 sta lives
 lda #$ab
 sta seed
 lda #15
 sta cool
 lda #0
 sta noteTime
 sta songPos
 jsr silence
 jsr scheduleFlag
 jsr playVideo
 jsr nextFleet
 jmp hud
nextFleet
 lda #1
 sta marchDir
 ldx #23
- sta alive,x
 dex
 bpl -
 lda #24
 sta remaining
 lda #32
 sta scrollX
 lda #0
 sta fineX
 sta fineHalf
 lda #4
 sta formation
 lda #$ff
 sta diver
 lda #0
 sta shotY
 sta shotY+1
 sta shotY+2
 sta bombY
 sta blastTime
 sta $d015
 lda wave
 cmp #13
 bcc +
 lda #13
+ sta difficulty
 sec
 sbc #1
 asl
 asl
 asl
 asl
 sta marchBoost
 lda #0
 sta marchPhase
 lda difficulty
 asl
 asl
 sta tempByte
 lda #82
 sec
 sbc tempByte
 sta attackDelay
 sta bombTimer
 clc
 adc #24
 sta diveTimer
 lda difficulty
 cmp #6
 lda #2
 adc #0
 sta bombSpeed
 lda #65
 sta waveBanner
 ldx #8
- lda sectorMsg,x
 sta screen+16*40+15,x
 lda #7
 sta $d800+16*40+15,x
 dex
 bpl -
 jsr paintAll
 jsr hud
 lda screen+75
 sta screen+16*40+20
 lda screen+76
 sta screen+16*40+21
 rts
gameTick
 ; Componer el cielo antes de que el VIC lea las primeras filas visibles.
 jsr advanceFormation
 jsr stars
 jsr music
 jsr audioTick
 jsr blastTick
 jsr playerTick
 jsr swarmTick
 jsr bombTick
 jsr flagTick
 jsr hits
 lda mode
 cmp #1
 bne .done
 lda remaining
 bne .banner
 lda blastTime
 bne .done
 lda wave
 cmp #99
 beq +
 inc wave
+ jmp nextFleet
.banner lda waveBanner
 beq .done
 dec waveBanner
 bne .done
 ldx #8
 lda #32
- sta screen+16*40+15,x
 dex
 bpl -
.done rts
gameOver
 lda #$40
 sta $d40b
 lda #0
 sta idleLo
 lda #2
 sta idleHi
 sta mode
 lda #1
 sta latch
 lda #16
 sta $d015
 ldx #pressEnd-pressMsg-1
- lda pressMsg,x
 sta screen+17*40+10,x
 lda #1
 sta $d800+17*40+10,x
 dex
 bpl -
 ldx #8
- lda overMsg,x
 sta screen+15*40+15,x
 lda #7
 sta $d800+15*40+15,x
 lda #32
 sta screen+16*40+15,x
 dex
 bpl -
 rts
; Tres bytes BCD big-endian. El puntaje se satura en 999999.
scoreKill
 lda award,x
 cpx diver
 bne +
 sed
 clc
 adc award,x
 cld
+ sed
 clc
 adc score+2
 sta score+2
 lda score+1
 adc #0
 sta score+1
 lda score
 adc #0
 sta score
 cld
 bcc +
 lda #$99
 sta score
 sta score+1
 sta score+2
+ ldx #0
- lda score,x
 cmp high,x
 bcc hud
 bne .record
 inx
 cpx #3
 bne -
 beq hud
.record ldx #2
- lda score,x
 sta high,x
 dex
 bpl -
hud
 ldx #39
- lda labels,x
 sta screen,x
 lda #3
 sta $d800,x
 dex
 bpl -
 ldx #0
 ldy #1
- lda score,x
 jsr .pair
 inx
 cpx #3
 bne -
 ldx #0
 ldy #12
- lda high,x
 jsr .pair
 inx
 cpx #3
 bne -
 lda lives
 ora #48
 sta screen+40+26
 lda wave
 ldx #48
- cmp #10
 bcc +
 sbc #10
 inx
 bne -
+ ora #48
 sta screen+40+36
 stx screen+40+35
 rts
.pair pha
 lsr
 lsr
 lsr
 lsr
 ora #48
 sta screen+40,y
 iny
 pla
 and #15
 ora #48
 sta screen+40,y
 iny
 rts

!zone respawn
lifeNotice
 lda #3
 sta mode
 lda #1
 sta latch
 lda #40
 sta readyDelay
 lda #0
 sta doubleGun
 sta flagY
 sta shotY
 sta shotY+1
 sta shotY+2
 sta bombY
 lda #32
 sta screen+40+31
 sta screen+40+32
 lda #16
 sta $d015
 lda #$40
 sta $d40b
 jsr scheduleFlag
 ldx diver
 cpx #$ff
 beq +
 jsr endDive
 jsr paintSlot
+ ldx #noticeWidth-1
- lda lostText,x
 sta screen+18*40+8,x
 lda lifeText,x
 sta screen+19*40+8,x
 lda resumeText,x
 sta screen+21*40+8,x
 lda #7
 sta $d800+18*40+8,x
 lda #1
 sta $d800+19*40+8,x
 sta $d800+21*40+8,x
 dex
 bpl -
 lda #52
 sec
 sbc lives
 sta screen+19*40+8+10
 rts
lifeWait
 jsr audioTick
 jsr blastTick
 jsr stars
 lda readyDelay
 beq .input
 dec readyDelay
 jsr trigger
 rts
.input jsr trigger
 bcc .wait
 ldx #noticeWidth-1
 lda #32
- sta screen+18*40+8,x
 sta screen+19*40+8,x
 sta screen+21*40+8,x
 dex
 bpl -
 lda #1
 sta mode
 lda #13
 sta cool
.wait rts
lostText !scr "      nave perdida      "
lifeText !scr "     vida 0 de 3        "
resumeText !scr "fire/espacio para seguir"
noticeWidth=24
