*=$e000 "Planner tables"
.align $100
lineLo: .fill 256,<(kernel+(i-firstLine)*stride)
lineHi: .fill 256,>(kernel+(i-firstLine)*stride)
bits: .fill 8,1<<i
inverse: .fill 8,255-(1<<i)
xreg: .fill 8,2*i
yreg: .fill 8,2*i+1
creg: .fill 8,$27+i
preg: .fill 8,$f8+i
order: .fill 16,i
.function vx(i) { .return (1-2*mod(i,2))*(112+mod(53*i,295)) }
.function vy(i) { .return (1-2*mod(floor(i/2),2))*(85+mod(41*i,247)) }
colours: .byte 3,10,7,14,8,13,4,5,15,2,6,12,3,10,7,14
oldLines: .fill 32,0
release: .fill 8,0
frame: .byte 0
champion: .byte $ff
capacity: .byte 8
sortIndex: .byte 0
outerIndex: .byte 1
key: .byte 0
best: .byte 0
oldCount: .byte 0,0
used: .byte 0
mask: .byte 0
cursor: .byte 0
nextSlot: .byte 0
candidate: .byte 0
slot: .byte 0
eventLine: .byte 0

bankXor: .byte 0
workPage: .byte 0
front: .byte 0
ready: .byte 0
misses: .word 0
chunk: .fill 36,0
hooks: .fill 32,0
hookCount: .byte 0,0
starts: .fill 32,0
startsHi: .fill 32,0
startsLo: .fill 32,0
counts: .byte 0,0
displayMask: .byte 0,0
segment: .byte 0
segmentsLeft: .byte 0
lastChunk: .byte 0
chunkNo: .fill 256,floor((i-firstLine)/8)
hookLo: .fill 31,<(kernel+i*8*stride)
hookHi: .fill 31,>(kernel+i*8*stride)

// Initial slope is encoded in the phase of each triangular trajectory.
.function xSeed(i) {
    .var x=mod(i*71+8,360)
    .return 64*(vx(i)<0 ? 767-x : x)+mod(i*11,64)
}
.function ySeed(i) {
    .var y=2+mod(i*71,219)
    .return 64*(vy(i)<0 ? 447-y : y)+mod(i*7,64)
}
initial_xPhaseLo: .fill 16,<xSeed(i)
initial_xPhaseHi: .fill 16,>xSeed(i)
initial_yPhaseLo: .fill 16,<ySeed(i)
initial_yPhaseHi: .fill 16,>ySeed(i)
initial_xSpeed: .fill 16,round(abs(vx(i))/4)
initial_ySpeed: .fill 16,round(abs(vy(i))/4)
initial_phase: .fill 16,i*16

snapY: .fill 16,0
snapX: .fill 16,0
snapH: .fill 16,0
currentPtr: .fill 16,0
initId: .fill 32,0
reuseId: .fill 32,0
reuseSlot: .fill 32,0
renderMask: .byte 0
physicalFrames: .word 0
plannerAge: .byte 0
maxAge: .byte 0
finishLine: .byte 0

// The latest samples need zero delay. Unwrap the CIA rollover near cycle 32.
.align $100
phaseDelay:
.for(var i=0;i<256;i++) {
    .var elapsed=63-mod(i+43,63)
    .if(elapsed<27) .eval elapsed=elapsed+63
    .byte min(59,max(0,elapsed-8))
}

*=$f100 "Reflected Q10.6 trajectories"
.function physicalX(p) {
    .var x=p<384 ? p : 767-p
    .return x<24 ? 480+x : x-24
}
finePixel: .fill 256,floor(i/64)
xBase: .fill 192,<physicalX(4*i)
.align $100
xBit: .fill 192,>physicalX(4*i)
.align $100
yBase: .fill 112,i<56 ? 4*i : 447-4*i

.align $100
animationPointers: .fill 1024,$c0+8*floor(i/256)+floor(mod(i,256)/32)
