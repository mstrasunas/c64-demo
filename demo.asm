; Sprite Orbit. ACME assembly for the unexpanded PAL Commodore 64.
!cpu 6510

screen          = $0400
color_ram       = $d800
sprite_pointers = screen + $3f8
sprite_data     = $2000          ; Outside the VIC-II character ROM window
raster_line     = 252

; VIC-II coordinates of the fully visible top left of a 24 x 21 sprite.
min_x = 24
max_x = 24 + 320 - 24
min_y = 50
max_y = 50 + 200 - 21

* = $0801
    !word basic_end
    !word 10
    !byte $9e                    ; BASIC SYS
    !text "2061"
    !byte 0
basic_end:
    !word 0

start:
    sei
    cld
    lda #$7f
    sta $dc0d                    ; Mask CIA 1 IRQ and CIA 2 NMI sources
    sta $dd0d
    lda $dc0d                    ; Clear pending CIA interrupts
    lda $dd0d
    lda #0
    sta $d01a
    sta $d015
    sta $d011                    ; Blank the display during setup

    lda $dd00
    ora #3                       ; VIC bank 0 ($0000-$3fff)
    sta $dd00
    lda $dd02
    ora #3
    sta $dd02
    lda #$14                     ; Screen $0400 and upper-case ROM charset
    sta $d018
    lda #$08                     ; 40 columns, text in standard color mode
    sta $d016

    lda #6
    sta $d020
    lda #0
    sta $d021
    sta $d017                    ; Normal sprite height and width
    sta $d01d
    sta $d01b                    ; All sprites in front of text graphics
    lda #14
    sta $d025                    ; Shared colors for pixel codes 01 and 11
    lda #1
    sta $d026

    ldx #0
paint_screen:
    lda starfield,x
    sta screen,x
    lda starfield+$100,x
    sta screen+$100,x
    lda starfield+$200,x
    sta screen+$200,x
    lda starfield+$2e8,x
    sta screen+$2e8,x
    lda #12
    sta color_ram,x
    sta color_ram+$100,x
    sta color_ram+$200,x
    sta color_ram+$2e8,x
    inx
    bne paint_screen

    ldx #39
paint_labels:
    lda #3
    sta color_ram+40,x
    lda #14
    sta color_ram+23*40,x
    dex
    bpl paint_labels

    ldx #7
setup_sprites:
    txa
    clc
    adc #sprite_data/64
    sta sprite_pointers,x
    lda sprite_colors,x
    sta $d027,x
    dex
    bpl setup_sprites

    jsr publish_positions
    lda #$ff
    sta $d01c                    ; All eight sprites in multicolor mode
    sta $d015

    ; Use the hardware vectors in RAM and leave the VIC-II I/O visible.
    lda $00
    ora #$07
    sta $00
    lda #$35
    sta $01
    lda #<nmi
    sta $fffa
    lda #>nmi
    sta $fffb
    lda #<raster_irq
    sta $fffe
    lda #>raster_irq
    sta $ffff

    lda #$1b                     ; Display on, 25 rows, raster compare bit 8 = 0
    sta $d011
    lda #raster_line
    sta $d012
    lda #$0f
    sta $d019                    ; Clear any pending VIC-II requests
    lda #$01
    sta $d01a                    ; Raster IRQ only
    cli
idle:
    jmp idle

nmi:
    rti

raster_irq:
    pha
    txa
    pha
    tya
    pha
    lda #$01
    sta $d019                    ; Acknowledge the raster IRQ
    jsr move_sprites
    jsr publish_positions
    pla
    tay
    pla
    tax
    pla
    rti

; Positions are unsigned 16.8, velocities are signed 8.8 pixels per frame.
; On crossing an edge, mirror the overshoot and reverse velocity.
!macro move_axis .fraction, .integer, .page, .speed_lo, .speed_hi, .min, .max {
    ldy #0
    lda .speed_hi,x
    bpl .add
    dey                          ; Sign-extend negative velocity to 24 bits
.add:
    clc
    lda .fraction,x
    adc .speed_lo,x
    sta .fraction,x
    lda .integer,x
    adc .speed_hi,x
    sta .integer,x
    tya
    adc .page,x
    sta .page,x

    lda .integer,x
    cmp #<.min
    lda .page,x
    sbc #>.min
    bcc .reflect_min

    lda .fraction,x
    cmp #1                       ; Include any fractional overshoot past max
    lda .integer,x
    sbc #<.max
    lda .page,x
    sbc #>.max
    bcc .done

    ldy #<(.max * 2)
    lda #>(.max * 2)
    jmp .reflect
.reflect_min:
    ldy #<(.min * 2)
    lda #>(.min * 2)
.reflect:
    pha                          ; Position = 2 * edge - position
    sec
    lda #0
    sbc .fraction,x
    sta .fraction,x
    tya
    sbc .integer,x
    sta .integer,x
    pla
    sbc .page,x
    sta .page,x

    sec
    lda #0
    sbc .speed_lo,x
    sta .speed_lo,x
    lda #0
    sbc .speed_hi,x
    sta .speed_hi,x
.done:
}

