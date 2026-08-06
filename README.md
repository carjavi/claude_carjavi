<p align="center"><img src="./img/claude_banner.png" width="600"   alt=" " /></p>
<h1 align="center"> claude_carjavi </h1> 
<h4 align="right">Ago 26</h4>

<p>
  <img src="https://img.shields.io/badge/OS-Linux%20GNU-yellowgreen">
  <img src="https://img.shields.io/badge/OS-Windows%2011-blue">
  <img src="https://img.shields.io/badge/Hardware-Raspberry%20ver%204-red">
  <img src="https://img.shields.io/badge/Hardware-ESP32-red">
</p>

<br>

Mi configuración personal de Claude Code (P.D. no hay data sensibles)

## Estructura 
```bash
claude_github/
├── CLAUDE.md                    (5.865 caracteres)
├── skills/
│   ├── python-defaults/SKILL.md
│   ├── javascript-node-defaults/SKILL.md
│   ├── embedded-firmware-cpp/SKILL.md
│   ├── research-references/SKILL.md
│   └── source-metadata-header/SKILL.md
├── install.ps1                  (Windows)
└── install.sh                   (macOS/Linux )
```

## Install
```bash
git clone https://github.com/carjavi/claude_carjavi
```
### Windows
```PowerShell
# Desde PowerShell
cd claude_carjavi
# Cambia la política de seguridad de PowerShell. Bypass no exige firma ni pregunta nada, y como es -Scope Process solo aplica a esta ventana de PowerShell, no cambia la configuración de tu sistema
Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process; .\install.ps1
```

### Linux
```bash
claude_carjavi
chmod +x install.sh && ./install.sh
```

<br>

