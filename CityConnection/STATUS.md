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
