# Reglas del proyecto

- Destino permanente: C64 estándar de 64 KB, VIC-II, CPU 6510 y SID. Primera configuración PAL a 50 Hz. La ejecución debe funcionar en VICE y en equipo real sin REU, cartucho ni expansiones.
- Usar ACME en todas las etapas. Entregar PRG autónomos con línea BASIC SYS y arranque mediante RUN. Python se admite para preparar gráficos durante la compilación.
- Leer el joystick exclusivamente en el puerto 2 mediante CIA1 ($DC00). Izquierda y derecha fijan el sentido de marcha continuo. Reservar arriba para salto y fire para latas de aceite según la etapa.
- Mantener coordenadas lógicas independientes del VIC-II, módulos documentados y recursos gráficos originales.
- Limitar los cambios al alcance de la etapa solicitada. Antes de cerrar cada funcionalidad estable, compilar, verificar y hacer commit. Registrar en STATUS.md las pruebas y sus límites.
- Conservar los PRG publicados. Una etapa nueva usa un número de versión nuevo y actualiza README.md, BUILD.md y MEMORY_MAP.md cuando corresponda.
