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
