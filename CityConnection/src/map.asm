; Una celda por columna mundial de 8 px. El escenario usa las columnas
; 1..38 alcanzables por el centro del coche. La matriz VIC es sólo una vista.
!zone roads
width = 40
layout:
!for level,0,3 {
  !for col,0,width-1 {
    !if col<1 | col>width-2 | (col>=8+level*4 & col<=10+level*4) | (col>=30-level*3 & col<=31-level*3) { !byte 0 } else { !byte 1 }
  }
}
road_state: !fill width*4
heights: !byte 64,104,144,184
offsets: !byte 0,width,width*2,width*3
rowlo: !for i,0,3 { !byte <(screen+320+200*i) }
rowhi: !for i,0,3 { !byte >(screen+320+200*i) }
road_tiles: !binary "build/road.bin"
remaining: !byte 0
total: !byte 0
column: !byte 0
stage_init:
    lda #0
    sta remaining
    ldx #width*4-1
.copy:
    lda layout,x
    sta road_state,x
    beq .skip
    inc remaining
.skip:
    dex
    cpx #255
    bne .copy
    lda remaining
    sta total
    ldx #3
.row:
    ldy #0
.col:
    tya
    clc
    adc offsets,x
    stx saved_level
    tax
    lda road_state,x
    ldx saved_level
    cmp #0
    beq .next
    lda #0
    jsr draw_cell
.next:
    iny
    cpy #40
    bne .col
    dex
    bpl .row
    jsr spawn
    jmp progress
saved_level: !byte 0
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
; A = estado gráfico, X = altura, Y = columna de la vista.
draw_cell:
    sta tile_index
    lda rowlo,x
    sta $fb
    lda rowhi,x
    sta $fc
    ldx tile_index
    lda road_tiles,x
    sta ($fb),y
    lda $fc
    clc
    adc #$94
    sta $fc
    lda inks,x
    sta ($fb),y
    ldx saved_level
    rts
inks: !byte 12,7
tile_index: !byte 0
