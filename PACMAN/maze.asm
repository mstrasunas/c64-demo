screenLo !for r,0,21 { !byte <($0400+125+40*r) }
screenHi !for r,0,21 { !byte >($0400+125+40*r) }
homeLo !for r,0,21 { !byte <(homeDirections+29*r) }
homeHi !for r,0,21 { !byte >(homeDirections+29*r) }
clearScreen
 ldx #0
- lda #0
 !for p,0,3 { sta $0400+p*250,x }
 lda #1
 !for p,0,3 { sta $d800+p*250,x }
 inx
 cpx #250
 bne -
 rts
paintBoard
 jsr clearScreen
 lda #<board
 sta ptr
 lda #>board
 sta ptr+1
 ldx #0
rowLoop
 lda screenLo,x
 sta dst
 lda screenHi,x
 sta dst+1
 ldy #28
- lda (ptr),y
 sta (dst),y
 cmp #66
 lda #10
 bcc +
 lda #14
+ pha
 lda dst+1
 clc
 adc #$d4
 sta dst+1
 pla
 sta (dst),y
 lda screenHi,x
 sta dst+1
 dey
 bpl -
 lda ptr
 clc
 adc #29
 sta ptr
 bcc +
 inc ptr+1
+ inx
 cpx #22
 bne rowLoop
 rts
; Carry set for a traversable neighbour. Direction order U,L,D,R.
probe
 ldy cx
 sty nx
 ldy cy
 sty ny
 cmp #1
 beq probeLeft
 bcc probeUp
 cmp #2
 beq probeDown
 inc nx
 lda nx
 cmp #29
 bne tileAt
 lda #0
 beq setNX
probeLeft
 dec nx
 bpl tileAt
 lda #28
setNX
 sta nx
 jmp tileAt
probeUp
 dec ny
 jmp tileAt
probeDown
 inc ny
tileAt
 ldy ny
 lda screenLo,y
 sta ptr
 lda screenHi,y
 sta ptr+1
 ldy nx
 lda (ptr),y
 cmp #63
 beq blocked
 cmp #66
 bcs blocked
 sec
 rts
blocked
 clc
 rts
