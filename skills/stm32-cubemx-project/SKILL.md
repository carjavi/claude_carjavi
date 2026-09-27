---
name: stm32-cubemx-project
description: Flujo de trabajo para proyectos STM32 generados con STM32CubeMX (.ioc) — editar el .ioc y regenerar con STM32CubeMX CLI, código propio solo en USER CODE o archivos aparte, salida serial por USB CDC (PA11/PA12) por defecto, anti-rebote por software en pulsadores, compilar y verificar sin errores ni warnings, y README.md con modificaciones del .ioc, tabla de conexiones, librerías y registros. Usar al crear, modificar o documentar cualquier proyecto STM32 con archivo .ioc.
---

Complementa a `embedded-firmware-cpp` (estándares generales de firmware) y `source-metadata-header` (bloque de metadata). Si el proyecto o el usuario indican otra cosa, eso gana (ver CLAUDE.md §0).

## 1. Configuración del `.ioc` con STM32CubeMX CLI

- Todo cambio de periféricos, pines, clocks, DMA o NVIC se hace **en el `.ioc`** y el código se regenera con STM32CubeMX en modo línea de comandos. No se edita a mano el código generado si CubeMX puede generarlo.
- Antes de modificar el `.ioc`: leerlo completo, identificar conflictos (pines ya usados, labels distintos a los que espera el código, periféricos faltantes) y **preguntar al usuario** las decisiones de diseño que no se deduzcan del contexto.
- Respaldar el `.ioc` y `Core/` antes de regenerar, sobre todo si el proyecto no está en git.
- Script de regeneración (rutas absolutas, con `/`):

  ```text
  config load C:/ruta/al/proyecto/Proyecto.ioc
  project generate
  exit
  ```

  ```bash
  STM32CubeMX.exe -q cubemx_gen.txt    # Windows: %LOCALAPPDATA%\Programs\STM32CubeMX\
  ```

- Correr la CLI en segundo plano y revisar el log `~/.stm32cubemx/STM32CubeMX.log`. **Si no termina en ~2–3 min, está bloqueada** por un diálogo que en modo script no se puede responder (caso conocido: `IP not ready for code generation: FATFS` cuando SDIO no tiene pin de card-detect). En ese caso:
  1. Detener solo el proceso `javaw` que se lanzó y verificar que no quedaron archivos a medias (comparar con el respaldo).
  2. Informar al usuario la causa exacta del bloqueo.
  3. Replicar a mano **exactamente** lo que generaría CubeMX (mismo formato, mismos comentarios, handles, `MX_xxx_Init`, IRQ handlers, entradas en `cmake/stm32cubemx/CMakeLists.txt`), dejando el `.ioc` coherente para que regenerar desde la GUI dé el mismo resultado.
- El código propio va **en archivos aparte** (`Core/Src/<modulo>.c` + `Core/Inc/<modulo>.h`) o **dentro de bloques `USER CODE BEGIN/END`**, para que sobreviva a cada regeneración. En proyectos CMake, las fuentes propias se agregan en el `CMakeLists.txt` raíz (`target_sources`), que CubeMX no regenera.
- Usar **User Labels** en los GPIO y referenciar siempre las macros generadas (`LABEL_Pin`, `LABEL_GPIO_Port`), nunca `GPIO_PIN_x` fijos en el código de aplicación.
- Orden de init: `MX_DMA_Init()` antes que cualquier periférico que enlace DMA en su `MspInit`.

## 2. Salida serial por USB CDC (Virtual COM Port)

- Cuando se pida "UART", "salida serial", "consola" o logs de debug, usar por defecto **USB OTG FS en modo Device, clase CDC**: **PA11 = USB_DM, PA12 = USB_DP** (Middleware `USB_DEVICE` → Communication Device Class). Usar un USART físico solo si el usuario lo pide explícitamente.
- Requisitos de clock: 48 MHz exactos para USB (PLLQ); verificarlo en el `.ioc`.
- Redirigir `printf` implementando `_write()` (o `__io_putchar`) sobre `CDC_Transmit_FS()`:
  - No bloquear si el host no ha abierto el puerto o el dispositivo no está enumerado (`hUsbDeviceFS.dev_state != USBD_STATE_CONFIGURED`) → descartar o encolar en un buffer circular estático.
  - Reintentar con timeout acotado ante `USBD_BUSY`; nunca un bucle infinito.
  - Nunca llamar `printf`/`CDC_Transmit_FS` desde una ISR.
