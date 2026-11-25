!zone vertical
previous: !byte $ff
pressed: !byte 0
grounded: !byte 255
velocity: !byte 0
quarter: !byte 0
old_y: !byte 0
physics:
    ; Centro horizontal en 9 bits, luego división por ocho.
    clc
    lda player_x
    adc #12
    tay
    lda player_x+1
    adc #0
    lsr
    tya
    ror
    lsr
    lsr
    sta column
    ldx grounded
    bmi .air
    jsr road_under
    beq .fall
    lda pressed
    and #1
    bne .jump
    jmp paint_contact
.jump:
    lda #$fb
    sta velocity
.fall:
    lda #255
    sta grounded
    lda #0
    sta quarter
.air:
    inc quarter
    lda quarter
    and #3
    bne .step
    lda velocity
    cmp #6
    beq .step
    inc velocity
.step:
    lda player_y
    sta old_y
    clc
    adc velocity
    sta player_y
    ldx velocity
    bpl collide
    cmp #30
    bcs .done
    lda #30
    sta player_y
    lda #0
    sta velocity
.done:
    rts
