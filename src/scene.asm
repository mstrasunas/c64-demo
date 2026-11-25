; 3 páginas y una cola solapada de 256 bytes. Solo se escriben 1000
; celdas, preservando los punteros de sprites al final de la matriz.
draw_scene:
    ldx #0
.copy:
!for offset in [0, 256, 512, 744] {
    lda scene_data + offset,x
    sta screen + offset,x
    lda scene_data + 1000 + offset,x
    sta color_ram + offset,x
}
    inx
    bne .copy
    rts
