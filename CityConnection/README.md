# City Connection para Commodore 64 · Etapa 1

Conversión del arcade de Jaleco (1985). Esta versión permite conducir un automóvil por una carretera urbana, con gráficos originales y un marcador provisional.

## Jugar

En VICE, seleccionar C64 PAL, asignar un dispositivo al **joystick del puerto 2** y abrir `cityconnection_v01.prg` mediante Autostart. En el C64, cargar el PRG desde el dispositivo correspondiente (por ejemplo, `LOAD"*",8,1` si es el primer programa del disco) y escribir `RUN`.

El coche arranca hacia la derecha. Pulsar izquierda o derecha cambia su orientación y su sentido de marcha. Al soltar el mando conserva el rumbo. Recorre un píxel por cuadro PAL y al superar un borde reaparece entero en el otro extremo. El HUD muestra 000000 puntos, 03 vidas y 05 latas de aceite. Los tres valores son fijos en esta etapa.

## Proyecto

- `src/main.asm` contiene la línea BASIC, el punto de entrada y el bucle por cuadro.
- `src/video.asm` inicializa el VIC-II y espera la línea de raster.
- `src/scene.asm` dibuja la matriz de pantalla y la RAM de color.
- `src/player.asm` lee CIA1, actualiza la posición lógica y proyecta el sprite.
- `tools/` contiene los dibujos y los generadores de los caracteres y sprites originales.
- `BUILD.md` describe la compilación y la recuperación del historial. `MEMORY_MAP.md` describe la distribución de RAM. `STATUS.md` recoge las pruebas.
