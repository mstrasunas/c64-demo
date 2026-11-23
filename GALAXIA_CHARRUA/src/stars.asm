!zone starfield
; Un carácter por subposición (ocho filas por ocho columnas). Las estrellas
; comparten glifos inmutables y avanzan entre celdas en coordenadas de píxel.
starCount = 32
skyHeight = 176
starChar = 160
starRowsLo !for i,0,skyHeight-1 { !byte <(screen+120+(i/8)*40) }
starRowsHi !for i,0,skyHeight-1 { !byte >(screen+120+(i/8)*40) }
starInitialY !byte 5,109,48,160,27,93,119,60,14,145,69,101,42,134,7,75,156,55,88,19,122,36,165,79,113,11,141,51,98,32,151,67
; Separación mínima de ocho píxeles: dos estrellas nunca necesitan la misma celda.
starCol !for i,0,starCount-1 { !byte (8+i*10+(i mod 2))/8 }
starBit !for i,0,starCount-1 { !byte (8+i*10+(i mod 2)) & 7 }
starColor !for i,0,7 { !byte 3,6,4,1 }
starY !fill starCount
oldRowLo !fill starCount
oldRowHi !fill starCount
oldCol !fill starCount

initStars
 ldx #0
- lda skyGlyphs,x
 sta chars+starChar*8,x
 lda skyGlyphs+256,x
 sta chars+starChar*8+256,x
 inx
 bne -
 ldx #starCount-1
- lda starInitialY,x
 sta starY,x
 lda #0
 sta oldRowHi,x
 dex
 bpl -
 rts

stars
 ldx #starCount-1
.loop
 ; Un enemigo o texto puede haberse dibujado encima desde el último cuadro.
 lda oldRowHi,x
 beq .advance
 sta ptr+1
 lda oldRowLo,x
 sta ptr
 ldy oldCol,x
 lda (ptr),y
 cmp #starChar
 bcc .advance
 cmp #starChar+64
 bcs .advance
 lda #32
 sta (ptr),y
.advance
 ; Dos planos: un píxel por cuadro y un píxel cada dos cuadros.
 txa
 and frame
 and #1
 bne .place
 inc starY,x
 lda starY,x
 cmp #skyHeight
 bcc .place
 lda #0
 sta starY,x
.place
 ldy starY,x
 lda starRowsLo,y
 sta ptr
 sta colptr
 sta oldRowLo,x
 lda starRowsHi,y
 sta ptr+1
 sta oldRowHi,x
 clc
 adc #$94
 sta colptr+1
 ; Compensar el scroll fino de la V sólo dentro de su banda de raster.
 lda starBit,x
 cpy #96
 ldy starCol,x
 bcs .pixel
 sec
 sbc fineX
 bcs .pixel
 dey
.pixel and #7
 sta tempByte
 tya
 sta oldCol,x
 lda (ptr),y
 cmp #32
 bne .next
 lda starY,x
 and #7
 asl
 asl
 asl
 ora tempByte
 clc
 adc #starChar
 sta (ptr),y
 lda starColor,x
 sta (colptr),y
.next dex
 bmi +
 jmp .loop
+
 rts

skyGlyphs
!for row,0,7 {
 !for col,0,7 {
  !for line,0,7 {
   !if line=row { !byte 128 >> col } else { !byte 0 }
  }
 }
}
