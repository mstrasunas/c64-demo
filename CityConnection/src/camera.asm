!zone scrolling
camera: !word 0
coarse: !byte 255
fine: !byte $10
active_page: !byte $12
dirty_level: !byte 255
dirty_column: !byte 0
camera_update:
    sec
    lda player_x
    sbc #148
    tay
    lda player_x+1
    sbc #0
    bcs +
    lda #0
    tay
+   cmp #3
    bcc .save
    bne .end
    cpy #192
    bcc .save
.end:
    lda #3
    ldy #192
.save:
    sty camera
    sta camera+1
    tya
    eor #255
    clc
    adc #1
    and #7
    ora #$10
    sta fine
    lda camera
    clc
    adc #7
    sta $fb
    lda camera+1
    adc #0
    lsr
    ror $fb
    lsr
    ror $fb
    lsr
    ror $fb
    ldx $fb
    cpx coarse
    bne +
    rts
+
    stx coarse
    lda active_page
    eor #$10
    sta active_page
    cmp #$02
    bne +
    jmp .first
+
    ldy #0
.second:
!for r,4,24 {
    lda world+r*160,x
    sta $4400+r*40,y
}
    inx
    iny
    cpy #40
    beq +
    jmp .second
+
    rts
.first:
    ldy #0
.copy:
!for r,4,24 {
    lda world+r*160,x
    sta $4000+r*40,y
}
    inx
    iny
    cpy #40
    beq +
    jmp .copy
+
.done:
    rts

patch_paint:
    ldx dirty_level
    bmi .return
    lda dirty_column
    sec
    sbc coarse
    cmp #40
    bcs .return
    tay
    lda rows_lo,x
    sta $fb
    lda active_page
    and #$10
    lsr
    lsr
    ora rows_hi,x
    sta $fc
    lda road_tiles+1
    sta ($fb),y
.return:
    rts
rows_lo: !for r,0,3 { !byte <($4000+(8+5*r)*40) }
rows_hi: !for r,0,3 { !byte >($4000+(8+5*r)*40) }
