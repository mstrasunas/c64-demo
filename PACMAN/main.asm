!cpu 6510
*=$0801
!byte $0b,$08,10,0,$9e
!text "2061"
!byte 0,0,0
jmp start
*=$2000
charset
!source "charset.asm"
!if *> $2800 { !error "charset overflow" }
*=$3000
!source "sprites.asm"
!if *> $4000 { !error "sprite overflow" }
*=$4000
ptr=$fb
dst=$fd
cx=$02
cy=$03
nx=$04
ny=$05
actor=$06
targetX=$07
targetY=$08
tmp=$09
best=$0a
choice=$0b
candidate=$0c
!source "init.asm"
!source "irq.asm"
!source "maze.asm"
!source "pacman.asm"
!source "ghosts.asm"
!source "collision.asm"
!source "score.asm"
!source "levels.asm"
!source "sound.asm"
!source "title.asm"
!source "video.asm"
!source "board.inc"
endGame=*
!if endGame >= $a000 { !error "program overflow" }
