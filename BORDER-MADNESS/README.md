# FULL BORDER MADNESS

Demo para Commodore 64 PAL de 64 KB. La presentación abre con un logotipo de tres segundos. Después, dieciséis objetos multicolores atraviesan el campo y los bordes al ritmo de *Undercurrent*. Los reflejos cambian con el pulso del SID.

## Ejecutar

En VICE 3.9, con las ROM de C64 instaladas, ejecutar desde el directorio del proyecto:

```sh
x64sc -model c64 -VICIIborders 1 -autostart demo.prg
```

El modelo `c64c` permite probar la configuración PAL más reciente. En un equipo físico, cargar el PRG desde la unidad habitual con `LOAD"DEMO.PRG",8,1` y escribir `RUN`. El cargador BASIC descomprime toda la demo en RAM. La ejecución sólo necesita el PRG. **F1** alterna el diagnóstico durante la animación. El azul muestra las zonas que el VIC-II todavía tapa y permite ver directamente las ventanas laterales. El reinicio del C64 sale de la demo.

## Compilar

Se usaron Kick Assembler 5.25, Java, Python 3 y Bash. Con una copia de Kick Assembler disponible, desde este directorio:

```sh
KICKASS_JAR=/ruta/a/KickAss.jar ./build.sh
```

El script ensambla `main.asm`, extrae el reproductor y la partitura a `music.sid`, comprime el programa con `pack.py` y ensambla `loader.asm` para generar `demo.prg`. El archivo SID es PSID v2, con inicio en $C000 y reproducción en $C003. Los gráficos y sus tablas se construyen a partir de los fuentes incluidos. El paquete de Kick Assembler y las ROM de VICE se obtienen por separado.

## Movimiento y multiplexado

Cada eje acumula una fase Q10.6 con velocidad propia. Una tabla triangular refleja la trayectoria en ambos extremos y conserva la fracción de píxel al rebotar. Las posiciones lógicas del origen abarcan X de 0 a 383 e Y raster de 26 a 249. El sprite ocupa hasta 24 × 21 píxeles. El estudio del borde izquierdo en x64sc mostró una discontinuidad entre X de hardware 503 y 0. La tabla usa 480–503 para los primeros 24 píxeles y reanuda en 0. La captura de límites sitúa píxeles visibles entre X 0–406 e Y 18–262 en la imagen de 408 × 293 de VICE. El recorte de un televisor puede ser diferente.

El hilo principal toma una instantánea coherente y ordena los objetos por Y mediante inserción sobre el orden anterior. Construye el programa raster siguiente mientras las IRQ ejecutan el activo. El planificador reserva 29 líneas desde el origen Y antes de reutilizar un sprite físico. Distribuye las escrituras en tres líneas y conserva el bit alto de X de los demás sprites al escribir $D010. El cambio de programa se publica en el intervalo vertical. Si el plan siguiente sigue en construcción, la IRQ reutiliza la asignación activa y actualiza posiciones, animaciones y música.

Con más de ocho objetos en una línea, el VIC-II sólo puede dibujar ocho. La prioridad rotativa desempata posiciones y reserva una plaza a un objeto omitido. El margen de programación también puede aplazar un objeto en un grupo muy compacto. En la prueba con los dieciséis a la misma Y, cada identificador recibió una plaza en **24 de 48 cuadros**. El recorrido individual continúa mientras un objeto espera su turno.

## Bordes y tiempo de CPU

La doble IRQ establece la referencia raster. El temporizador A de CIA1 proporciona la fase módulo 63. El programa desenrollado lee esa fase, ajusta la espera y usa `DEC $D016` seguido de `STY $D016` para cambiar CSEL alrededor de la comparación del borde. En vertical, el código escribe $1B en $D011 en la línea 49 y $13 en la 248. DEN permanece desactivado durante la línea 48 de la animación para evitar las *badlines* de la matriz de caracteres.

