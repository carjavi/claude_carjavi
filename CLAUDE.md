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
