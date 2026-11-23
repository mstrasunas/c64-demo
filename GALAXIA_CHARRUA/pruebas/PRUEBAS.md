# Verificación de la versión con vuelo en V e himno

Se regeneraron los gráficos con Python y se ensambló el PRG con ACME 0.97. La segunda compilación reprodujo el SHA-256 `00724d4ee2dd2df3a45afe935ef18724717ba71ef57ba8ff90d88ff27f4c8574`. El ejecutable de 30.529 bytes se probó en VICE x64sc 3.9, con un C64 PAL y Xvfb. La prueba en hardware físico sigue pendiente.

| Prueba | Método y resultado |
|---|---|
| Arranque y controles | Autostart del PRG, presentación y comienzo con espacio. Se enviaron A, D y espacio a la ventana de VICE. Se observó desplazamiento y un proyectil en vuelo. En los extremos se leyeron las posiciones 0 y 148 y los bits de X alta correspondientes. Para esta prueba de bordes se prolongó la invulnerabilidad. |
| Continuidad | Con un punto de parada por cuadro en el monitor, se midieron 139 transiciones consecutivas de la primera oleada. En todas, la formación avanzó exactamente un píxel, incluyendo las inversiones de sentido. Aparecieron las seis poses. El GIF toma una captura de VICE cada dos cuadros PAL. |
| Presupuesto de CPU | En una muestra de 60 cuadros, el monitor midió entre 660 y 9.902 ciclos desde la lectura de controles hasta la espera de raster. El cuadro del modelo PAL probado tiene 19.656 ciclos. |
| Disparos y colisiones | Hubo bajas con el teclado. Para verificar todos los puestos, se ubicaron proyectiles con el monitor en posiciones de la V y en la picada. Se comprobaron el contador de enemigos, el inicio de la explosión y el incremento del marcador según la fila o el ataque. |
| Oleadas | Al limpiar la formación aparecieron los 24 enemigos de la oleada 2. Se conservaron 740 puntos y aumentó el incremento fraccional de la velocidad. |
| Vidas y reinicio | Una bomba redujo las vidas a dos. El siguiente impacto durante la protección dejó dos vidas. Se prepararon una embestida y un último impacto con el monitor. Se comprobó GAME OVER y, al reiniciar con espacio, oleada 1, tres vidas, puntuación cero y récord de 740. |
| SID | Se renderizó la presentación con reSID y salida WAV. En partida se siguió el índice del secuenciador mientras se disparaba y se observó su avance por nueve posiciones durante la captura animada. |

![Vista animada de VICE](vuelo.gif)

![Presentación](titulo.png)
![Atacante en vuelo](partida.png)
![Fin de partida](game-over.png)

Para inspeccionar los símbolos, compilá con `./build.sh -l /tmp/galaxia.sym`. En el monitor de VICE, `until` con la dirección de `gameTick` detiene el programa una vez por cuadro de partida. Los bytes `scrollX`, `fineX`, `animation` y `songPos` indican el desplazamiento total en píxeles, su componente fina, la pose y la posición musical.