La apertura lateral se programa por tramos donde hay sprites próximos al borde o escrituras de reutilización. Las líneas laterales vacías pueden quedar cerradas. Esta decisión deja CPU al planificador. F1 permite observarla. La zona vertical de movimiento también deja margen al arranque raster y a la actualización del cuadro. El montaje conserva la actualización por cuadro aunque la carga retrase la publicación de una nueva asignación.

| Trabajo | Medición en x64sc | Cota de código |
|---|---:|---:|
| Movimiento y animación de los 16 objetos | 1.750–1.752 ciclos | 1.782 |
| Llamada al reproductor SID | 281–465 ciclos | 540 |
| IRQ de línea 274 hasta la etiqueta de registros actualizados | 3.041–3.428 ciclos | 3.791 hasta el retorno completo |

Las mediciones de rutinas proceden de una ventana de 1.024 cuadros. Las cotas cuentan instrucciones 6510, ramas y posibles cruces de página. Movimiento y música están incluidos en la IRQ. La ventana desde la línea 274 hasta la 23 del siguiente cuadro comprende 61 × 63 = 3.843 ciclos, antes de descontar la latencia de entrada. La IRQ desactiva los sprites durante este trabajo. Un cuadro PAL completo tiene 312 × 63 = 19.656 ciclos. Durante el dibujo, ocho sprites consumen hasta 16 accesos de datos en fases de CPU por línea activa, además de la anticipación de BA que puede detener lecturas. El tiempo libre del planificador varía con la distribución espacial. La prueba de coincidencia ejercita el DMA real emulado con los ocho canales activos.

## Música

*Undercurrent* tiene 64 compases de 16 pasos, a seis cuadros por paso. Un recorrido dura 6.144 cuadros, aproximadamente 122,6 segundos en PAL. La voz principal combina portamento, vibrato y cambios de forma de onda, incluidos sincronismo y modulación en anillo. El bajo usa pulso de anchura variable, arpegios y filtro resonante. La tercera voz alterna ruido y formas tonales para bombo, caja y charles. Las tablas cambian de frase, instrumentación y patrón de percusión entre introducción, desarrollo, estribillo y transición. La respuesta analógica del filtro varía según el SID.

## Verificación

- Kick Assembler generó ambos binarios. x64sc arrancó el PRG empaquetado mediante el cargador BASIC. En ambos modelos, el volcado de RAM entre $1000 y $F8FF coincidió byte por byte con la imagen ensamblada.
- Se probaron ocho sprites como etapa inicial y el multiplexado de dieciséis. Se fijaron posiciones en los cuatro extremos y después se forzó la coincidencia vertical de los dieciséis. En cinco cuadros de traza del ensayo de límites, las 1.240 escrituras críticas observadas terminaron en el ciclo 56 de la línea prevista. En el ensayo de coincidencia, las 120 observadas también terminaron en ese ciclo, según la numeración del monitor de VICE.
- Se registraron 24.000 entradas consecutivas a la IRQ de cuadro en cada configuración de x64sc 3.9: 6569 con 6581 y 8565 con 8580. Los 23.999 intervalos de cada traza correspondieron a un cuadro PAL, aproximadamente ocho minutos de tiempo emulado por modelo. La salida de audio estuvo desactivada en esta prueba de cadencia. El PSID se renderizó por separado durante más de un bucle con los dos modelos de SID en libsidplayfp.
- Las capturas de `pruebas/` proceden de x64sc. `cadencia.mon` permite repetir la traza con el binario distribuido. Para medir el mismo recorrido, conservar el ajuste PAL y las direcciones del binario original. La comprobación en un C64 físico y un CRT queda pendiente.

Para repetir el registro desde este directorio:

```sh
x64sc -model c64 -VICIIborders 1 -warp +sound -initbreak reset -moncommands pruebas/cadencia.mon -monlog -monlogname cadencia.log -autostartprgmode 1 -autostart demo.prg
```
