# GALAXIA CHARRÚA

Arcade espacial para Commodore 64 PAL. Mové la nave bajo la escuadrilla, abrí un hueco en sus tres filas y decidí cuándo conviene esperar a que un enemigo rompa la formación. En picada vale el doble, pero también puede embestirte.

[Descargar GALAXIA_CHARRUA.PRG](./GALAXIA_CHARRUA.PRG?raw=true) · [Pruebas de ejecución](pruebas/PRUEBAS.md)

![Pantalla de presentación del C64](pruebas/titulo.png)
![Vuelo y combate en VICE PAL](pruebas/vuelo.gif)

## Jugar en VICE

Usá x64sc con las ROM de un C64 configuradas. Podés abrir el PRG con **File → Autostart disk/tape image** o ejecutarlo desde la terminal.

```sh
x64sc -model c64 -pal -autostartprgmode 1 -autostart GALAXIA_CHARRUA.PRG
```

| Acción | Joystick, puerto 2 | Teclado C64 |
|---|---|---|
| Empezar o volver a jugar | FIRE | Espacio |
| Mover la nave | Izquierda / derecha | A / D |
| Disparar | FIRE | Espacio |

Podés mantener el disparo pulsado. Sólo hay un proyectil propio en vuelo y deben pasar al menos 13 cuadros entre disparos. Para iniciar otra partida, soltá y volvé a pulsar FIRE o espacio. Si esperás unos diez segundos en GAME OVER, vuelve la presentación con el récord.

## Cargar en un C64

Copiá el PRG a un disco o dispositivo compatible. Si lo guardás con el nombre de directorio Commodore `GALAXIA_CHARRUA` en la unidad 8, escribí lo siguiente desde BASIC.

```basic
LOAD"GALAXIA_CHARRUA",8,1
RUN
```

Si hay un solo juego con ese prefijo en el disco, también podés usar `LOAD"GALAXIA*",8,1`. Así evitás escribir el guion bajo en el teclado original. El PRG carga en $0801 e incluye la línea BASIC `10 SYS2061`.

## Puntuación y oleadas

| Enemigo | En formación | En picada |
|---|---:|---:|
| Corona, fila amarilla | 40 | 80 |
| Medusa, fila roja | 30 | 60 |
| Horqueta, fila verde | 20 | 40 |

Cada oleada trae 24 enemigos. Un atacante que pasa de largo vuelve por arriba e intenta recuperar su puesto. Los proyectiles enemigos se desvían hacia el lado en que estaba la nave al disparar. Empezás con tres vidas. Después de un impacto, la nave reaparece en el centro y parpadea durante 90 cuadros. Los 24 enemigos vuelan en tres líneas en V. La marcha comienza a un píxel por cuadro y aumenta gradualmente hasta 1,75 píxeles por cuadro en la oleada 13. También se acorta el intervalo entre ataques. El récord dura mientras siga ejecutándose el programa.

## Animación y música

Las estrellas descienden en dos planos de profundidad. Cruzan las filas de caracteres y reaparecen arriba al salir por abajo.

La nave acelera y frena con precisión fraccional, se inclina al virar y alterna cuatro fases de propulsión. Los tres tipos de enemigo despliegan las alas en seis poses, tanto en formación como en picada. Las explosiones pasan del destello central a los fragmentos en ocho fases.

En la presentación y en partida suena un arreglo instrumental del comienzo del coro del **Himno Nacional Uruguayo**, música de Francisco José Debali. La transcripción toma la entrada «Orientales, la patria o la tumba» de la partitura publicada por la Dirección General de Educación Inicial y Primaria. Una voz SID toca la melodía y las otras dos quedan disponibles para efectos. [Escuchar el arreglo SID](pruebas/himno-sid.mp3?raw=true) · [Partitura de referencia, página impresa 4](https://www.dgeip.edu.uy/documentos/2013/musica/biblioteca/HimnoNacionalb.pdf)

## Compilar

Desde esta carpeta, con ACME en el PATH, ejecutá lo siguiente.

```sh
./build.sh
```

También podés indicar una ruta explícita o generar una tabla de símbolos para el monitor de VICE.

```sh
ACME=/ruta/a/acme ./build.sh -l /tmp/galaxia.sym
```

El script genera `GALAXIA_CHARRUA.PRG` junto al README. ACME incorpora directamente los recursos binarios de `src/`. Para editar y regenerar la ilustración, los sprites o los caracteres enemigos, ejecutá `python3 tools/arte.py` antes de compilar. Los gráficos son originales.

## Organización y memoria

| Archivo | Responsabilidad |
|---|---|
| main.asm | Arranque BASIC/6510, IRQ raster y ciclo de cuadros |
| vic.asm, sprites.asm | Banco de video, presentación y coordenadas de nueve bits |
| player.asm | CIA1, teclado, movimiento y cadencia |
| enemies.asm | Formación, picadas, retorno y fuego enemigo |
| collisions.asm | Impactos, explosiones e invulnerabilidad |
| game.asm | Partidas, oleadas, BCD y récord |
| sound.asm | Secuenciador PAL y reparto de voces SID para música y efectos |
| himno.asm | Notas y duraciones del comienzo del coro del himno |
| data.asm, stars.asm | Estado del juego y campo de estrellas con posiciones en píxeles |

El VIC-II usa el banco $4000–$7FFF. La pantalla está en $4400, los punteros de sprites en $47F8, el juego de caracteres en $4800, los sprites en $5000 y el bitmap de presentación en $6000. El código empieza en $080D. El PRG ocupa 30.529 bytes, incluidos los espacios entre segmentos.

La formación se dibuja con cuatro caracteres multicolor por enemigo. En partida se usan hasta cinco sprites simultáneos para nave, disparo propio, atacante, disparo enemigo y explosión. Dos interrupciones preparan el cambio de scroll con anticipación y sincronizan la escritura de $D016 con el inicio de las líneas 75 y 171. La misma posición alimenta las colisiones y el retorno de las picadas. El IRQ en la línea 250 avisa al bucle principal una vez por cuadro. El KERNAL salva los registros al entrar y el manejador los restaura antes de RTI. La lógica y el sonido corren en el 6510.
