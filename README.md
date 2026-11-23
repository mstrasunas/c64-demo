# Sprite Orbit para Commodore 64 PAL

Demo autónoma en ensamblador 6510 para un Commodore 64 PAL. Usa los ocho sprites de hardware del VIC-II en multicolor, cada uno con un dibujo, un color propio y una velocidad independiente en cada eje.

## Compilar

Instalá ACME y ejecutá `./build.sh` desde el proyecto. El script genera `demo.prg` junto a `demo.asm`. Si ACME está fuera del `PATH`, podés indicar su ruta con la variable `ACME`.

```sh
ACME=/ruta/a/acme ./build.sh
```

En el entorno Cloud se usó ACME 0.97, extraído de un paquete Debian a `/tmp/c64-demo-tools/usr/bin/acme`.

## Ejecutar

En VICE con las ROM del C64 configuradas, ejecutá el PRG con `x64sc` en modo PAL.

```sh
x64sc -model c64 -pal -autostartprgmode 1 -autostart demo.prg
```

En un C64 PAL, copiá el PRG a un disco o dispositivo compatible, con el nombre `DEMO`. Desde BASIC, cargalo en la unidad 8 y ejecutalo. Si lo guardaste con otro nombre o número de unidad, adaptá el comando.

```text
LOAD"DEMO",8
RUN
```

El PRG carga desde `$0801` y contiene una línea BASIC `10 SYS 2061` que inicia la demo. Reiniciá el C64 para volver a BASIC.

## Movimiento y refresco

La interrupción raster en la línea 252 calcula y publica las posiciones una vez por cuadro PAL, a unos 50 Hz. Las velocidades fraccionarias conservan el movimiento subpíxel entre actualizaciones. Al cruzar un borde, el código refleja el excedente e invierte la velocidad de ese eje. La esquina superior izquierda de cada sprite queda en X de 24 a 320 e Y de 50 a 229, dentro del área visible de 320 × 200.

Cada sprite ocupa un bloque de 64 bytes desde `$2000` en el banco 0 del VIC-II. Los registros `$D000–$D00F` reciben las coordenadas bajas de X y las de Y. Cada bit de `$D010` corresponde al noveno bit de X de su sprite.

## Verificación

- Compilé con ACME 0.97, comprobé el encabezado y la línea BASIC del PRG, y comparé dos compilaciones byte por byte.
- Ejecuté el PRG con VICE 3.9 (`x64sc`), modelo PAL con VIC-II MOS6569R3 y pantalla virtual Xvfb. Tomé la [captura](captura.png) con el comando `screenshot` del monitor de VICE y comprobé que muestra los ocho diseños.
- Copié el PRG a una imagen D64 temporal, verifiqué que se pudiera extraer sin cambios y confirmé visualmente que arrancaba desde la unidad 1541-II emulada.
- Con el monitor binario, contrasté las coordenadas, velocidades y registros del VIC-II con un cálculo independiente durante 900 interrupciones consecutivas en la línea 252. Observé 66 rebotes, con cobertura de los cuatro bordes para cada sprite, y 30 cambios de bits en `$D010`, con cruces del límite de X=255 en ambos sentidos para cada sprite.
- Con `stopwatch` en el monitor de VICE, medí 98.280 ciclos en cinco cuadros. El período nominal es de 19.656 ciclos por cuadro (312 líneas por 63 ciclos), con hasta un ciclo de variación en las entradas medidas a la interrupción.

La prueba en un Commodore 64 físico queda pendiente.
