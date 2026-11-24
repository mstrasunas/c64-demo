newGame
 lda #1
 sta level
 lda #3
 sta lives
 lda #0
 ldx #5
- sta score,x
 dex
 bpl -
nextBoard
 jsr paintBoard
 lda #pellets
 sta remaining
 ldx level
 dex
 cpx #3
 bcc +
 ldx #2
+ stx fruitKind
 ldx level
 cpx #8
 bcc +
 ldx #8
+ lda speeds-1,x
 sta speed
 lda durations-1,x
 sta frightLength
 jsr hudLabels
 jsr resetActors
 jmp mainLoop
resetActors
 ldx #4
- lda initialX,x
 sta px,x
 lda initialY,x
 sta py,x
 lda delays,x
 sta release,x
 lda #0
 sta eaten,x
 sta fraction,x
 lda #1
 sta dirs,x
 dex
 bpl -
 lda #1
 sta want
 sta state
 sta scatter
 lda #0
 sta frightened
 sta fruitTime
 sta modeIndex
 lda #50
 sta second
 lda #7
 sta modeTime
 lda #75
 sta timer
 jsr hud
 ldx #4
- lda readyText,x
 sta banner+2,x
 dex
 bpl -
 jmp render
clearBanner
 ldx #8
 lda #0
- sta banner,x
 dex
 bpl -
 rts
clocks
 lda fruitTime
 beq +
 dec fruitTime
+ lda frightened
 beq modes
 dec frightened
 rts
modes
 dec second
 bne clockDone
 lda #50
 sta second
 lda modeIndex
 cmp #7
 beq clockDone
 dec modeTime
 bne clockDone
 inc modeIndex
 ldx modeIndex
 lda schedule,x
 sta modeTime
 lda scatter
 eor #1
 sta scatter
 jmp reverseGhosts
clockDone
 rts
banner=$0400+125+12*40+10
readyText !byte 50,37,33,36,57
initialX !byte 104,112,96,128,112
initialY !byte 128,64,80,80,80
delays !byte 0,0,50,130,215
speeds !byte 202,210,218,226,232,238,244,249
durations !byte 250,225,200,175,150,125,100,75
schedule !byte 7,20,7,20,5,20,5,255
level !byte 1
lives !byte 3
remaining !byte 0
speed !byte 0
frightLength !byte 0
frightened !byte 0
chain !byte 0
fruitTime !byte 0
scatter !byte 0
modeIndex !byte 0
modeTime !byte 0
second !byte 0
fruitKind !byte 0
