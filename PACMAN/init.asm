start
 sei
 cld
 lda #$35
 sta $01
 lda #$7f
 sta $dc0d
 sta $dd0d
 lda $dc0d
 lda $dd0d
 lda #<raster
 sta $fffe
 lda #>raster
 sta $ffff
 lda #<nmi
 sta $fffa
 lda #>nmi
 sta $fffb
 lda $dd02
 ora #3
 sta $dd02
 lda $dd00
 ora #3
 sta $dd00
 lda #$18
 sta $d018
 lda #8
 sta $d016
 lda #$1b
 sta $d011
 lda #0
 sta $d020
 sta $d021
 sta $d017
 sta $d01d
 sta $d01b
 sta $d015
 sta $dc02
 lda #$3e
 sta $d01c
 lda #1
 sta $d025
 lda #6
 sta $d026
 lda #251
 sta $d012
 lda #1
 sta $d019
 sta $d01a
 lda $02a6
 sta pal
 jsr soundInit
 jsr title
 cli
mainLoop
 lda pending
 beq mainLoop
 lda #0
 sta pending
 inc tick
 jsr soundTick
 lda state
 beq menuTick
 cmp #4
 beq menuTick
 cmp #2
 beq playTick
 dec timer
 bne drawFrame
 cmp #1
 beq beginPlay
 cmp #3
 beq afterDeath
 lda level
 cmp #99
 bcs +
 inc level
+ jmp nextBoard
beginPlay
 jsr clearBanner
 lda #2
 sta state
 jmp drawFrame
menuTick
 lda state
 bne +
 jsr animateTitle
+ lda $dc00
 and #16
 beq +
 lda #0
 sta fireHeld
 jmp mainLoop
+ lda fireHeld
 bne mainLoop
 inc fireHeld
 jmp newGame
afterDeath
 dec lives
 beq gameOverJump
 jsr resetActors
 jmp mainLoop
gameOverJump
 jsr gameOver
 jmp mainLoop
playTick
 jsr joystick
 jsr movePlayer
 lda state
 cmp #2
 bne drawFrame
 jsr contacts
 lda state
 cmp #2
 bne drawFrame
 jsr moveGhosts
 jsr contacts
 lda state
 cmp #2
 bne drawFrame
 jsr clocks
drawFrame
 jsr render
 jmp mainLoop
state !byte 0
timer !byte 0
tick !byte 0
fireHeld !byte 0
