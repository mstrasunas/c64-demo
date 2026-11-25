; Mundo de una pantalla. Origen en la esquina superior izquierda del área
; visible. El VIC usa otro origen; solo render_player conoce esa diferencia.
max_x = 1248
car_ptr = ($5000 - $4000) / 64
player_x: !word 40
player_y: !byte 144
facing:   !byte 0        ; 0 derecha, 2 izquierda: pares de fotogramas.
wheel_clock: !byte 0

player_init:
    lda $dc02
    and #%11100000       ; Pines de dirección y fire como entradas.
    sta $dc02
    lda #0
    sta $dc03            ; Matriz de teclado en alta impedancia.
    sta $d017
    sta $d01d
    sta $d01b
    lda #1
    sta $d01c
    lda #3
    sta $d025
    lda #1
    sta $d026
    lda #2
    sta $d027
    jsr render_player
    lda #1
    sta $d015
    rts

read_joystick:
    lda $dc00
    tay
    eor #$ff
    and previous
    sta pressed
    sty previous
    tya
    and #%00001100       ; Activo a cero. Otras entradas no alteran el rumbo.
    cmp #8
    beq .left
    cmp #4
    bne .keep            ; Neutro y opuestas simultáneas conservan el sentido.
    lda #0
    beq .store
.left:
    lda #2
.store:
    sta facing
.keep:
    rts

!zone movement
move_player:
    inc wheel_clock
    lda facing
    bne .left
    inc player_x
    bne .limit
    inc player_x+1
.limit:
    lda player_x+1
    cmp #>max_x
    bne .done
    lda player_x
    cmp #<(max_x+1)
    bne .done
    dec player_x
.done:
    rts
.left:
    lda player_x+1
    bne .decrease
    lda player_x
    cmp #8
    beq .done
.decrease:
    lda player_x
    bne +
    dec player_x+1
+   dec player_x
    rts

render_player:
    sec
    lda player_x
    sbc camera
    tay
    lda player_x+1
    sbc camera+1
    tax
    tya
    clc
    adc #24
    sta $d000
    txa
    adc #0
    sta $d010
    clc
    lda player_y
    adc #50
    sta $d001
    lda wheel_clock
    lsr
    lsr
    lsr
    and #1
    ora facing
    clc
    adc #car_ptr
    sta $43f8
    sta screen+$3f8
    rts
