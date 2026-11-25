# Estado de la conversión

## Etapa 1 de 7 · v01

Cerrada. PRG autónomo para C64 PAL de 64 KB, con arranque BASIC, caracteres multicolor, carretera, HUD, sprite multicolor y control por el puerto 2. La escena es estática. Salto, disparo, scroll y música quedan pendientes para las etapas correspondientes.

| Prueba realizada | Resultado |
|---|---|
| Compilación con ACME 0.97 y recompilación limpia | PRG idéntico byte a byte; 18 689 bytes. Hash en BUILD.md. |
| Autostart de VICE 3.9 x64sc PAL con inyección del PRG y arranque BASIC | Entró en el bucle de juego; ciudad, coche y HUD visibles. |
| Pulsar izquierda y derecha con el teclado numérico asignado al joystick 2 | CIA1 dio $7B a la izquierda, $77 a la derecha y $7F en reposo. Cambiaron el sentido y el puntero de sprite. |
| Soltar el mando tras girar | La X continuó en el sentido elegido en ambas direcciones. |
| Recorrido completo, 65 muestras por sentido en el monitor de VICE | Desplazamiento lógico de un píxel por actualización, paso por X de sprite 255/256 y reaparición en el borde opuesto en ambos sentidos. |
| Animación y proyección | Punteros $40/$41 hacia la derecha y $42/$43 hacia la izquierda. X de sprite igual a X lógica + 24. |
| Escenario y HUD en memoria emulada | Las 1000 celdas de pantalla y los 1000 nibbles de color coincidieron con los recursos generados. |

No se realizaron pruebas en un Commodore 64 físico.

## Etapa 2 · v02

Cuatro carreteras discontinuas con superficie en Y 64, 104, 144 y 184. El mapa contiene 134 segmentos. La velocidad inicial del salto es −5 píxeles por cuadro y la gravedad añade un píxel por cuadro de velocidad cada cuatro cuadros. Las colisiones comparan la posición anterior y actual de los neumáticos al descender. Sólo la transición de carretera intacta a pintada reduce el contador.

ACME compiló el PRG. VICE 3.9 x64sc PAL arrancó mediante BASIC y ejecutó 256 actualizaciones. En una segunda prueba se ejecutó el mismo código en py65, sustituyendo únicamente la espera raster por RTS y aplicando entradas de puerto 2 con semilla 42. El coche aterrizó en las cuatro alturas y completó el escenario en 12.504 actualizaciones. En cada cuadro el contador coincidió con el número de segmentos intactos y decreció como máximo en uno. Se verificaron STAGE CLEAR en pantalla y la restauración de los 134 segmentos con Fire. La partida completa se probó con entradas emuladas; queda pendiente la prueba en hardware físico.

## Etapa 3 · v03

Manhattan tiene 160 columnas y cuatro alturas. Las colisiones consultan coordenadas mundiales. La cámara tiene límites y conserva la velocidad, el salto y la caída de v02. El HUD se presenta en 40 columnas; la línea raster 81 selecciona el campo en 38 columnas. Al cambiar de columna gruesa se preparan las 21 filas del campo en la pantalla oculta. Los demás cuadros sólo cambian la fase y, cuando corresponde, una celda pintada. Las altas y bajas de escena inicializan Color RAM.

Una partida reproducible de 6.001 actualizaciones cubrió ambos sentidos, cambios consecutivos de dirección, saltos, los 552 segmentos y STAGE CLEAR. La prueba del binario en py65 cotejó las 840 celdas visibles con el mapa en cada actualización, la proyección del sprite en X=255/256 y el contador hasta completar y reiniciar con Fire.

En VICE 3.9 x64sc PAL se arrancó el PRG mediante BASIC y se reprodujeron las mismas entradas sustituyendo la lectura de CIA por una rutina de prueba en RAM. Se registraron las escrituras de $D016 y se capturó el HUD durante desplazamiento y al completar. Las capturas y la secuencia de puerto 2 están en tests/. Queda pendiente la verificación física en un C64.

## Etapa 4 · v04

Dos patrullas aparecen fuera de la primera pantalla. Cada una persigue la X del jugador sobre su tramo y comprueba el apoyo antes de avanzar. El gato intenta aparecer cada 1.024 cuadros sobre carretera firme, separado del jugador, y se retira tras 128 cuadros. Hay tres latas de recogida única por partida. Fire dispara en el sentido de marcha; un impacto aturde durante 120 cuadros y embestir la patrulla giratoria otorga 100 puntos.

Se usan ocho sprites físicos sin multiplexación. Las hitboxes usan X mundial de 16 bits e Y lógica. Un accidente consume una de tres vidas, dura 32 cuadros y va seguido de 100 cuadros de protección si quedan vidas. El accidente mantiene el mapa pintado. Fire reinicia después de STAGE CLEAR o GAME OVER.

La secuencia reproducible de tests/combat.joy recoge aceite, dispara, elimina una patrulla, pierde una vida y completa los 552 segmentos. La prueba comprueba el contador y la matriz visible durante el recorrido. Pruebas dirigidas adicionales del binario en py65 comprueban el impacto con una patrulla activa, que el disparo atraviesa al gato, el daño del gato, la inmunidad, el agotamiento de vidas y los dos reinicios.

En VICE 3.9 x64sc PAL se arrancó el PRG por BASIC y se sustituyó únicamente la lectura de CIA por la secuencia grabada. Se observaron 6.642 pasos por la separación raster en la línea 81, con un cuadro PAL por intervalo, y cero segmentos pendientes al final. Falta la comprobación en hardware físico.
