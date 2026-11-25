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
    jsr player_init
    lda #$1b
    sta $d011
frame:
    jsr wait_frame
    jsr read_joystick
    jsr move_player
    jsr render_player
    jmp frame
!source "src/video.asm"
!source "src/scene.asm"
!source "src/player.asm"
!if * > $3000 { !error "Codigo fuera de su region" }
* = $3000
scene_data: !binary "build/scene.bin"
* = $4800
!binary "build/charset.bin"
* = $5000
car_sprites: !binary "build/car.bin"
