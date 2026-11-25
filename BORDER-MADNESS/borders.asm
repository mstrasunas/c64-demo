// A double IRQ locks CIA1 timer A to the PAL raster. The timer is a modulo-63
// phase reference. A lookup compensates for DMA before the mid-line sample.
*=$2400 "PAL raster stream"
.const lastLine=271
irqOne:
    tsx
    stx savedSp+1
    inc $d012
    lda #<irqTwo
    sta $fffe
    lda #>irqTwo
    sta $ffff
    lda #1
    sta $d019
    cli
    .fill 50,$ea
irqTwo:
savedSp: ldx #0
    txs
    lda #4
!:  cmp $d012
    bne !-
phaseWalk:
    cmp $d012
    bne phaseLocked
    clc
    adc #1
    .fill 23,$ea
    bit $ea
    jmp phaseWalk
phaseLocked:
    lda #0
    sta $dc0e
    lda #62
    sta $dc04
    lda #0
    sta $dc05
phasePad:
    .fill 11,$ea
    lda #$11
    sta $dc0e
    lda #1
    sta $d019

    lda #1
    sta ready
    jmp armBlank
// IRQs below can interrupt the planner at any instruction boundary.
.macro saveCpu() {
    pha
    txa
    pha
    tya
    pha
}
blankIrq:
    :saveCpu()
    lda #0
    sta $d015
    lda #$0b
    sta $d011
    lda $dc01
    and #$10
    cmp previousKey
    beq keyDone
    sta previousKey
    bne keyDone
    lda $d020
    eor #6
    sta $d020
keyDone:
    inc plannerAge
    lda ready
    beq repeatBuffer
    lda plannerAge
    cmp maxAge
    bcc !+
    sta maxAge
!:  lda #0
    sta plannerAge
    lda front
    eor #1
    sta front
    lda #0
    sta ready
    beq loadBank
repeatBuffer:
    inc misses
    bne loadBank
    inc misses+1
loadBank:
    inc physicalFrames
    bne !+
    inc physicalFrames+1
!:
    jsr move
    jsr musicPlay
    ldx #1
    lda step
    and #3
    bne !+
    lda tick
    cmp #3
    bcs !+
    ldx #7
!:  stx $d026
    lda front
    asl
    asl
    asl
    asl
    tay
    sty segment
    // Slot order makes eight RORs assemble the complete ninth-bit mask.
    .for(var i=0;i<8;i++) {
        ldx initId+i,y
        lda px,x
        sta $d000+2*i
        lda py,x
        sta $d001+2*i
        lda currentPtr,x
        sta $07f8+i
        lda colours,x
        sta $d027+i
        lda hi,x
        lsr
        ror renderMask
    }
    lda renderMask
    sta $d010
    ldx front
    lda oldCount,x
    beq noEvents
    sta eventsLeft
    cpx #0
    beq refreshEven
    jmp refreshOdd
noEvents: jmp liveDone
refreshEven:
    :refreshEvents(0)
refreshOdd:
    :refreshEvents(16)
liveDone:
    ldx front
    lda counts,x
    sta segmentsLeft
    lda $d012
    sta finishLine
    lda displayMask,x
    sta $d015
nextSegment:
    ldx segment
    lda startsLo,x
    sta enterStream+1
    lda startsHi,x
    sta enterStream+2
    lda starts,x
    sta target+1
    sec
    sbc #1
    sta $d012
    lda #$0b
    ldx target+1
    beq !+
    cpx #16
    bcs !+
    ora #$80
!:  // Preserve DEN/RSEL, change just the raster compare high bit.
    and #$80
    sta upper+1
    lda vertical
upper: ora #0
    sta $d011
    lda #<bandIrq
    sta $fffe
    lda #>bandIrq
    sta $ffff
irqReturn:
    lda #1
    sta $d019
    pla
    tay
    pla
    tax
    pla
    rti
bandIrq:
    :saveCpu()
    clv
    ldy #8
target: lda #0
!:  cmp $d012
    bne !-
enterStream: jmp $4000
leaveStream:
    inc segment
    dec segmentsLeft
    beq endDisplay
    // Both D011 changes occur inside mandatory bands.
    bit $d011
    bmi bottom
    lda $d012
    cmp #249
    bcs bottom
    cmp #50
    bcc top
mid: lda #$1b
    bne setVertical
bottom: lda #$13
    bne setVertical
top: lda #$0b
setVertical: sta vertical
    jmp nextSegment
endDisplay:
    lda #$0b
    sta vertical
    lda #$8b
    sta $d011
    lda #<blankIrq
    sta $fffe
    lda #>blankIrq
    sta $ffff
    lda #18
    sta $d012
    jmp irqReturn
armBlank:
    lda #$8b
    sta $d011
    lda #18
    sta $d012
    lda #<blankIrq
    sta $fffe
    lda #>blankIrq
    sta $ffff
    rti
previousKey: .byte $10
vertical: .byte $0b
*=$4000 "Even raster program"
kernel:
:rasterProgram()
    jmp leaveStream
*=$8000 "Odd raster program"
:rasterProgram()
    jmp leaveStream
.macro rasterProgram() {
.for(var line=firstLine; line<=lastLine;line++) {
    .if (line==49 || line==248) {
        .if (line==49) {lda #$1b} else {lda #$13}
    } else {
        bvc !quiet+
    }
    .if(line==49 || line==248) {sta $d011} else {sta $0200}
    lda #0
    sta $0200
!quiet:
    nop
    ldx $dc04
    lda phaseDelay,x
    lsr
    sta !branch+ +1
    bcc !+
!:  
!branch: bvc !sled+
!sled:
    .fill 29,$ea
    dec $d016
    sty $d016
    jmp !next+
    .byte 0
!next:
}
}

.macro refreshEvents(bias) {
    .for(var i=0;i<8;i++) {
        ldx reuseId+bias+i
        ldy #1
        lda px,x
        sta ($e0+bias+i*2),y
        ldy #stride+1
        lda currentPtr,x
        sta ($e0+bias+i*2),y
        ldy #2*stride+1
        lda py,x
        sta ($e0+bias+i*2),y
        ldy reuseSlot+bias+i
        lda hi,x
        beq !low+
        lda renderMask
        ora bits,y
        bne !save+
!low:   lda renderMask
        and inverse,y
!save:  sta renderMask
        ldy #stride+6
        sta ($e0+bias+i*2),y
        dec eventsLeft
        bne !+
        jmp liveDone
!:
    }
    jmp liveDone
}
eventsLeft: .byte 0
