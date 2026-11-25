; Índices fijos: 1/2 patrullas, 3 gato, 4 disparo, 5..7 latas.
!zone actors
lives: !byte 3
ammo: !byte 5
score_hundreds: !byte 0
crash: !byte 0
shield: !byte 0
clock4: !byte 0
cat_clock: !byte 0
shot_left: !byte 0
active: !fill 8
ax: !fill 8
ah: !fill 8
ay: !fill 8
stun: !fill 3
direction: !fill 3
bits: !byte 1,2,4,8,16,32,64,128
starts_lo: !byte 0,<400,<912,0,0,80,<520,<1000
starts_hi: !byte 0,>400,>912,0,0,0,>520,>1000
starts_y: !byte 0,87,127,0,0,167,87,127
palette: !byte 2,6,6,8,7,7,7,7
pictures: !byte 0,$44,$44,$46,$47,$47,$47,$47
actors_init:
    lda #3
    sta lives
    lda #5
    sta ammo
    lda #0
    sta crash
    sta shield
    sta clock4
    sta cat_clock
    sta score_hundreds
    sta stun+1
    sta stun+2
    sta direction+1
    sta direction+2
    ldx #7
.init:
    lda starts_lo,x
    sta ax,x
    lda starts_hi,x
    sta ah,x
    lda starts_y,x
    sta ay,x
    lda #1
    sta active,x
    lda palette,x
    sta $d027,x
    dex
    bne .init
    stx active+3
    stx active+4
    lda #255
    sta $d01c
    jmp hud4

; Coordenadas de referencia para hitboxes centradas en los dibujos.
refx: !word 0
refy: !byte 0
radius: !byte 0
hit:
    sec
    lda ax,x
    sbc refx
    tay
    lda ah,x
    sbc refx+1
    beq .positive
    cmp #255
    bne .miss
    tya
    eor #255
    tay
    iny
    beq .miss
.positive:
    cpy radius
    bcs .miss
    sec
    lda ay,x
    sbc refy
    clc
    adc #9
    cmp #19
    rts                 ; C=0 indica contacto
.miss:
    sec
    rts

actors_tick:
    inc clock4
    lda shield
    beq +
    dec shield
+   inc cat_clock
    bne .cat_age
    lda #0
    sta active+3
    lda grounded
    cmp #4
    bcs .police
    tax
    lda column
    cmp #140
    bcc +
    sbc #23             ; C=1; al sumar 12 queda once columnas detrás
+   clc
    adc #12
    tay
    lda state_lo,x
    sta $fb
    lda state_hi,x
    sta $fc
    lda ($fb),y
    beq .police
    lda heights,x
    sec
    sbc #17
    sta ay+3
    tya
    ldx #0
    stx ah+3
!for i,1,3 { asl
    rol ah+3 }
    sec
    sbc #12
    sta ax+3
    lda ah+3
    sbc #0
    sta ah+3
    inc active+3
.cat_age:
    lda cat_clock
    cmp #128
    bne .police
    lda #0
    sta active+3
.police:
    ldx #2
.chase:
    lda active,x
    beq .next
    lda stun,x
    beq .walk
    dec stun,x
    jmp .next
.walk:
    lda clock4
    and #1
    bne .next
    lda player_x
    cmp ax,x
    lda player_x+1
    sbc ah,x
    lda #0
    bcs +
    lda #1
+   sta direction,x
    jsr patrol_step
.next:
    dex
    bne .chase
    lda pressed
    and #16
    beq .projectile
    lda ammo
    beq .projectile
    lda active+4
    bne .projectile
    inc active+4
    dec ammo
    jsr hud4
    lda player_x
    sta ax+4
    lda player_x+1
    sta ah+4
    lda player_y
    sta ay+4
    lda facing
    sta shot_left
.projectile:
    lda active+4
    beq .contacts
    lda #4
    ldy #0
    ldx shot_left
    beq +
    lda #252
    dey
