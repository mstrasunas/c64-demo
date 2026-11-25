!zone painting
paint_contact:
    jsr road_under
    cmp #1
    bne .done
    lda #2
    sta ($fb),y
    lda world_lo,x
    sta $fb
    lda world_hi,x
    sta $fc
    lda road_tiles+1
    sta ($fb),y
    stx dirty_level
    sty dirty_column
    lda remaining
    bne +
    dec remaining+1
+   dec remaining
    jsr progress
    lda remaining
    ora remaining+1
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
    lda #<percent_table
    sta $fb
    lda #>percent_table
    clc
    adc remaining+1
    sta $fc
    ldy remaining
    lda ($fb),y
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
percent_table: !binary "build/percent.bin"
digits: !binary "build/digits.bin"
clear_text: !binary "build/clear.bin"