move_sprites:
    ldx #7
move_next_sprite:
    jsr move_x
    jsr move_y
    dex
    bpl move_next_sprite
    rts

move_x:
    +move_axis x_fraction, x_integer, x_page, vx_fraction, vx_integer, min_x, max_x
    rts

move_y:
    +move_axis y_fraction, y_integer, y_page, vy_fraction, vy_integer, min_y, max_y
    rts

; Rebuild $D010 from all eight X coordinates. Insert each bit at bit 0
; while iterating from sprite 7 down to sprite 0.
publish_positions:
    lda #0
    sta x_msb_mask
    ldx #7
    ldy #14
publish_next_sprite:
    lda x_integer,x
    sta $d000,y
    lda y_integer,x
    sta $d001,y
    lda x_page,x
    lsr
    rol x_msb_mask
    dey
    dey
    dex
    bpl publish_next_sprite
    lda x_msb_mask
    sta $d010
    rts

x_msb_mask:  !byte 0
x_fraction:  !fill 8, 0
x_integer:   !byte <42, <115, <199, <286, <59, <141, <226, <302
x_page:      !byte >42, >115, >199, >286, >59, >141, >226, >302
y_fraction:  !fill 8, 0
y_integer:   !byte 78, 100, 69, 112, 182, 166, 198, 153
y_page:      !fill 8, 0

!macro velocities .v0, .v1, .v2, .v3, .v4, .v5, .v6, .v7 {
    !byte <.v0, <.v1, <.v2, <.v3, <.v4, <.v5, <.v6, <.v7
    !byte >.v0, >.v1, >.v2, >.v3, >.v4, >.v5, >.v6, >.v7
}
; 256 velocity units = one pixel per frame. Low and high arrays are adjacent.
vx_fraction: +velocities $150, -$0b0, $1c0, -$130, $0c8, -$190, $108, $17c
vx_integer = vx_fraction + 8
vy_fraction: +velocities $0a0, -$120, $0e8, -$0c0, $158, $080, -$164, -$098
vy_integer = vy_fraction + 8

sprite_colors: !byte 7, 10, 4, 3, 5, 8, 13, 2

!zone Graphics
starfield:
    !scr "           .                  .       . "
    !scr "   ---   vic-ii / sprite orbit   ---    "
    !scr "      .                 .           .   "
    !scr "                 .          .           "
    !scr "  .                            .        "
    !scr "        .            .                . "
    !scr "              .                         "
    !scr "   .                      .        .    "
    !scr "                  .                     "
    !scr "       .                        .       "
    !scr "  .                     .             . "
    !scr "            .                           "
    !scr "     .                      .           "
    !scr "                 .                  .   "
    !scr "         .           .                  "
    !scr "  .                             .       "
    !scr "                          .           . "
    !scr "      .                                 "
    !scr "               .             .          "
    !scr "  .                    .             .  "
    !scr "           .                    .       "
    !scr "     .             .                    "
    !scr "                          .          .  "
    !scr "   ---   8 sprites / pal 50 hz   ---    "
    !scr " .        .                  .        . "

!if * > sprite_data { !error "Program overlaps the sprite data" }
!fill sprite_data - *, 0

; 12 multicolor pixels per row, stored as three bytes.
; . = transparent, + = shared light blue, o = individual color, * = shared white.
sprite_rocket:
    !byte $00, $30, $00       ; .....*......
    !byte $00, $74, $00       ; ....+*+.....
    !byte $00, $74, $00       ; ....+*+.....
    !byte $00, $64, $00       ; ....+o+.....
    !byte $01, $ed, $00       ; ...+*o*+....
    !byte $01, $ad, $00       ; ...+oo*+....
    !byte $01, $fd, $00       ; ...+***+....
    !byte $01, $cd, $00       ; ...+*.*+....
    !byte $01, $fd, $00       ; ...+***+....
    !byte $01, $a9, $00       ; ...+ooo+....
    !byte $01, $a9, $00       ; ...+ooo+....
    !byte $06, $aa, $40       ; ..+ooooo+...
    !byte $06, $aa, $40       ; ..+ooooo+...
    !byte $06, $66, $40       ; ..+o+o+o+...
    !byte $06, $66, $40       ; ..+o+o+o+...
    !byte $04, $20, $40       ; ..+..o..+...
    !byte $00, $30, $00       ; .....*......
    !byte $00, $74, $00       ; ....+*+.....
    !byte $00, $74, $00       ; ....+*+.....
    !byte $00, $0c, $00       ; ......*.....
    !byte $00, $10, $00       ; .....+......
    !byte 0                     ; Pad to the next 64-byte sprite slot

