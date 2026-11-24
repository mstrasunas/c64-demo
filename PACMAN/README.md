# Pac-Man · The Maze Run

Juego para Commodore 64 de 64 KB. El PRG contiene el lanzador BASIC de una línea, el programa 6510, los gráficos y la música. La imagen D64 contiene el mismo ejecutable con el nombre PACMAN.

## Jugar

**VICE.** Ejecuta `x64sc -pal pacman.d64` o `x64sc -ntsc pacman.d64`. También puedes abrir `pacman.prg` mediante *Autostart disk/tape image*. En la configuración de joystick, asigna un mando físico o un conjunto de teclas al puerto 2. Pulsa fuego en la presentación.

**Commodore 64.** Conecta el joystick al puerto 2. Monta el D64 en una unidad compatible o transfiérelo a un disquete de 1541. Con la unidad como dispositivo 8, escribe:

```basic
LOAD"PACMAN",8,1
RUN
```

Si copias el PRG suelto a un dispositivo de almacenamiento, utiliza el nombre que figure en su directorio. El programa ocupa la máquina hasta el siguiente reinicio.

**Control.** Mantén la dirección deseada antes del cruce. Pac-Man conserva ese giro y sigue por el pasillo hasta que puede tomarlo. Puedes invertir la marcha entre dos centros de casilla. Los extremos del túnel de la fila central comunican entre sí.

**Objetivo.** Empiezas con tres vidas. Cada ronda tiene 214 puntos de 10 y cuatro superpíldoras de 50. Las capturas consecutivas durante una misma superpíldora valen 200, 400, 800 y 1.600 puntos. Los fantasmas azules parpadean al terminar su vulnerabilidad. Los ojos pueden cruzarse con Pac-Man sin hacerle daño.

Las frutas aparecen en el pasillo bajo la casa, después de comer 50 y 110 puntos o superpíldoras. Las cerezas valen 100, la fresa 300 y la naranja 500. La fruta dura cinco segundos de juego. Las rondas reutilizan el laberinto y aumentan la velocidad de los fantasmas y reducen la duración de la vulnerabilidad hasta la ronda 8. El indicador de ronda llega a 99. El récord se conserva entre partidas durante la sesión. Pulsa fuego después de GAME OVER para volver a jugar.

## Compilación

Necesitas ACME Cross Assembler. Con GNU Make, desde la carpeta de este archivo:

```sh
make
make disk
```

El segundo objetivo utiliza c1541, que forma parte de VICE. Para compilar directamente:

```sh
acme -f cbm -o pacman.prg -l symbols.txt main.asm
```

Los módulos gráficos ya contienen todos los bytes. Para editar los diseños y generar de nuevo las tablas, modifica `graphics.py` y ejecuta `make graphics` y `make disk`. El generador utiliza la biblioteca estándar de Python 3. El código ejecutado en la C64 está escrito en ensamblador.

## Mapa de memoria

| Direcciones | Uso |
|---|---|
| $0001 | Puerto del 6510. El valor $35 mantiene la E/S visible y deja RAM bajo BASIC y KERNAL. |
| $0002–$000C, $00FB–$00FE | Casillas, candidato y destino de IA, temporales y dos punteros indirectos. |
| $0100–$01FF | Pila de la CPU. |
| $02A6 | Indicador PAL/NTSC inicializado por el KERNAL y leído una vez al arrancar. |
| $0400–$07E7 | Pantalla de 40 × 25. El laberinto comienza en columna 5, fila 3. |
| $07F8–$07FD | Seis punteros de sprite, jugador, cuatro fantasmas y fruta. |
| $0801–$080F | Línea BASIC SYS 2061 y salto al inicializador. |
| $2000–$23FF | 128 caracteres de ocho bytes. Tipografía, puntos, puerta, contornos y título. |
| $3000–$3CBF | 51 fotogramas de sprite alineados a 64 bytes. |
| $4000–$4DA4 | Inicialización, IRQ, lógica, SID, renderizado, tablas y variables. |
| $4DA5–$5022 | 638 caracteres del trazado inicial. |
| $5023–$52A0 | 638 direcciones de regreso al centro de la casa. |
| $D000–$D02E | VIC-II. La extensión de X se publica en $D010. |
| $D400–$D418 | SID, voces y volumen. |
| $D800–$DBE7 | RAM de color de las 1.000 celdas visibles. |
| $DC00, $DC02 | Joystick del puerto 2 y dirección de sus líneas. |
| $DD00, $DD02 | Selección del banco VIC-II $0000–$3FFF. |
| $FFFA–$FFFB, $FFFE–$FFFF | Vectores NMI e IRQ en RAM. |

