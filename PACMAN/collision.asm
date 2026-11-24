contacts
 lda fruitTime
 beq checkGhosts
 lda px
 sec
 sbc #112
 jsr absolute
 cmp #6
 bcs checkGhosts
 lda py
 sec
 sbc #96
 jsr absolute
 cmp #6
 bcs checkGhosts
 lda #0
 sta fruitTime
 lda #5
 jsr effect
 ldx fruitKind
 lda fruitScores,x
 jsr addScore
checkGhosts
 ldx #4
contactLoop
 lda eaten,x
 ora release,x
 bne noContact
 lda px,x
 sec
 sbc px
 jsr absolute
 cmp #7
 bcs noContact
 lda py,x
 sec
 sbc py
 jsr absolute
 cmp #7
 bcs noContact
 lda frightened
 beq fatal
 lda #1
 sta eaten,x
 stx savedActor
 lda #4
 jsr effect
 ldy chain
 lda captureValue,y
 jsr addScore
 ldx savedActor
 lda chain
 cmp #3
 bcs noContact
 inc chain
noContact
 dex
 bne contactLoop
 rts
fatal
 lda #3
 sta state
 lda #64
 sta timer
 lda #6
 jmp effect
captureValue !byte 20,40,80,160
savedActor !byte 0
fruitScores !byte 10,30,50
