// Standalone PAL player with fixed init/play jump table.
*=$c000 "Undercurrent | SID"
    jmp musicInit
    jmp musicPlay
musicInit:
    lda #0
    ldx #24
!:  sta $d400,x
    dex
    bpl !-
    ldx #stateEnd-state-1
!:  sta state,x
    dex
    bpl !-
    lda #$1f
    sta $d418
    rts
musicPlay:
    lda tick
    bne pitched
    ldx bar
    lda roots,x
    sta root
    lda sections,x
    asl
    asl
    asl
    asl
    ora step
    tay
    lda leadSeq,y
    cmp #$ff
    beq holdLead
    pha
    lda #$20
    sta $d404
    pla
    clc
    adc root
    tax
    lda freqLo,x
    sta goal
    lda freqHi,x
    sta goal+1
    lda step
    and #3
    cmp #3
    beq holdLead
    lda goal
    sta pitch
    lda goal+1
    sta pitch+1
holdLead:
    ldx step
    lda bassSeq,x
    clc
    adc root
    sta bassNote
    ldy bar
    lda drumBank,y
    ora step
    tay
    lda drums,y
    sta drum
    lda #$40
    sta $d40b
    lda #$10
    sta $d412
pitched:
    inc lfo
    ldx lfo
    lda sweep,x
    sta $d416
    lda resonance,x
    sta $d417
    // Exponential portamento in signed 16-bit arithmetic.
    sec
    lda goal
    sbc pitch
    sta delta
    lda goal+1
    sbc pitch+1
    cmp #$80
    ror
    ror delta
    cmp #$80
    ror
    ror delta
    tax
    clc
    lda delta
    adc pitch
    sta pitch
    txa
    adc pitch+1
    sta pitch+1
    ldx lfo
    lda vibrato,x
    clc
    adc pitch
    sta $d400
    lda pitch+1
    adc vibSign,x
    sta $d401
    ldx bar
    ldy sections,x
    lda tick
    beq envelopeEnd
    tax
    lda leadWave,y
    sta $d404
    lda bassWave,x
    sta $d40b
envelopeEnd:
    lda leadAD,y
    sta $d405
    lda leadSR,y
    sta $d406
    lda #$08
    sta $d40c
    lda #$a5
    sta $d40d
    ldx tick
    lda arp,x
    clc
    adc bassNote
    tax
    lda freqLo,x
    sta $d407
    lda freqHi,x
    sta $d408
    // Pulse width uses $d409/$d40a.
    ldx lfo
    lda pulse,x
    sta $d40a
    lda lfo
    asl
    asl
    asl
    sta $d409
    ldx tick
    lda drum
    beq beatDone
    tay
    lda drumAD-1,y
    sta $d413
    lda drumSR-1,y
    sta $d414
    cpy #1
    bne noise
    lda kickHi,x
    sta $d40f
    lda #$55
    sta $d40e
    lda kickWave,x
    jmp gateDrum
noise:
    lda noiseHi,x
    cpy #3
    bne !+
    lsr
!:
    sta $d40f
    lda noiseWave,x
gateDrum:
    sta $d412
beatDone:
    inc tick
    lda tick
    cmp #6
    bcc musicDone
    lda #0
    sta tick
    inc step
    lda step
    cmp #16
    bcc musicDone
    lda #0
    sta step
    inc bar
    lda bar
    and #63
    sta bar
musicDone:
    rts
#import "instruments.asm"
#import "music_data.asm"
state:
tick: .byte 0
step: .byte 0
bar: .byte 0
lfo: .byte 0
goal: .word 0
pitch: .word 0
delta: .byte 0
drum: .byte 0
root: .byte 0
bassNote: .byte 0
stateEnd:
musicEnd:
