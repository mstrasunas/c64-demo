.label xPhaseLo=$10
.label xPhaseHi=$20
.label yPhaseLo=$30
.label px=$40
.label hi=$50
.label yPhaseHi=$60
.label py=$70
.label xSpeed=$80
.label ySpeed=$90
.label phase=$a0
.const firstLine=24
.const stride=64
// FULL BORDER MADNESS | PAL 63 cycles per line
BasicUpstart2(start)
*=$1000 "Bootstrap"
start:
    sei
    cld
    lda #$35
    sta $01
    lda #$7f
    sta $dc0d
    sta $dd0d
    lda $dc0d
    lda $dd0d
    lda #$03
    ora $dd02
    sta $dd02
    lda $dd00
    ora #3
    sta $dd00
    lda #$1b
    sta $d011
    lda #$1e
    sta $d018
    lda #8
    sta $d016
    lda #0
    sta $d020
    sta $d021
    sta $d015
    sta $d017
    sta $d01b
    sta $d01d
    sta $3fff
    ldx #0
clearScreen:
    .for(var p=0;p<4;p++) {
        lda titleScreen+p*256,x
        sta $0400+p*256,x
        lda titleColour+p*256,x
        sta $d800+p*256,x
    }
    inx
    bne clearScreen
    lda #$ff
    sta $dc02
    lda #0
    sta $dc03
    lda #$fe
    sta $dc00
    ldx #15
initMotion:
    lda initial_xPhaseLo,x
    sta xPhaseLo,x
    lda initial_xPhaseHi,x
    sta xPhaseHi,x
    lda initial_yPhaseLo,x
    sta yPhaseLo,x
    lda initial_yPhaseHi,x
    sta yPhaseHi,x
    lda initial_xSpeed,x
    sta xSpeed,x
    lda initial_ySpeed,x
    sta ySpeed,x
    lda initial_phase,x
    sta phase,x
    dex
    bpl initMotion
    jsr musicInit
    ldx #150
intro:
    bit $d011
    bpl intro
    bit $d011
    bmi *-3
    txa
    pha
    jsr musicPlay
    pla
    tax
    dex
    bne intro
    lda #$14
    sta $d018
    lda #$ff
    sta $d01c
    lda #11
    sta $d025
    lda #1
    sta $d026
    lda #0
    sta bankXor
    jsr move
    jsr prepare
    lda #<irqOne
    sta $fffe
    lda #>irqOne
    sta $ffff
    lda #<nmiExit
    sta $fffa
    lda #>nmiExit
    sta $fffb
    lda #16
    sta $d012
    lda #1
    sta $d019
    sta $d01a
    lda #1
    sta ready
    cli
idle:
    lda ready
    bne idle
    jsr prepare
    lda #1
    sta ready
    jmp idle
nmiExit: rti
#import "movement.asm"
#import "multiplexer.asm"
#import "sprites.asm"
#import "music.asm"
#import "borders.asm"
#import "tables.asm"
#import "title.asm"