sprite_planet:
    !byte $05, $50, $00       ; ..++++......
    !byte $16, $94, $00       ; .++oo++.....
    !byte $1a, $a9, $00       ; .+ooooo+....
    !byte $1a, $b9, $00       ; .+ooo*o+....
    !byte $1a, $fe, $40       ; .+oo***o+...
    !byte $1a, $ba, $40       ; .+ooo*oo+...
    !byte $16, $aa, $40       ; .++ooooo+...
    !byte $06, $aa, $94       ; ..+oooooo++.
    !byte $05, $aa, $7d       ; ..++oooo+**+
    !byte $1d, $a9, $f4       ; .+*+ooo+**+.
    !byte $75, $9f, $64       ; +*++o+**+o+.
    !byte $75, $f6, $a4       ; +*++**+ooo+.
    !byte $17, $5a, $a4       ; .++*++oooo+.
    !byte $05, $aa, $a4       ; ..++oooooo+.
    !byte $01, $6a, $94       ; ...++oooo++.
    !byte $00, $55, $50       ; ....++++++..
    !byte $00, $10, $00       ; .....+......
    !byte $00, $00, $00       ; ............
    !byte $00, $00, $c0       ; ........*...
    !byte $00, $00, $00       ; ............
    !byte $00, $00, $00       ; ............
    !byte 0                     ; Pad to the next 64-byte sprite slot

sprite_saucer:
    !byte $00, $00, $00       ; ............
    !byte $00, $30, $00       ; .....*......
    !byte $00, $10, $00       ; .....+......
    !byte $00, $64, $00       ; ....+o+.....
    !byte $01, $a9, $00       ; ...+ooo+....
    !byte $01, $b9, $00       ; ...+o*o+....
    !byte $01, $be, $40       ; ...+o**o+...
    !byte $01, $aa, $40       ; ...+oooo+...
    !byte $01, $55, $40       ; ...++++++...
    !byte $5a, $aa, $a5       ; ++oooooooo++
    !byte $7a, $eb, $ad       ; +*oo*oo*oo*+
    !byte $6a, $aa, $a9       ; +oooooooooo+
    !byte $15, $55, $54       ; .++++++++++.
    !byte $07, $55, $d0       ; ..+*++++*+..
    !byte $01, $55, $40       ; ...++++++...
    !byte $04, $14, $10       ; ..+..++..+..
    !byte $04, $14, $10       ; ..+..++..+..
    !byte $30, $14, $0c       ; .*...++...*.
    !byte $00, $14, $00       ; .....++.....
    !byte $00, $3c, $00       ; .....**.....
    !byte $00, $00, $00       ; ............
    !byte 0                     ; Pad to the next 64-byte sprite slot

sprite_crystal:
    !byte $00, $10, $00       ; .....+......
    !byte $00, $74, $00       ; ....+*+.....
    !byte $00, $7d, $00       ; ....+**+....
    !byte $01, $f9, $00       ; ...+**o+....
    !byte $01, $fa, $40       ; ...+**oo+...
    !byte $07, $ea, $40       ; ..+**ooo+...
    !byte $07, $fa, $90       ; ..+***ooo+..
    !byte $1f, $6a, $90       ; .+**+oooo+..
    !byte $1f, $6a, $a4       ; .+**+ooooo+.
    !byte $7d, $aa, $a4       ; +**+oooooo+.
    !byte $7d, $aa, $a9       ; +**+ooooooo+
    !byte $76, $aa, $a9       ; +*+oooooooo+
    !byte $1a, $aa, $a4       ; .+oooooooo+.
    !byte $1a, $9a, $90       ; .+ooo+ooo+..
    !byte $06, $a6, $90       ; ..+ooo+oo+..
    !byte $06, $9a, $40       ; ..+oo+oo+...
    !byte $01, $9a, $40       ; ...+o+oo+...
    !byte $01, $a9, $00       ; ...+ooo+....
    !byte $00, $69, $00       ; ....+oo+....
    !byte $00, $64, $00       ; ....+o+.....
    !byte $00, $14, $00       ; .....++.....
    !byte 0                     ; Pad to the next 64-byte sprite slot

