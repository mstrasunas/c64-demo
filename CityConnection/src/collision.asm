!zone collision
; Barrido vertical de los pies entre ambos cuadros, de arriba abajo.
collide:
    ldx #0
.loop:
    lda heights,x
    sec
    sbc #17
    cmp old_y
    bcc .next
    cmp player_y
    beq .test
    bcs .next
.test:
    jsr road_under
    beq .next
    lda heights,x
    sec
    sbc #17
    sta player_y
    stx grounded
    lda #0
    sta velocity
    jmp paint_contact
.next:
    inx
    cpx #4
    bne .loop
    lda player_y
    cmp #205
    bcc .safe
    jmp spawn
.safe:
    rts
road_under:
    lda state_lo,x
    sta $fb
    lda state_hi,x
    sta $fc
    ldy column
    lda ($fb),y
    rts
