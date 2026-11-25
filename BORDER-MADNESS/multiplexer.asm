.label patch=$02
prepare:
    lda bankXor
    eor #$c0
    sta bankXor
    cmp #$80
    lda #0
    rol
    sta workPage
    asl
    asl
    asl
    asl
    sta oldBias+1
    sta newBias+1
    sta initBias+1
    jsr restoreHooks
    // The IRQ advances the live positions. Snapshot all sixteen atomically.
snapshot:
    ldx physicalFrames
    .for(var i=0;i<16;i++) {
        lda py+i
        sta snapY+i
        lda px+i
        sta snapX+i
        lda hi+i
        sta snapH+i
    }
    cpx physicalFrames
    beq snapshotDone
    jmp snapshot
snapshotDone:
    inc frame
    jsr sortY
    // Restore the harmless store targets in last frame's reused slots.
    ldy workPage
    ldx oldCount,y
    beq cleared
undo:
    dex
    txa
    clc
oldBias: adc #0
    tay
    lda oldLines,y
    tay
    lda lineLo,y
    sta patch
    lda lineHi,y
    eor bankXor
    sta patch+1
    .for(var n=0;n<3;n++) {
        ldy #n*stride
        lda #$50
        sta (patch),y
        iny
        lda #8
        sta (patch),y
    }
    cpx #0
    bne undo
cleared:
    lda #0
    ldy workPage
    sta oldCount,y
    sta used
    sta mask
    sta cursor
    sta nextSlot
    lda #$ff
    sta candidate
    sta best
    ldx #0
    stx sortIndex
    // Give one previously rejected object a guaranteed slot, rotating by ID.
    ldx champion
    bmi next
    ldy #7
    jsr initial
next:
    ldx sortIndex
    lda order,x
    tax
    cpx champion
    beq advance
    lda used
    cmp capacity
    bcs reuse
    tay
    jsr initial
    inc used
    jmp advance
reuse:
    lda cursor
    bne haveCursor
    lda snapY,x
    sec
    sbc #19
    sta cursor
haveCursor:
    ldy nextSlot
    lda release,y
    cmp cursor
    bcs !+
    lda cursor
!:  cmp #47
    bcc !+
    cmp #50
    bcs !+
    lda #50
!:  cmp #245
    bcs dropped
    sta eventLine
    clc
    adc #9
    cmp snapY,x
    bcs dropped
    sbc #5
    sta cursor
    jsr rewrite
    inc nextSlot
    lda nextSlot
    cmp capacity
    bcc advance
    lda #0
    sta nextSlot
    beq advance
dropped:
    txa
    sec
    sbc frame
    and #15
    cmp best
    bcs advance
    sta best
    stx candidate
advance:
    inc sortIndex
    lda sortIndex
    cmp #16
    beq !+
    jmp next
!:
    ldy workPage
    lda mask
    sta displayMask,y
    lda candidate
    sta champion
    ldx #8
    cmp #$ff
    beq !+
    dex
!:  stx capacity
    jmp buildSegments
sortY:
    ldx #1
outer:
    lda order,x
    sta key
    sec
    sbc frame
    and #15
    sta keyRank+1
    ldy key
    lda snapY,y
    sta cmpKey+1
    txa
    tay
inner:
    dey
    ldx order,y
    lda snapY,x
cmpKey: cmp #0
    bcc insert
    bne shiftEntry
    txa
    sec
    sbc frame
    and #15
keyRank: cmp #0
    bcc insert
shiftEntry:
    txa
    sta order+1,y
    tya
    bne inner
    lda key
    sta order
    jmp sortedKey
insert:
    lda key
    sta order+1,y
sortedKey:
    ldx outerIndex
    inx
    stx outerIndex
    cpx #16
    bcc outer
    lda #1
    sta outerIndex
    rts
attributes:
    sty slot
    lda snapH,x
    beq lowSide
    lda snapX,x
    cmp #55
    bcc inside
    bcs edge
lowSide:
    lda snapX,x
    cmp #36
    bcs inside
edge:
    lda snapY,x
    sec
    ldy yPhaseHi,x
    cpy #56
    bcs upward
    sec
    sbc #2
    jmp clampEdge
upward:
    sec
    sbc #9
clampEdge:
    cmp #24
    bcs !+
    lda #24
!:  pha
    tay
    lda chunkNo,y
    tay
    lda #1
    sta chunk,y
    sta chunk+1,y
    sta chunk+2,y
    sta chunk+3,y
    pla
    and #7
    cmp #2
    bcc inside
    lda #1
    sta chunk+4,y