El PRG es una imagen continua con relleno entre regiones. El registro $D018 contiene $18. Cada puntero de sprite equivale a su dirección dentro del banco dividida por 64. ACME comprueba los límites de las regiones de caracteres, sprites y programa. El listado `symbols.txt` se actualiza al compilar.

## Movimiento e inteligencia artificial

Las posiciones lógicas están en píxeles. El centro de una casilla se reconoce con los tres bits bajos de ambos ejes. Los cuatro sentidos siguen el orden arriba, izquierda, abajo y derecha. La colisión de pared consulta directamente el carácter de pantalla. Al comer se borra esa celda y se decrementa el contador. La puerta permite salir de la casa a los fantasmas y bloquea a Pac-Man.

Cada fantasma tiene dirección, posición, acumulador fraccionario de velocidad, tiempo de salida y marca de ojos. En los centros elige entre vecinos transitables. Descarta la vuelta atrás salvo en un callejón sin salida. Compara la distancia cuadrática aproximada al objetivo con tablas de cuadrados escalados. En caso de empate, prevalece el primer sentido en el orden anterior.

| Fantasma | Objetivo durante persecución |
|---|---|
| Blinky | Casilla actual de Pac-Man. |
| Pinky | Cuatro casillas por delante de Pac-Man. |
| Inky | Proyecta dos casillas, toma el vector de Blinky a esa proyección y lo suma de nuevo a la proyección. |
| Clyde | Persigue desde lejos. A menos de ocho pasos de distancia Manhattan busca la esquina inferior izquierda. |

Los destinos proyectados se acotan al rectángulo del tablero. En dispersión cada fantasma tiene su esquina. El calendario alterna 7, 20, 7, 20, 5, 20 y 5 segundos antes de la persecución continua. El cambio de modo invierte la dirección de los fantasmas activos.

La superpíldora detiene ese calendario, invierte la marcha y reduce la velocidad de los fantasmas. En cada decisión de vulnerabilidad buscan alejarse de Pac-Man. Al capturarlos, los ojos avanzan hasta dos píxeles por actualización. Una búsqueda en anchura realizada por el generador desde la casa deja en cada casilla la primera dirección del camino mínimo de vuelta, incluido el túnel. En la casa recuperan el cuerpo, esperan y salen por la puerta.

## Vídeo y sonido

La interrupción de la línea 251 publica una copia completa de coordenadas, colores, punteros y bits altos de X. La lógica prepara la siguiente copia en RAM. PAL ejecuta una actualización por cuadro y NTSC ejecuta cinco por cada seis. El dibujo ordinario modifica sprites, puntos consumidos y las cuatro superpíldoras. El laberinto completo se pinta al comenzar una ronda.

Pac-Man utiliza un sprite monocromo con cuatro orientaciones y ocho fases adicionales de muerte. Los fantasmas utilizan sprites multicolor, dos posiciones de los pies y ojos direccionales. El SID dedica la primera voz a la melodía, la segunda a la sirena y la tercera a los efectos. La rutina de efectos acepta eventos según su prioridad y actualiza tono, forma de onda y duración una vez por paso lógico. La muerte y la fanfarria tienen prioridad sobre las capturas y los puntos.

## Pruebas

Compilado con ACME 0.97. La imagen de disco se generó con c1541. En VICE 3.9 x64sc se arrancó el D64 en PAL y NTSC, se simuló fuego en la CIA y se verificaron READY, partida, movimiento, consumo de puntos, colisiones, pérdida de las tres vidas y GAME OVER. La prueba de disco utilizó la emulación de unidad con trampas de VICE.

La prueba del núcleo ejecuta las instrucciones ensambladas con py65. Recorre físicamente todos los puntos con los enemigos aislados, comprueba el marcador y el siguiente nivel, los giros anticipados, las paredes, el túnel y el noveno bit de X. También ejercita 4.000 actualizaciones de navegación, el regreso de ojos, las cuatro capturas encadenadas, las frutas, las vidas y el récord.

Para repetir las pruebas desde este directorio, instala py65 para la primera y configura x64sc con sus ROM habituales para la segunda:

```sh
make disk
python3 tests/logic.py
python3 tests/vice.py
```

El segundo script admite la variable X64SC con la ruta del ejecutable. Una medición adicional de 500 actualizaciones de juego en x64sc registró 9.828.002 ciclos en PAL y 10.257.001 en NTSC. Se inspeccionaron capturas del VIC-II y se verificó señal de audio en una grabación PCM de la emulación reSID a 48 kHz. La validación se realizó por emulación. Queda pendiente la prueba con una C64 física, joystick y salida analógica SID.
