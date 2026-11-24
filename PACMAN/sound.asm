soundInit
 lda #0
 ldx #24
- sta $d400,x
 dex
 bpl -
 lda #15
 sta $d418
 lda #$08
 sta $d403
 sta $d40a
 sta $d411
 lda #$19
 sta $d405
 sta $d40c
 sta $d413
 lda #$a6
 sta $d406
 sta $d40d
 sta $d414
 rts
; Voice 1 melody, voice 2 siren, voice 3 preemptible effects.
effect
 cmp #2
 bne +
 ldx priority
 bne effectDone
+ cmp priority
 bcc effectDone
 sta priority
 tax
 lda lengths,x
 sta sfxTime
 lda waves,x
 sta $d412
 ora #1
 sta $d412
effectDone
 rts
soundTick
 lda state
 beq theme
 lda #$10
 sta $d404
 lda state
 cmp #2
 beq siren
 lda #$10
 sta $d40b
 jmp playFx
theme
 lda tick
 and #7
 bne playFx
 lda tick
 lsr
 lsr
 lsr
 and #31
 tay
 lda tune,y
 tax
 lda notesLo,x
 sta $d400
 lda notesHi,x
 sta $d401
 lda #$40
 sta $d404
 cpx #0
 beq playFx
 lda #$41
 sta $d404
 jmp playFx
siren
 lda tick
 and #31
 cmp #16
 bcc +
 eor #31
+ asl
 ldy frightened
 beq +
 lsr
+ clc
 adc #8
 sta $d408
 lda #$20
 sta $d407
 lda #$11
 sta $d40b
playFx
 ldx priority
 beq soundDone
 dec sfxTime
 beq stopFx
 lda sfxTime
 cpx #6
 beq descending
 cpx #7
 beq flourish
 cpx #4
 bcs rise
 and #7
 asl
 asl
 adc #8
 bne pitch
rise
 eor #31
 and #31
 asl
 adc #10
 bne pitch
flourish
 lsr
 lsr
 and #7
 tay
 lda scale,y
 bne pitch
descending
 lsr
 adc #3
pitch
 sta $d40f
 lda tick
 asl
 asl
 sta $d40e
soundDone
 rts
stopFx
 lda #0
 sta priority
 sta $d412
 rts
lengths !byte 0,6,2,25,25,30,62,76
waves !byte 0,$10,$10,$40,$40,$10,$20,$40
scale !byte 68,54,45,36,32,27,22,18
tune !byte 1,0,4,6,8,6,4,0,2,0,5,7,9,7,5,0,3,5,8,10,8,5,3,0,4,6,9,8,6,4,1,0
notesLo !byte 0,$67,$33,$03,$d5,$aa,$87,$65,$4b,$36,$24
notesHi !byte 0,$11,$13,$15,$16,$19,$1c,$20,$22,$26,$2a
sfxTime !byte 0
priority !byte 0