inside:
    ldy slot
    lda snapY,x
    clc
    adc #29
    bcc !+
    lda #255
!:  sta release,y
    rts
initial:
    jsr attributes
    tya
    clc
initBias: adc #0
    tay
    txa
    sta initId,y
    ldy slot
    lda mask
    ora bits,y
    sta mask
    rts
rewrite:
    jsr attributes
    ldy eventLine
    lda lineLo,y
    sta patch
    lda lineHi,y
    eor bankXor
    sta patch+1
    lda chunkNo,y
    tay
    lda #1
    sta chunk,y
    lda eventLine
    and #7
    cmp #6
    bcc !+
    lda #1
    sta chunk+1,y
!:
    ldy workPage
    lda oldCount,y
    tax
    clc
newBias: adc #0
    pha
    and #7
    asl
    ora newBias+1
    tay
    lda patch
    sta $e0,y
    lda patch+1
    sta $e1,y
    pla
    tay
    lda slot
    sta reuseSlot,y
    lda eventLine
    sta oldLines,y
    tya
    pha
    inx
    txa
    ldy workPage
    sta oldCount,y
    ldy sortIndex
    ldx order,y
    pla
    tay
    txa
    sta reuseId,y
    .for(var n=0;n<3;n++) {
        ldy #n*stride
        lda #$a9
        sta (patch),y
    }
    ldy #2*stride+9
    lda #2
    sta (patch),y
    .for(var n=0;n<5;n++) {
        .var off=floor(n/2)*stride+mod(n,2)*5
        .if(n==1) {
            lda colours,x
            ldy #off+1
            sta (patch),y
        }
        ldy slot
        .if(n==0) {lda xreg,y}
        .if(n==1) {lda creg,y}
        .if(n==2) {lda preg,y}
        .if(n==3) {lda #$10}
        .if(n==4) {lda yreg,y}
        ldy #off+3
        sta (patch),y
        iny
        .if(n==2) {lda #7} else {lda #$d0}
        sta (patch),y
    }
    rts
// Sparse raster execution. Patch one exit at each end of a run; all writes
// below target the inactive program. Each buffer owns its undo list.
restoreHooks:
    ldx workPage
    lda hookCount,x
    beq hooksDone
    sta lastChunk
    lda #0
    sta hookCount,x
    jsr pageOffset
    tax
restoreHook:
    ldy hooks,x
    lda hookLo,y
    sta patch
    lda hookHi,y
    eor bankXor
    sta patch+1
    ldy #0
    lda #$50
    sta (patch),y
    iny
    lda #8
    sta (patch),y
    iny
    lda #$8d
    sta (patch),y
    inx
    dec lastChunk
    bne restoreHook
hooksDone:
    ldx #30
    lda #0
!:  sta chunk,x
    dex
    bpl !-
    rts
pageOffset:
    lda workPage
    asl
    asl
    asl
    asl
    rts
buildSegments:
    lda #1
    sta chunk+3
    sta chunk+28
    jsr pageOffset
    sta startOffset+1
    sta hookOffset+1
    ldx workPage
    lda #0
    sta counts,x
    sta lastChunk
    ldx #0
chunks:
    lda chunk,x
    cmp lastChunk
    beq chunkDone
    sta lastChunk
    txa
    asl
    asl
    asl
    clc
    adc #firstLine
    sta chunkLine
    tay
    lda lineLo,y
    sta patch
    lda lineHi,y
    // For raster >=256 the line table wraps, requiring another 16 KB.
    cpx #29
    bcc !+
    clc
    adc #$40
!:  eor bankXor
    sta patch+1
    lda lastChunk
    beq hook
    ldy workPage
    lda counts,y
    clc
startOffset: adc #0
    tay
    lda chunkLine
    sta starts,y
    lda patch
    sta startsLo,y
    lda patch+1
    sta startsHi,y
    ldy workPage
    lda counts,y
    clc
    adc #1
    sta counts,y
    bne chunkDone
hook:
    ldy #0
    lda #$4c
    sta (patch),y
    iny
    lda #<leaveStream
    sta (patch),y
    iny
    lda #>leaveStream
    sta (patch),y
    ldy workPage
    lda hookCount,y
    clc
hookOffset: adc #0
    tay
    txa
    sta hooks,y
    ldy workPage
    lda hookCount,y
    clc
    adc #1
    sta hookCount,y
chunkDone:
    inx
    cpx #31
    beq !+
    jmp chunks
!:
    rts
chunkLine: .byte 0
