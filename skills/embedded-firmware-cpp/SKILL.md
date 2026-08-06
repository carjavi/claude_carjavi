---
name: embedded-firmware-cpp
description: Estándares para firmware embebido en C/C++ (ESP32, STM32, Raspberry Pi, Arduino) — mínimo C++17, FreeRTOS sin delays bloqueantes, manejo de memoria/heap, logging por niveles, documentación de GPIO/protocolos/timing crítico, testing de drivers. Usar al escribir o revisar código embebido/firmware.
---

Los siguientes son defaults para proyectos nuevos o sin stack definido (ver CLAUDE.md §0 — si el proyecto ya tiene convenciones, esas ganan).

### C / C++
- Mínimo C++17.
- Documentar ISR y tareas críticas.
- Priorizar bajo consumo y estabilidad; evitar asignación dinámica innecesaria.

### Sistemas embebidos

**FreeRTOS:** sin delays bloqueantes; usar queues, semaphores, event groups. Toda tarea define stack, prioridad y timeout.

**Memoria:** minimizar fragmentación del heap, evitar `malloc` cuando se pueda, preferir buffers estáticos, monitorear heap y stack watermark.

**Logging:** niveles ERROR/WARN/INFO/DEBUG. Nunca imprimir dentro de una ISR.

**Hardware:** documentar siempre GPIO, voltajes, protocolos y timing crítico. Considerar ruido eléctrico, consumo, protección ESD y fuentes de alimentación.

**Protocolos frecuentes:** UART, SPI, I2C, CAN, RS485, Modbus, MQTT, BLE, WiFi, LoRa/LoRaWAN.

**Testing:** todo driver incluye test funcional, test de timeout y test de reconexión.
