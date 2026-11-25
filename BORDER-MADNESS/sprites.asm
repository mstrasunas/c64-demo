// 32 multicolour frames in VIC bank 0. Each logical pixel is two dots wide.
*=$3000 "Faceted spinners"
.function pixel(x,y,kind,frame) {
    .var u=(x-5.5)/5.85
    .var v=(y-10)/10.6
    .var phase=frame*PI/4
    .var a=atan2(v,u)
    .var r=u*u+v*v
    // A tilted equatorial ring passes behind the sphere on its far side.
    .if(kind==1) {
        .var ry=v+0.40*u
        .var ring=u*u+ry*ry*6.5
        .if(ring<1.04 && ring>0.63 && (ry>0 || r>0.50)) {
            .if(cos(3*a+phase)>0.35) .return 3
            .return 2
        }
        .if(r>0.52) .return 0
        .eval r=r/0.52
    }
    .if(kind==3) {
        .var facets=abs(u)*0.73+abs(v)*0.83
        .if(facets>0.94+0.08*cos(phase)) .return 0
        .if(r>1) .return 0
        .var face=cos(a*3+phase+0.3)
        .if(face< -0.22) .return 1
        .if(face>0.70 && v<0.14) .return 3
        .return 2
    }
    .if(r>1) .return 0
    .if(kind==2) {
        .var radius=sqrt(r)
        .if(radius<0.36+0.07*cos(a-phase)) .return 0
        .var curve=(radius-0.68)*3
        .var rim=0.5-curve*(0.5*u+0.8*v)+0.28*sin(3*a+phase)
        .if(rim>0.85) .return 3
        .if(rim<0.37) .return 1
        .return 2
    }
    .var z=sqrt(1-r)
    .var ridge=cos(4*a+phase+2.8*z)
    .var light=-0.48*u-0.63*v+0.60*z+0.19*ridge
    .if(light>0.85 && (ridge>0 || r<0.45)) .return 3
    .if(light<0.24 || (ridge< -0.70 && r>0.25)) .return 1
    .return 2
}
.for(var k=0;k<4;k++) {
    .for(var f=0;f<8;f++) {
        .for(var y=0;y<21;y++) {
            .for(var b=0;b<3;b++) {
                .byte pixel(b*4,y,k,f)*64+pixel(b*4+1,y,k,f)*16+pixel(b*4+2,y,k,f)*4+pixel(b*4+3,y,k,f)
            }
        }
        .byte 0
    }
}