+   clc
    adc ax+4
    sta ax+4
    sta refx
    tya
    adc ah+4
    sta ah+4
    sta refx+1
    cmp #5
    bcs .expire
    lda ay+4
    sta refy
    lda #14
    sta radius
    ldx #2
.shot_test:
    lda active,x
    beq +
    jsr hit
    bcs +
    lda #120
    sta stun,x
    bne .expire
+   dex
    bne .shot_test
    beq .contacts
.expire:
    lda #0
    sta active+4
.contacts:
    lda player_x
    sta refx
    lda player_x+1
    sta refx+1
    lda player_y
    sta refy
    lda #15
    sta radius
    ldx #7
.touch:
    cpx #4
    beq .advance
    lda active,x
    beq .advance
    jsr hit
    bcs .advance
    cpx #5
    bcc .hazard
    inc ammo
    jmp .remove
.hazard:
    cpx #3
    beq .damage
    lda stun,x
    beq .damage
    inc score_hundreds
.remove:
    lda #0
    sta active,x
    txa
    pha
    jsr hud4
    pla
    tax
    jmp .advance
.damage:
    lda shield
    bne .advance
    dec lives
    lda #32
    sta crash
    jmp hud4
.advance:
    dex
    bne .touch
    rts

; Prueba el centro de las ruedas antes de aceptar el siguiente píxel.
patrol_step:
    lda direction,x
    beq .right
    lda #255
    tay
    bne .candidate
.right:
    lda #1
    ldy #0
.candidate:
    clc
    adc ax,x
    sta refx
    tya
    adc ah,x
    sta refx+1
    lda refx
    clc
    adc #12
    sta $fd
    lda refx+1
    adc #0
!for i,1,3 { lsr
    ror $fd }
    ldy $fd
    lda state_lo,x       ; patrullas en niveles 1 y 2
    sta $fb
    lda state_hi,x
    sta $fc
    lda ($fb),y
    beq +
    lda refx
    sta ax,x
    lda refx+1
    sta ah,x
+   rts

crash_tick:
    dec crash
    bne .done
    lda lives
    beq .over
    jsr spawn
    lda #100
    sta shield
    lda #0
    sta active+3
    sta active+4
    rts
.over:
    ldx #8
.message:
    lda over_text,x
    sta screen+81,x
    lda #2
    sta color_ram+81,x
    dex
    bpl .message
.done:
    rts
over_text: !binary "build/over.bin"
hud4:
    ldx lives
    lda digits,x
    sta screen+62
    ldx ammo
    lda digits,x
    sta screen+74
    ldx score_hundreds
    lda digits,x
    sta screen+48
    rts

render_actors:
    lda #1
    sta visible
    lda lives
    ora crash
    beq .hide
    lda shield
    and #4
    beq +
.hide:
    dec visible
+   lda crash
    beq .begin
    and #4
    beq .begin
    lda #$48
    sta $43f8
    sta $47f8
.begin:
    ldx #7
.sprite:
    lda active,x
    beq .next_sprite
    sec
    lda ax,x
    sbc camera
    sta $fd
    lda ah,x
    sbc camera+1
    tay
    lda $fd
    clc
    adc #24
    sta $fd
    tya
    adc #0
    bmi .next_sprite
    beq .low
    cmp #1
    bne .next_sprite
    lda $fd
    cmp #88
    bcs .next_sprite
    lda $d010
    ora bits,x
    sta $d010
.low:
    txa
    asl
    tay
    lda $fd
    sta $d000,y
    lda ay,x
    clc
    adc #50
    sta $d001,y
    lda pictures,x
    cpx #3
    bcs .pointer
    lda stun,x
    beq .normal
    lda clock4
    lsr
    lsr
    and #1
    jmp .orient
.normal:
    lda direction,x
.orient:
    ora #$44
.pointer:
    sta $43f8,x
    sta $47f8,x
    lda visible
    ora bits,x
    sta visible
.next_sprite:
    dex
    bne .sprite
    lda visible
    sta $d015
    rts
visible: !byte 0
