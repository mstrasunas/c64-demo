# Compilación de v04

Usar un shell POSIX, Python 3.8 o posterior y ACME 0.97 en el PATH. En Debian los paquetes se llaman `acme` y `python3`. VICE es opcional para compilar.

Desde la raíz ejecutar:

```sh
./build.sh
sha256sum cityconnection_v04.prg
```

El script genera los recursos en `build/`, ensambla el código 6510 y crea un PRG con cabecera de carga $0801. El programa publicado se sustituye solo al terminar ACME correctamente. Se puede eliminar `build/` y repetir la compilación.

SHA-256 de v01: `cbfb1855986a662b0cb26c4bcea2f9136d6c2c76b8290ac736373ab85374c6b7` (18 689 bytes).

## Ejecutar la prueba manual

```sh
x64sc -pal -joydev2 1 -keyset -autostartprgmode 1 -autostart cityconnection_v04.prg
```

En VICE 3.9 con GTK, activar Bloq Num, pulsar 4 y 6 del teclado numérico y soltar cada tecla. Comprobar el giro del coche, que las ruedas alternan y que la marcha continúa tras cruzar los bordes.

SHA-256 de v02: `634ba3b9296e57a2081cae7778a5beaa9a741e3e671c8fc730e812310baab8b0`.

v03 genera además la imagen mundial de 160 columnas, la plantilla lógica de carreteras y una tabla de porcentaje. SHA-256 del PRG de 26.529 bytes: `18258ff61173dcd969fe28fe4555e5d36fe359542aca9d06e5681ac2dcc5dfda`. Para repetir la partida de aceptación después de compilar, instalar py65 y ejecutar `python3 tests/combat.py`.

SHA-256 de v04: `4728fff318800cadc205b0e507a06f1e0f45edaff137fede3895e398927d36b6`.