# Archivos *.md
## claude.md
```bash
# CLAUDE.md

Este archivo da guía **global** a Claude Code (claude.ai/code) en todos mis repositorios. Para que aplique en todos lados debe copiarse a `~/.claude/CLAUDE.md`; cualquier `CLAUDE.md` dentro de un proyecto específico complementa o sobreescribe lo que diga aquí.

Las convenciones específicas por lenguaje/plataforma viven como skills en `skills/` (se instalan en `~/.claude/skills/` y se activan solas según la tarea): `python-defaults`, `javascript-node-defaults`, `embedded-firmware-cpp`, `research-references`, `source-metadata-header`. Instalar con `install.ps1` (Windows) o `install.sh` (macOS/Linux) — sobrescriben lo que ya exista con el mismo nombre.

---

## 0. Precedencia (leer primero)

- Si el proyecto ya tiene convenciones establecidas (framework, linter, estilo de nombres, estructura de carpetas), **respetarlas por encima de las reglas de este archivo**. Estas reglas son el default para código nuevo o proyectos sin convención previa, no una orden de migrar código ajeno o de terceros.
- Si hay un `CLAUDE.md` de proyecto, un `.cursorrules`, o un `AGENTS.md` local con reglas más específicas, esas ganan sobre las generales de aquí.
- Ante conflicto entre dos reglas de este archivo, prioriza la más específica (por lenguaje o subsistema) sobre la general.

---

## 1. Perfil

**Áreas:** desarrollo fullstack, sistemas embebidos, automatización industrial, electrónica, APIs y servicios cloud.

**Stack habitual:** Python, JavaScript/Node.js, C/C++, FreeRTOS, Arduino IDE, Docker.

**Hardware objetivo:** ESP32 (S3, C6, C3), STM32, Raspberry Pi (5, 4, 3, Zero, Pico).

---

## 2. Reglas generales

- Priorizar código simple, mantenible y reutilizable, con arquitectura modular y una responsabilidad por módulo.
- Evitar duplicación de código y dependencias innecesarias; verificar que las librerías usadas estén mantenidas y actualizadas.
- Priorizar soluciones offline / local-first cuando sea razonable.
- Explicar brevemente las decisiones técnicas no obvias (trade-offs, por qué se descartó otra opción).
- Si el contexto de la conversación no alcanza: revisar primero `context/`, `docs/` u otro directorio de documentación del proyecto si existe, antes de buscar información externa.
- Si hay demasiadas iteraciones sin resultado en un mismo enfoque, decirlo explícitamente y sugerir alternativas técnicas en vez de seguir insistiendo.
- Manejo de errores, retries y timeouts: obligatorio en fronteras de I/O (APIs, red, buses de comunicación, drivers de hardware) — ver skill `embedded-firmware-cpp` y §6 (APIs y seguridad). No añadir manejo de errores especulativo en funciones internas puras o scripts de un solo uso donde el caso de falla no puede ocurrir.

---

## 3. Convenciones de código

- Variables y funciones en inglés.
- Python / C / C++: `snake_case`.
- JavaScript / TypeScript: `camelCase` para variables y funciones, `PascalCase` para clases y componentes React — es la convención que esperan ESLint/Prettier y el ecosistema npm; usar `snake_case` en JS genera fricción constante con linters y librerías de terceros.

> Nota: la regla original decía "snake_case en todo, nunca camelCase". La ajusté por lenguaje — si preferís mantener snake_case también en JS/TS de forma consciente, decímelo y lo dejo como excepción explícita.

---

## 4. Documentación obligatoria

Toda función, método, clase o variable importante debe documentarse con el estándar del lenguaje:

| Lenguaje | Estándar |
|---|---|
| JavaScript / TypeScript | JSDoc |
| Python | Docstrings |
| C / C++ | Doxygen |

Toda función pública documenta: descripción, parámetros, retorno, errores relevantes y ejemplo de uso cuando aplique. También: variables globales, constantes, configuración, GPIO, buffers importantes, ISR, callbacks, threads, interfaces y templates genéricos.

La documentación va inmediatamente encima de la declaración. Si cambia el comportamiento del código, actualizarla en el mismo cambio. Evitar comentarios redundantes o triviales.

---

## 5. Metadata y versionado

Todo archivo de código fuente que genere o modifique lleva un bloque de metadata al inicio absoluto del archivo — campos, formato de ejemplo, esquema de versionado y sintaxis de comentario por lenguaje: ver skill `source-metadata-header`.

---

## 6. APIs y seguridad

- REST JSON como default. Nunca hardcodear API keys ni secretos, nunca subirlos al repo.
- Toda API maneja retry, timeout, logging y errores.
- Validar y sanitizar: JSON externo, datos seriales, payloads MQTT, input de usuario.

---

## 7. Docker

Los servicios backend/API deben poder correr en Docker. No aplica a firmware/sketches de microcontrolador.

---

## 8. Cómo usar las herramientas de Claude Code para esto

- **Comandos de build/lint/test** van en el `CLAUDE.md` de cada proyecto (generado con `/init`), no acá — varían por repo y este archivo es el layer global.
- **Convenciones por lenguaje/plataforma y rutinas repetibles** (defaults de Python/JS/Node, checklist de firmware embebido, flujo de investigación, bloque de metadata) viven como **Skills** propias en `skills/` — se activan solas por descripción y no inflan el contexto en cada turno. Ver el listado al inicio de este archivo.
- **Reglas duras que no pueden depender de que el modelo se acuerde** (nunca commitear secretos, siempre agregar el header de metadata antes de guardar) conviene reforzarlas con **hooks** (`PreToolUse`/`PostToolUse` en `settings.json`, o un pre-commit hook con gitleaks) en vez de solo pedirlo por texto acá.
- Decisiones y feedback puntuales de un proyecto (por qué se eligió tal librería, un ajuste de proceso que diste en una sesión) los guarda Claude Code solo en su sistema de memoria por proyecto — no hace falta duplicarlos en este archivo, que es para reglas estables y transversales.

```

<br>

## Skill embedded-firmware
```bash
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

```


<br>

## Skill javascript-node

```bash
---
name: javascript-node-defaults
description: Defaults para proyectos JavaScript/Node.js y frontend — última LTS, async/await, separación UI/lógica/datos, stack de UI con React+WebSerial+WebSocket cuando el proyecto incluye interfaz web. Usar al iniciar o estructurar un proyecto JS/Node o una interfaz web.
---

Los siguientes son defaults para proyectos nuevos o sin stack definido (ver CLAUDE.md §0 — si el proyecto ya tiene convenciones, esas ganan).

### JavaScript / Node.js
- Última LTS, `async/await` (no callbacks legacy).
- Separar UI / lógica / acceso a datos.

### UI (cuando el proyecto incluya interfaz web)
- Frontend: React, WebSerial, WebSocket.
- Backend: Node.js.

```


<br>

## Skill python-defaults

```bash
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

```

<br>

## Skill research-references

```bash
---
name: research-references
description: Flujo de investigación antes de generar ejemplos de código — revisar contexto interno del proyecto primero, luego GitHub/documentación oficial, cómo priorizar fuentes y cerrar con sección Referencias. Usar al generar ejemplos de código complejos o arquitecturas nuevas.
---

- Antes de generar ejemplos: revisar documentación interna del proyecto (`context/`, `docs/`), ejemplos existentes y patrones ya usados en el repo.
- Si no alcanza: buscar proyectos similares en GitHub, documentación oficial y ejemplos oficiales de librerías/frameworks. Priorizar referencias mantenidas recientemente, bien documentadas, con arquitectura limpia y uso amplio en la comunidad.
- En ejemplos complejos o arquitecturas nuevas, cerrar con una sección `Referencias` listando los links usados como inspiración técnica.
- Ante múltiples enfoques válidos, explicar brevemente ventajas/desventajas e indicar cuál recomendás.
- Documentación oficial por encima de blogs externos.

text
{
Referencias:
- https://github.com/espressif/esp-idf
- https://github.com/micropython/micropython
- https://github.com/fastapi/fastapi
}

```


