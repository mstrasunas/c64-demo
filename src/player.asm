; Mundo de una pantalla. Origen en la esquina superior izquierda del área
; visible. El VIC usa otro origen; solo render_player conoce esa diferencia.
max_x = 320 - 24
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
    lda #0
    sta player_x
    sta player_x+1
.done:
    rts
.left:
    lda player_x
    bne .decrement
    lda player_x+1
    beq .wrap
    dec player_x+1
.decrement:
    dec player_x
    rts
.wrap:
    lda #<max_x
    sta player_x
    lda #>max_x
    sta player_x+1
    rts

render_player:
    ; Cámara fija en (0,0). El bit 8 incluye el acarreo del desplazamiento.
    clc
    lda player_x
    adc #24
    sta $d000
    lda player_x+1
    adc #0
    sta $d010            ; Único sprite activo en esta etapa.
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
    sta screen+$3f8
    rts
