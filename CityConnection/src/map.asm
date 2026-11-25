!zone roads
width=160
layout: !binary "build/layout.bin"
road_state: !fill 640
heights: !byte 64,104,144,184
state_lo: !for i,0,3 { !byte <(road_state+i*width) }
state_hi: !for i,0,3 { !byte >(road_state+i*width) }
world_lo: !for i,0,3 { !byte <(world+(8+i*5)*width) }
world_hi: !for i,0,3 { !byte >(world+(8+i*5)*width) }
road_tiles: !binary "build/road.bin"
remaining: !word 0
column: !byte 0
stage_init:
    ; Filas de fondo uniformes: se preparan una vez en las dos matrices.
    ldy #39
.blank:
    lda #0
!for r in [20,21,22,24] {
    sta $4000+r*40,y
    sta $4400+r*40,y
}
    dey
    bpl .blank
    lda #0
    sta remaining
    sta remaining+1
    ldy #159
.copy:
!for i,0,3 {
    lda layout+i*width,y
    sta road_state+i*width,y
    beq +
    inc remaining
    bne ++
    inc remaining+1
++  lda road_tiles
    sta world+(8+i*5)*width,y
+
}
    dey
    cpy #255
    bne .copy
    lda #255
    sta coarse
    jsr spawn
    jmp progress
spawn:
    lda #40
    sta player_x
    lda #0
    sta player_x+1
    sta facing
    sta velocity
    sta quarter
    lda #167
    sta player_y
    lda #3
    sta grounded
    rts
