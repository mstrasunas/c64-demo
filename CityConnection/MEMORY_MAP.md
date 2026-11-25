# Mapa de memoria · v02

Direcciones inclusivas. El VIC-II usa el banco 1 ($4000–$7FFF), con $DD00 bits 1–0 = %10 y $D018 = $12.

| Rango | Uso |
|---|---|
| $0000–$07FF | Puerto del 6510, página cero, pila, área de sistema y pantalla BASIC inicial. |
| $0801–$080C | Línea BASIC 10 SYS2061 y terminador. |
| $080D–$2FFF | Código nativo y estado del jugador. El tramo libre queda para crecimiento del motor. |
| $3000–$37CF | Escena provisional: 1000 códigos de carácter y 1000 colores. |
| $37D0–$3FFF | Reserva para datos de escenario. |
| $4000–$43FF | Reserva para pantalla alternativa alineada a 1 KB. |
| $4400–$47FF | Pantalla activa. $47F8–$47FF contienen los punteros de sprites. |
| $4800–$4FFF | Juego de caracteres personalizados, 256 posiciones de 8 bytes. |
| $5000–$50FF | Cuatro sprites de 64 bytes: derecha A/B e izquierda A/B. |
| $5100–$5FFF | Reserva de sprites alineados a 64 bytes. |
| $6000–$7FFF | Reserva para futuras pantallas y recursos de vídeo. |
| $8000–$8FFF | Reserva para reproductor y datos de música SID. |
| $9000–$9FFF | Reserva para escenarios. |
| $A000–$BFFF | ROM BASIC visible en la configuración habitual. |
| $C000–$CFFF | RAM libre. |
| $D000–$DFFF | E/S visible: VIC-II, SID ($D400), RAM de color ($D800), CIA1 y CIA2. |
| $E000–$FFFF | ROM KERNAL visible. |

El PRG carga un bloque continuo desde $0801 hasta $50FF, con relleno entre segmentos. Durante el dibujo se copian 1000 celdas sin sobrescribir la tabla de punteros. La X lógica tiene 16 bits, con recorrido 0–296; la Y lógica se expresa en píxeles. La cámara queda fija en el origen y la proyección suma (24, 50) para el VIC-II. El bit alto de X va a $D010.
v02 aloja el mapa lógico, su copia mutable y los contadores en la región del motor, por debajo de $3000. El dibujo de segmentos usa el puntero temporal $FB–$FC. La matriz de pantalla es una vista del mapa.

## Cambios en v03

El mundo usa $6000–$6F9F, 25 filas de 160 códigos de carácter, con las carreteras pintadas reflejadas en esa imagen. La plantilla y los 640 estados de colisión/pintura están en la región de código inferior a $3000. El contador pendiente tiene 16 bits. Las pantallas $4000 y $4400 comparten el charset $4800 y mantienen el puntero de sprite en $43F8/$47F8. El HUD siempre se lee de $4400. Color RAM se inicializa con el HUD y un color multicolor fijo para el campo.

La X mundial del coche va de 8 a 1248 y la cámara de 0 a 960. El sprite recibe X mundial menos cámara más 24, incluido el noveno bit. En el campo se muestra la ventana de caracteres que comienza en ceil(cámara/8), con fase fina (-cámara) módulo 8.
