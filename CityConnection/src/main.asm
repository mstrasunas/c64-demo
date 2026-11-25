!cpu 6510
screen = $4400
color_ram = $d800
* = $0801
!word basic_end
!word 10
!byte $9e
!text "2061"
!byte 0
basic_end: !word 0

* = $080d
start:
    sei                 ; Poseemos el raster y el teclado KERNAL queda inactivo.
    jsr video_init
    jsr draw_scene
    jsr stage_init
    jsr camera_update
    jsr player_init
    lda #$1b
    sta $d011
frame:
    ; Línea 81, después del HUD y antes de la primera badline del campo.
    lda $d011
    bmi frame
    lda $d012
    cmp #81
    bne frame
    lda active_page
    sta $d018
    lda fine
    sta $d016
    jsr read_joystick
    lda #255
    sta dirty_level
    lda remaining
    ora remaining+1
    bne playing
    lda pressed
    and #16
    beq display
    jsr wait_frame
    lda #$0b
    sta $d011
    jsr draw_scene
    jsr stage_init
    jmp ready_view
playing:
    jsr move_player
    jsr physics
ready_view:
    jsr camera_update
display:
    jsr wait_frame
    jsr patch_paint
    jsr render_player
    lda #$12
    sta $d018
    lda #$18
    sta $d016
    lda #$1b
    sta $d011
    jmp frame
!source "src/camera.asm"
!source "src/video.asm"
!source "src/scene.asm"
!source "src/player.asm"
!source "src/map.asm"
!source "src/physics.asm"
!source "src/collision.asm"
!source "src/paint.asm"
!if * > $3000 { !error "Codigo fuera de su region" }
* = $3000
scene_data: !binary "build/scene.bin"
* = $4800
!binary "build/charset.bin"
* = $5000
car_sprites: !binary "build/car.bin"

*=$6000
world: !binary "build/world.bin"
