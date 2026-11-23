!zone tables
bitMask !byte 1,2,4,8,16,32,64,128
clearBit !byte 254,253,251,247,239,223,191,127
rowLo !for i,0,23 { !byte <(screen+(5+i/8*3)*40) }
rowHi !for i,0,23 { !byte >(screen+(5+i/8*3)*40) }
homeY !for i,0,23 { !byte 50+(5+i/8*3)*8 }
tileID !for i,0,23 { !byte 128+i/8*4 }
enemyColor !fill 8,15 : !fill 8,10 : !fill 8,13
award !fill 8,$40 : !fill 8,$30 : !fill 8,$20
starColors !byte 3,6,4,1
labels !scr " score      hi-score    lives     wave  "
overMsg !scr "game over"
sectorMsg !scr "wave     "
pressMsg !scr "press fire to start"
pressEnd
bob !byte 12,13,14,15,16,17,18,18,19,20,20,21,21,22,22,22,22,22,22,22,21,21,20,20,19,18,18,17,16,15,14,13,12,11,10,9,8,7,6,6,5,4,4,3,3,2,2,2,2,2,2,2,3,3,4,4,5,6,6,7,8,9,10,11
melody !byte 5,0,8,10,12,10,8,0,6,8,10,0,5,3,5,0,8,0,12,13,12,10,8,5,6,0,3,5,2,3,5,0
bass !byte 1,1,3,2,1,5,3,2
freqLo !byte 0,$68,$b1,$05,$a0,$87,$ce,$51,$80,$36,$d0,$20,$0e,$9c
freqHi !byte 0,$11,$13,$16,$17,$1a,$1d,$20,$23,$27,$29,$30,$35,$3b
!source "src/stars.asm"
state
frame !byte 0
lastFrame !byte 0
mode !byte 0
high !fill 3
digitPos !byte 0
savedX !byte 0
starPhase !byte 0
songPos !byte 0
keys !byte 0
latch !byte 0
runStart
score !fill 3
lives !byte 0
wave !byte 0
playerX !byte 0
immune !byte 0
cool !byte 0
shotX !byte 0
shotY !byte 0
alive !fill 24
remaining !byte 0
formation !byte 0
marchDir !byte 0
moveTimer !byte 0
marchDelay !byte 0
attackDelay !byte 0
diveTimer !byte 0
diver !byte 0
diveX !byte 0
diveY !byte 0
returning !byte 0
bombDir !byte 0
bombX !byte 0
bombY !byte 0
bombTimer !byte 0
bombSpeed !byte 0
targetX !byte 0
targetY !byte 0
height !byte 0
width !byte 0
victim !byte 0
blastTime !byte 0
seed !byte 0
waveBanner !byte 0
difficulty !byte 0
laserTime !byte 0
noiseTime !byte 0
diveTone !byte 0
tempByte !byte 0
carryX !byte 0
idleLo !byte 0
idleHi !byte 0
runEnd
stateEnd
enemyTiles !binary "src/enemigos.bin"
titleInk !binary "src/titulo.map"
!if * > screen { !error "Código invade el banco de video" }
*=spriteMem
!binary "src/sprites.bin"
*=bitmap
!binary "src/titulo.bin"
