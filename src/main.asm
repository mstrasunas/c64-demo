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
    lda #$1b
    sta $d011
frame:
    jsr wait_frame
    jmp frame
!source "src/video.asm"
