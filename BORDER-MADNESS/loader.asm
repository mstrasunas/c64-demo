// BASIC-compatible compact load. Decompress backwards with all RAM visible.
#import "end.asm"
BasicUpstart2(unpack)
.label source=$f7
.label dest=$f9
.label match=$fb
unpack:
    sei
    cld
    lda #$34
    sta $01
    lda #<packedEnd-1
    sta source
    lda #>(packedEnd-1)
    sta source+1
    lda #<endAddress
    sta dest
    lda #>endAddress
    sta dest+1
    ldy #0
token:
    jsr readByte
    bmi backref
    tax
    inx
literal:
    jsr readByte
    jsr outputByte
    dex
    bne literal
    beq checkEnd
backref:
    and #127
    clc
    adc #3
    tax
    jsr readByte
    sta match
    jsr readByte
    sta match+1
    clc
    lda dest
    adc match
    sta match
    lda dest+1
    adc match+1
    sta match+1
copy:
    lda (match),y
    jsr outputByte
    lda match
    bne !+
    dec match+1
!:  dec match
    dex
    bne copy
checkEnd:
    lda dest+1
    cmp #$10
    bcs token
    lda #$35
    sta $01
    jmp $1000
readByte:
    lda (source),y
    pha
    lda source
    bne !+
    dec source+1
!:  dec source
    pla
    rts
outputByte:
    sta (dest),y
    lda dest
    bne !+
    dec dest+1
!:  dec dest
    rts
*=$0900 "Packed payload"
.import binary "payload.bin"
packedEnd:
.assert "BASIC load fits below ROM",packedEnd<$a000,true
