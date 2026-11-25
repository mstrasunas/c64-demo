video_init:
    lda #$0b
    sta $d011           ; Ocultar el dibujo hasta terminar.
    lda $dd00
    and #%11111100
    ora #2              ; Banco VIC 1 ($4000-$7fff).
    sta $dd00
    lda $dd02
    ora #3
    sta $dd02
    lda #$12            ; Matriz $4400, caracteres $4800.
    sta $d018
    lda #$18            ; 40 columnas, multicolor.
    sta $d016
    lda #0
    sta $d015
    sta $d01a
    sta $d020
    sta $d021
    lda #6
    sta $d022
    lda #12
    sta $d023
    rts

; Línea PAL 252: por debajo de la imagen, antes del siguiente fotograma.
; Comprobar el bit 8 distingue la línea completa aun al arrancar.
wait_frame:
    lda $d011
    bmi wait_frame
    lda $d012
    cmp #252
    bne wait_frame
.leave:
    cmp $d012
    beq .leave
    rts
