!cpu 6510
*=$0801
!word basicEnd
!word 10
!byte $9e
!text "2061"
!byte 0
basicEnd !word 0
*=$080d
start
 sei
 cld
 lda #$7f
 sta $dc0d
 lda $dc0d
 lda $dd0d
 lda #$37
 sta $01
 jsr initVic
 ldx #stateEnd-state-1
 lda #0
- sta state,x
 dex
 bpl -
 jsr silence
 jsr title
 lda #<irq
 sta $0314
 lda #>irq
 sta $0315
 lda #250
 sta $d012
 lda #1
 sta $d019
 sta $d01a
 cli
frameWait
 lda frame
 cmp lastFrame
 beq frameWait
 sta lastFrame
 jsr controls
 lda mode
 beq titleTick
 cmp #2
 beq overTick
 jsr gameTick
 jmp frameWait
titleTick
 jsr titleAnim
 jsr music
 jsr trigger
 bcc frameWait
 jsr newGame
 jmp frameWait
overTick
 jsr blastTick
 jsr audioTick
 jsr stars
 jsr trigger
 bcc .idle
 jsr newGame
 jmp frameWait
.idle
 dec idleLo
 bne frameWait
 dec idleHi
 bne frameWait
 jsr silence
 jsr title
 jmp frameWait
; KERNAL salva A/X/Y antes de saltar por $0314. Sin escaneo de teclado ROM.
irq
 lda #1
 sta $d019
 inc frame
 pla
 tay
 pla
 tax
 pla
 rti
trigger
 lda keys
 and #16
 bne .pressed
 sta latch
 clc
 rts
.pressed
 lda latch
 bne .held
 inc latch
 sec
 rts
.held
 clc
 rts
!source "src/vic.asm"
!source "src/sprites.asm"
!source "src/player.asm"
!source "src/enemies.asm"
!source "src/collisions.asm"
!source "src/game.asm"
!source "src/sound.asm"
!source "src/data.asm"
