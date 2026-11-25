!zone painting
paint_contact:
    jsr road_under
    cmp #1
    bne .done
    lda #2
    sta road_state,y
    stx saved_level
    ldy column
    lda #1
    jsr draw_cell
    dec remaining
    jsr progress
    lda remaining
    bne .done
    ldx #10
.clear:
    lda clear_text,x
    sta screen+81,x
    lda #7
    sta color_ram+81,x
    dex
    bpl .clear
.done:
    rts
; División por acumulación de restos. El acarreo conserva el noveno bit.
progress:
    lda total
    sec
    sbc remaining
    sta painted_count
    lda #0
    ldx #100
    ldy #0
.loop:
    clc
    adc painted_count
    bcs .subtract
    cmp total
    bcc .carry_on
.subtract:
    sec
    sbc total
    iny
.carry_on:
    dex
    bne .loop
    tya
    ldy #0
    cmp #100
    bcc .tens
    iny
    sbc #100
.tens:
    ldx digits,y
    stx screen+112
    ldy #0
.divide:
    cmp #10
    bcc .show
    sbc #10
    iny
    bne .divide
.show:
    tax
    lda digits,y
    sta screen+113
    lda digits,x
    sta screen+114
    rts
painted_count: !byte 0
digits: !binary "build/digits.bin"
clear_text: !binary "build/clear.bin"