<br>

## Skill source-metadata-header

```bash
---
name: source-metadata-header
description: Formato del bloque de metadata (@author, @date, @copyright, @version, @library) y esquema de versionado para todo archivo de código fuente nuevo o modificado, con sintaxis de comentario por lenguaje. Usar al crear o modificar un archivo de código fuente.
---

Todo archivo de código fuente que genere o modifique lleva un bloque de metadata al inicio absoluto del archivo. **Excepciones:** archivos de configuración/lockfiles (`package-lock.json`, `.env*`, etc.), código autogenerado, y código de terceros/vendored.

Campos obligatorios: descripción breve (máx. 2 líneas), `@author`, `@date`, `@copyright`, `@version`, `@library`.

text
{
@author: Carlos Briceño <carjavi@hotmail.com>
@date: dd-mm-aaaa
@copyright: Copyright (c) 2026 www.carjavi.com
@version: V1.0
@library:
- pip install pyserial
- npm install mqtt
}

- Versionado incremental: `V1.0` inicial, `V1.1` mejoras menores, `V2.0` cambios importantes. Actualizar `@version` y `@date` cuando el archivo se modifica.
- `@library`: solo dependencias externas realmente usadas, con el comando de instalación real. Si no hay ninguna: `@library: No external dependencies`.

Comentarios por lenguaje: `#` (Python/Shell/YAML) · `//` o `/** */` (JS/TS/C/C++/Java) · `<!-- -->` (HTML/XML) · `--` (SQL/Lua).

```

<br>

## install.ps1

```PowerShell
# install.ps1 - Instala CLAUDE.md y las skills de este repo en la configuracion
# de Claude Code del usuario actual (~/.claude/). Sobrescribe archivos existentes
# con el mismo nombre.

$ErrorActionPreference = "Stop"

$repoRoot = $PSScriptRoot
$claudeDir = Join-Path $env:USERPROFILE ".claude"
$skillsDir = Join-Path $claudeDir "skills"

New-Item -ItemType Directory -Force -Path $claudeDir | Out-Null
New-Item -ItemType Directory -Force -Path $skillsDir | Out-Null

Copy-Item -Path (Join-Path $repoRoot "CLAUDE.md") -Destination (Join-Path $claudeDir "CLAUDE.md") -Force
Write-Output "CLAUDE.md instalado en $claudeDir"

Get-ChildItem -Path (Join-Path $repoRoot "skills") -Directory | ForEach-Object {
    $destSkillDir = Join-Path $skillsDir $_.Name
    New-Item -ItemType Directory -Force -Path $destSkillDir | Out-Null
    Copy-Item -Path (Join-Path $_.FullName "SKILL.md") -Destination (Join-Path $destSkillDir "SKILL.md") -Force
    Write-Output "Skill instalada: $($_.Name)"
}

Write-Output "Listo."

```

<br>

## install.sh

```bash
#!/usr/bin/env bash
# install.sh - Instala CLAUDE.md y las skills de este repo en la configuracion
# de Claude Code del usuario actual (~/.claude/). Sobrescribe archivos existentes
# con el mismo nombre.
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
claude_dir="$HOME/.claude"
skills_dir="$claude_dir/skills"

mkdir -p "$claude_dir" "$skills_dir"

cp -f "$repo_root/CLAUDE.md" "$claude_dir/CLAUDE.md"
echo "CLAUDE.md instalado en $claude_dir"

for dir in "$repo_root"/skills/*/; do
    name="$(basename "$dir")"
    mkdir -p "$skills_dir/$name"
    cp -f "$dir/SKILL.md" "$skills_dir/$name/SKILL.md"
    echo "Skill instalada: $name"
done

echo "Listo."

```


<br>

<br>

---

<div>
  <p>
    <img  align="top" width="42" style="padding:0px 0px 0px 0px;" src="./img/carjavi.png"/> Copyright &nbsp;&copy; 2023 Instinto Digital <a href="https://carjavi.github.io/" title="carjavi.github">carjavi</a>
  </p>
</div>

<p align="center">
    <a href="https://instintodigital.net/" target="_blank"><img src="./img/developer.png" height="100" alt="www.instintodigital.net"></a>
</p>





