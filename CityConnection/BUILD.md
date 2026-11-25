# Compilación de v01

Usar un shell POSIX, Python 3.8 o posterior y ACME 0.97 en el PATH. En Debian los paquetes se llaman `acme` y `python3`. VICE es opcional para compilar.

Desde la raíz ejecutar:

```sh
./build.sh
sha256sum cityconnection_v01.prg
```

El script genera los recursos en `build/`, ensambla el código 6510 y crea un PRG con cabecera de carga $0801. El programa publicado se sustituye solo al terminar ACME correctamente. Se puede eliminar `build/` y repetir la compilación.

SHA-256 de v01: `cbfb1855986a662b0cb26c4bcea2f9136d6c2c76b8290ac736373ab85374c6b7` (18 689 bytes).

## Ejecutar la prueba manual

```sh
x64sc -pal -joydev2 1 -keyset -autostartprgmode 1 -autostart cityconnection_v01.prg
```

En VICE 3.9 con GTK, activar Bloq Num, pulsar 4 y 6 del teclado numérico y soltar cada tecla. Comprobar el giro del coche, que las ruedas alternan y que la marcha continúa tras cruzar los bordes.

## Recuperar el checkpoint del paquete

El ZIP incluye los fuentes listos para compilar y el historial Git en un bundle. Para obtener un repositorio de trabajo, ejecutar desde la carpeta extraída:

```sh
git clone etapa1.bundle ciudad
git -C ciudad log --oneline --decorate
```

La rama es `main` y la etiqueta de entrega es `v01`.