- Aumentar el heap/stack del `.ioc` si se usa `printf` con formato de floats (`-u _printf_float`).

## 3. Pulsadores: anti-rebote por software

- Toda entrada de pulsador lleva **debounce por software no bloqueante** basado en `HAL_GetTick()`, con ventana configurable (`#define BUTTON_DEBOUNCE_MS 30u`, típico 20–50 ms).
- Patrón: muestrear el pin, y aceptar el nuevo estado solo si se mantuvo estable durante toda la ventana. Detectar flancos (presionado/soltado) sobre el estado filtrado, no sobre el pin crudo.
- Si el pulsador usa EXTI: la ISR solo marca el evento y guarda el tick (`volatile`); el filtrado y la acción se hacen fuera de la ISR (loop principal o tarea).
- Prohibido `HAL_Delay()` en ISR o como método de debounce.
- Configurar pull-up/pull-down en el `.ioc` según el circuito de la placa, y documentarlo.

## 4. Compilar y verificar

- Al terminar, **compilar** el proyecto: Debug y, si existe, Release.
  - Proyectos CMake (CubeMX `TargetToolchain=CMake`): `cmake --preset Debug && cmake --build --preset Debug`.
  - Si `arm-none-eabi-gcc`, `cmake` o `ninja` no están en el PATH, buscarlos en `%LOCALAPPDATA%\stm32cube\bundles\{gnu-tools-for-stm32,cmake,ninja}\<versión>\bin` (STM32CubeCLT / extensión STM32 de VS Code) y anteponerlos al PATH solo para el comando.
  - Proyectos STM32CubeIDE: `headless-build` de STM32CubeIDE, o avisar si no está disponible.
- Criterio de éxito: **0 errores y 0 warnings en el código propio**. Además, pasar el código propio por `-Wall -Wextra -Wpedantic -Wshadow`.
- Reportar el uso de **FLASH y RAM** (salida del linker o `arm-none-eabi-size`) y confirmar con `arm-none-eabi-nm` que los símbolos clave (IRQ handlers, callbacks HAL) quedaron enlazados.
- Si algo falla, mostrar el error real. Nunca afirmar que compila sin haberlo compilado.
- Aclarar siempre que compilar no equivale a probar en hardware.

## 5. README.md en la raíz del proyecto

Crear o actualizar `README.md` con estas secciones:

1. **Descripción:** qué hace el proyecto en 2–3 líneas; MCU exacto (según el `.ioc`), placa y hardware externo.
2. **Modificaciones en el `.ioc`:** periféricos, pines, DMA, NVIC y clocks agregados o cambiados, con el porqué de las decisiones no obvias (prescalers, prioridades, streams DMA). Anotar si alguna parte del código generado se replicó a mano y por qué.
3. **Tabla de conexiones:**

   | Señal del dispositivo | GPIO STM32 | User Label CubeMX | Función | Pin físico en la placa |
   |---|---|---|---|---|

   Más un diagrama ASCII si hay más de 4 señales, y advertencias de conexión (voltajes, pines que no están en el conector esperado, etc.).
4. **Librerías usadas:** STM32 HAL (versión de firmware package), middlewares (USB Device, FATFS, FreeRTOS…) y cualquier librería externa, con su versión.
5. **Funciones y registros importantes:** API pública de los módulos propios (tabla función → descripción), callbacks HAL e ISR usados, y registros o comandos del periférico/dispositivo externo que el código configura (por ejemplo, comandos de un controlador de pantalla o registros de un sensor), con su valor y significado.
6. **Compilar y grabar:** comandos exactos y uso de memoria verificado.
7. **Troubleshooting:** síntomas típicos → causa → solución, cuando aplique.
