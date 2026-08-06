---
name: python-defaults
description: Defaults para proyectos Python nuevos o sin convención propia — type hints, async/await, logging JSON estructurado, arquitectura services/models/api/utils, APIs con FastAPI+Pydantic+JWT, comunicaciones industriales (MQTT/Modbus TCP/RS485) con retry/timeout/watchdog. Usar al iniciar o estructurar un proyecto Python.
---

Los siguientes son defaults para proyectos nuevos o sin stack definido (ver CLAUDE.md §0 — si el proyecto ya tiene convenciones, esas ganan).

- Última versión estable, type hints, `async`/`await` cuando aplique.
- Logging estructurado JSON: timestamp, nivel, módulo, request_id.
- Arquitectura: separar `services` / `models` / `api` / `utils`.
- APIs: FastAPI, con OpenAPI, validación Pydantic, manejo global de errores, JWT.
- Automatización/comunicaciones: MQTT, Modbus TCP, RS485 — toda comunicación con retry, timeout y watchdog.
