joystick
 lda $dc00
 lsr
 bcc joyUp
 lsr
 bcc joyDown
 lsr
 bcc joyLeft
 lsr
 bcs joyDone
 lda #3
 bne joySet
joyLeft
 lda #1
 bne joySet
joyDown
 lda #2
 bne joySet
joyUp
 lda #0
joySet
 sta want
joyDone
 rts
position
 lda px,x
 lsr
 lsr
 lsr
 sta cx
 lda py,x
 lsr
 lsr
 lsr
 sta cy
 lda px,x
 ora py,x
 and #7
 rts
movePlayer
 ldx #0
 jsr position
 beq playerCentre
 lda dirs
 eor #2
 cmp want
 bne playerStep
 sta dirs
 jmp playerStep
playerCentre
 lda want
 jsr probe
 bcc +
 lda want
 sta dirs
+ lda dirs
 jsr probe
 bcc playerIdle
playerStep
 ldx #0
 jsr advance
 jsr position
 beq +
 lda tick
 and #15
 bne playerIdle
 lda #2
 jmp effect
+ lda cy
 sta ny
 lda cx
 sta nx
 jsr tileAt
 cmp #64
 beq eatDot
 cmp #65
 beq eatPower
playerIdle
 rts
eatPower
 lda frightLength
 sta frightened
 lda #0
 sta chain
 jsr reverseGhosts
 lda #3
 jsr effect
 lda #5
 bne addPellet
eatDot
 lda #1
 jsr effect
 lda #1
addPellet
 jsr addScore
 ldx #0
 jsr position
 lda cx
 sta nx
 lda cy
 sta ny
 jsr tileAt
 lda #0
 sta (ptr),y
 dec remaining
 beq boardDone
 lda remaining
 cmp #pellets-50
 beq spawnFruit
 cmp #pellets-110
 bne playerIdle
spawnFruit
 lda #250
 sta fruitTime
 rts
boardDone
 lda #5
 sta state
 lda #90
 sta timer
 lda #7
 jmp effect
advance
 lda dirs,x
 beq stepUp
 cmp #1
 beq stepLeft
 cmp #2
 beq stepDown
 inc px,x
 lda px,x
 cmp #232
 bne stepDone
 lda #0
 sta px,x
 rts
stepLeft
 dec px,x
 lda px,x
 cmp #255
 bne stepDone
 lda #231
 sta px,x
 rts
stepDown
 inc py,x
 rts
stepUp
 dec py,x
stepDone
 rts
px !fill 5
py !fill 5
dirs !fill 5
want !byte 1