sprite_invader:
    !byte $04, $00, $10       ; ..+......+..
    !byte $0c, $00, $30       ; ..*......*..
    !byte $01, $00, $40       ; ...+....+...
    !byte $03, $00, $c0       ; ...*....*...
    !byte $01, $55, $40       ; ...++++++...
    !byte $06, $aa, $90       ; ..+oooooo+..
    !byte $1a, $aa, $a4       ; .+oooooooo+.
    !byte $6b, $eb, $e9       ; +oo**oo**oo+
    !byte $6b, $eb, $e9       ; +oo**oo**oo+
    !byte $6a, $aa, $a9       ; +oooooooooo+
    !byte $69, $aa, $69       ; +oo+oooo+oo+
    !byte $65, $55, $59       ; +o++++++++o+
    !byte $64, $00, $19       ; +o+......+o+
    !byte $64, $00, $19       ; +o+......+o+
    !byte $64, $14, $19       ; +o+..++..+o+
    !byte $15, $00, $54       ; .+++....+++.
    !byte $01, $00, $40       ; ...+....+...
    !byte $03, $00, $c0       ; ...*....*...
    !byte $00, $00, $00       ; ............
    !byte $04, $00, $10       ; ..+......+..
    !byte $00, $00, $00       ; ............
    !byte 0                     ; Pad to the next 64-byte sprite slot

sprite_satellite:
    !byte $00, $03, $00       ; .......*....
    !byte $00, $0c, $00       ; ......*.....
    !byte $04, $30, $00       ; ..+..*......
    !byte $43, $c0, $00       ; +..**.......
    !byte $6f, $d0, $00       ; +o***+......
    !byte $7a, $40, $00       ; +*oo+.......
    !byte $15, $05, $50       ; .+++..++++..
    !byte $01, $56, $e4       ; ...++++o*o+.
    !byte $01, $a6, $e4       ; ...+oo+o*o+.
    !byte $15, $65, $a5       ; .++++o++oo++
    !byte $1a, $56, $a9       ; .+oo+++oooo+
    !byte $1a, $46, $a9       ; .+oo+.+oooo+
    !byte $15, $46, $a9       ; .++++.+oooo+
    !byte $1a, $46, $a9       ; .+oo+.+oooo+
    !byte $1a, $45, $55       ; .+oo+.++++++
    !byte $15, $45, $a5       ; .++++.++oo++
    !byte $00, $06, $64       ; ......+o+o+.
    !byte $00, $06, $64       ; ......+o+o+.
    !byte $00, $06, $64       ; ......+o+o+.
    !byte $00, $05, $54       ; ......+++++.
    !byte $00, $00, $00       ; ............
    !byte 0                     ; Pad to the next 64-byte sprite slot

sprite_comet:
    !byte $00, $00, $01       ; ...........+
    !byte $00, $00, $00       ; ............
    !byte $00, $00, $40       ; ........+...
    !byte $00, $00, $00       ; ............
    !byte $00, $01, $00       ; .......+....
    !byte $00, $00, $10       ; .........+..
    !byte $00, $04, $04       ; ......+...+.
    !byte $00, $10, $40       ; .....+..+...
    !byte $00, $11, $00       ; .....+.+....
    !byte $00, $55, $01       ; ....++++...+
    !byte $01, $50, $00       ; ...+++......
    !byte $05, $90, $50       ; ..++o+..++..
    !byte $16, $91, $00       ; .++oo+.+....
    !byte $1a, $94, $00       ; .+ooo++.....
    !byte $1b, $d0, $00       ; .+o**+......
    !byte $6b, $f4, $00       ; +oo***+.....
    !byte $6b, $f4, $00       ; +oo***+.....
    !byte $6a, $d0, $00       ; +ooo*+......
    !byte $6a, $40, $00       ; +ooo+.......
    !byte $15, $00, $00       ; .+++........
    !byte $00, $00, $00       ; ............
    !byte 0                     ; Pad to the next 64-byte sprite slot

sprite_robot:
    !byte $00, $30, $00       ; .....*......
    !byte $00, $10, $00       ; .....+......
    !byte $00, $10, $00       ; .....+......
    !byte $01, $55, $40       ; ...++++++...
    !byte $06, $aa, $90       ; ..+oooooo+..
    !byte $06, $eb, $90       ; ..+o*oo*o+..
    !byte $06, $eb, $90       ; ..+o*oo*o+..
    !byte $06, $aa, $90       ; ..+oooooo+..
    !byte $06, $55, $90       ; ..+o++++o+..
    !byte $05, $55, $50       ; ..++++++++..
    !byte $3d, $55, $7c       ; .**++++++**.
    !byte $65, $aa, $59       ; +o++oooo++o+
    !byte $65, $be, $59       ; +o++o**o++o+
    !byte $65, $be, $59       ; +o++o**o++o+
    !byte $65, $aa, $59       ; +o++oooo++o+
    !byte $30, $55, $0c       ; .*..++++..*.
    !byte $06, $41, $90       ; ..+o+..+o+..
    !byte $06, $41, $90       ; ..+o+..+o+..
    !byte $06, $41, $90       ; ..+o+..+o+..
    !byte $0f, $41, $f0       ; ..**+..+**..
    !byte $00, $00, $00       ; ............
    !byte 0                     ; Pad to the next 64-byte sprite slot
