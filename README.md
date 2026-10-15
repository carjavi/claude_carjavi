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
claude_carjavi/
├── CLAUDE.md                    (reglas globales -> ~/.claude/CLAUDE.md)
├── skills/                      (skills propias -> ~/.claude/skills/)
│   ├── python-defaults/SKILL.md
│   ├── javascript-node-defaults/SKILL.md
│   ├── embedded-firmware-cpp/SKILL.md
│   ├── stm32-cubemx-project/SKILL.md
│   ├── research-references/SKILL.md
│   └── source-metadata-header/SKILL.md
├── externals.json               (skills, repos, MCP y herramientas externas a instalar)
├── externals/                   (scripts de los externos que necesitan más de un comando)
│   ├── ghidra/install.ps1 · install.sh
│   └── rea/install.ps1 · install.sh
├── install.ps1                  (Windows)
└── install.sh                   (macOS/Linux)
```

## Install
Un solo instalador deja el PC listo: copia `CLAUDE.md` y las skills propias a `~/.claude/`, y después instala todo lo declarado en [`externals.json`](#skills-externas) (hoy: Ghidra + REA). Volver a correrlo actualiza todo.

**Requisitos previos**
- Git.
- Node.js **22.19+**, **24.11+** o **26+** con npm. En Windows: `winget install OpenJS.NodeJS.LTS`.
- ~1,5 GB libres (Ghidra + JDK).
- **Claude Desktop cerrado por completo** (icono de la bandeja → *Quit*). Si está abierto puede borrar el registro de los MCP; el instalador lo detecta y omite Claude Desktop en ese caso.

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

### Linux / macOS
```bash
cd claude_carjavi
chmod +x install.sh && ./install.sh
```

### Actualizar (en cualquier PC)
```bash
cd claude_carjavi
git pull
# y vuelve a correr el instalador de tu sistema (arriba)
```

Al terminar: **abre una terminal nueva** (para que tome `GHIDRA_INSTALL_DIR` y `JAVA_HOME`) y **reinicia Claude Code / Claude Desktop**. El instalador termina con un resumen de lo instalado, lo omitido y lo que falló; un item que falla no detiene a los demás.

<br>

# Mis Skills

Skills escritas por mí. Cada una es una carpeta en [`skills/`](./skills) y el instalador la copia completa a `~/.claude/skills/`. Su contenido está más abajo, en [Archivos *.md](#archivos-md).

| Skill | Qué hace |
|---|---|
| [`python-defaults`](#skill-python-defaults) | Defaults para Python: type hints, async, logging JSON, FastAPI + Pydantic, MQTT/Modbus/RS485. |
| [`javascript-node-defaults`](#skill-javascript-node) | Defaults para JS/Node y frontend: LTS, async/await, React + WebSerial + WebSocket. |
| [`embedded-firmware-cpp`](#skill-embedded-firmware) | Estándares de firmware C/C++ (ESP32, STM32, RPi, Arduino): C++17, FreeRTOS, memoria, logging. |
| [`stm32-cubemx-project`](#skill-stm32-cubemx-project) | Flujo STM32CubeMX: `.ioc` + CLI, USER CODE, USB CDC, anti-rebote, README del proyecto. |
| [`research-references`](#skill-research-references) | Investigar antes de generar código y cerrar con sección de Referencias. |
| [`source-metadata-header`](#skill-source-metadata-header) | Bloque de metadata (@author, @version...) en cada archivo fuente. |

**Agregar una skill propia**: crea `skills/<nombre>/SKILL.md` (más `references/` o `scripts/` si los necesita) y agrégala a la tabla.

<br>

<br>

<br>

# Skills Externas

Skills de otros repositorios, junto con los MCP y herramientas que necesitan. Se instalan desde [`externals.json`](./externals.json) en el orden en que aparecen ahí. Cada skill tiene su propia sección.

| Skill | Qué es | Items en `externals.json` |
|---|---|---|
| [reverse-engineer-anything (REA)](#reverse-engineer-anything-rea) | Ingeniería inversa de programas, apps, webs y firmware con Claude. | `ghidra`, `jadx`, `rea` |

Para sumar una nueva, sigue [Agregar una skill externa](#agregar-una-skill-externa).

<br>

## reverse-engineer-anything (REA)

[REA — Reverse Engineer Anything](https://github.com/morluto/rea) (licencia MIT) conecta a Claude con herramientas de ingeniería inversa para investigar software **sin tener su código fuente**: ejecutables nativos, apps JavaScript/Electron, ensamblados .NET, sitios web, APKs y firmware. Todo el análisis corre en el PC; a Claude solo le llegan los resultados.

### Qué hace

Son tres piezas que se instalan juntas:

| Pieza | Para qué |
|---|---|
| **CLI `rea`** | Analizar desde la terminal (`rea inspect`, `rea decompile`, ...). |
| **Servidor MCP `rea`** | Le da a Claude las herramientas de análisis: inspeccionar, decompilar, rastrear llamadas e IPC, comparar versiones. |
| **Skill `reverse-engineer-anything`** | Le enseña a Claude **cuándo** usar REA y **cómo** investigar. |

La skill guía a Claude para:
- **Elegir la herramienta según el objetivo**: un `.asar` o app Electron → análisis de JavaScript; un `.exe` .NET → metadata gestionada; un binario nativo → Ghidra; una web → captura del navegador; un APK → análisis Android.
- **Responder con evidencia**: cada conclusión cita el archivo, la función o la dirección de donde sale, y separa lo comprobado de lo inferido y lo desconocido.
- **No usar REA cuando no hace falta**: si tienes el código fuente completo, Claude lo lee directamente.
- **Diagnosticar** si faltan herramientas o registros (`rea doctor`) antes de reintentar a ciegas.

### Qué puede analizar

No es solo para archivos locales. REA trabaja con archivos en tu PC, con **sitios web en vivo** (abre la página en un navegador Chrome/Edge y observa lo que pasa) y con capturas de red o dispositivos Android conectados.

| Objetivo | Qué obtiene Claude | Windows | Necesita |
|---|---|---|---|
| **App Electron / JavaScript** (VS Code, Arduino IDE 2, Discord, Postman, `.asar`) | Módulos, imports, source maps, rutas, canales IPC, add-ons nativos. | ✅ | Node.js (ya instalado) |
| **Programa .NET** (`.exe`/`.dll` en C#, WinForms, WPF) | Clases, métodos, firmas, strings. Sin ejecutarlo. | ✅ | Nada extra |
| **Ejecutable nativo** (C/C++, Go, Rust: `.exe`, ELF) | Funciones, pseudocódigo decompilado, ensamblador, strings, imports. | ⚠️ Solo `.exe` x86-64 | Ghidra (ya instalado) |
| **Sitio o aplicación web** (URL pública o `localhost`) | Estructura de la página, scripts cargados, peticiones de red/APIs, capturas de pantalla. | ✅ | Chrome o Edge |
| **Captura de red guardada** (`.har` del navegador, Fiddler) | Endpoints, parámetros, cabeceras, flujo de llamadas. | ✅ | Nada extra |
| **APK Android** (incluye Flutter) | Código Java/Kotlin decompilado, manifiesto, permisos, recursos. | ✅ | JADX + JDK 17+ (ya instalados) |
| **Dispositivo Android conectado** | Logs, dumps, capturas. | ✅ | `adb` |
| **Firmware** (`.bin`, `.elf` de STM32/ESP32, imágenes de router) | Particiones, sistemas de archivos, decompilado ARM. | ❌ Usa Linux/WSL | Ghidra, Binwalk/Unblob |
| **Comportamiento en ejecución** (lanzar un proceso y observarlo) | Salida, archivos y procesos que abre. | ❌ Solo Linux/macOS | — |
| **Otros**: bases SQLite, WASM, bytecode EVM, grabaciones de analizador lógico | Estructura y contenido. | ✅ | — |

### Dónde es bueno y dónde no

**Brilla en:**
- **Entender cómo hace algo una app que no es tuya** para replicarlo en tu proyecto (cómo detecta puertos serie, cómo arma un protocolo, qué API llama).
- **Interoperabilidad**: descubrir el protocolo, formato de archivo o API que usa un programa para que tu código hable con él.
- **Apps Electron y .NET**: el código se recupera casi completo y legible; son los casos con mejores resultados.
- **Webs**: ver qué APIs llama el frontend, qué parámetros manda y qué devuelve, sin abrir DevTools a mano.
- **Depurar tus propios builds** sin el código a mano, o comparar dos versiones para ver qué cambió.

**No esperes milagros con:**
- **Código del servidor de una web**: REA solo ve lo que llega al navegador (HTML, JS, peticiones). La lógica del backend no se puede ver.
- **Binarios nativos grandes, sin símbolos u ofuscados**: el pseudocódigo de Ghidra es aproximado, con nombres genéricos (`FUN_00401a20`). Sirve para entender, no para recompilar.
- **Apps protegidas** (ofuscadores, packers, anti-debug, DRM): REA no las desofusca.
- **Apps móviles iOS** y apps de la Microsoft Store empaquetadas/cifradas: no soportadas.
- **Sitios con login**: necesitas iniciar sesión tú, o darle a Claude un `.har` exportado desde tu navegador.

### Qué instala el instalador (`ghidra` + `jadx` + `rea`)

| Componente | Windows | Linux |
|---|---|---|
| JDK 21 (Temurin), solo si no hay uno | `%LOCALAPPDATA%\Programs\jdk\` | `~/.local/opt/jdk/` |
| Ghidra 12.1.4 | `%LOCALAPPDATA%\Programs\ghidra\` | `~/.local/opt/ghidra/` |
| `GHIDRA_INSTALL_DIR`, `JAVA_HOME` | Variables de usuario | `~/.config/claude_carjavi/env.sh` (cargado desde `~/.profile` y `~/.bashrc`) |
| jadx-headless-mcp 0.7.1 (motor JADX para APKs, SHA-256 verificado) | `%LOCALAPPDATA%\Programs\jadx\` | `~/.local/opt/jadx/` |
| `REA_JADX_MCP_JAR` | Variable de usuario | `~/.config/claude_carjavi/jadx.sh` (cargado desde `~/.profile` y `~/.bashrc`) |
| CLI `rea` | `npm install --global rea-agents` | igual |
| MCP `rea` en Claude Code | `~/.claude.json` | igual |
| MCP `rea` en Claude Desktop | `claude_desktop_config.json` | igual |
| Skill | `~/.claude/skills/reverse-engineer-anything/` | igual |

- Nada pide permisos de administrador.
- `JAVA_HOME` solo se define si no existe o no es un JDK válido, para no romper el Java de otras herramientas (STM32CubeIDE, Arduino, etc.). Si ya apunta a otro Java, el instalador avisa.
- En macOS se omite Ghidra: REA usa Hopper en Mac, y `rea setup` (sin `--yes`) ofrece instalarlo.

### Instalación manual (solo REA, sin el instalador)
```bash
npm install --global rea-agents
rea setup --yes --client claude_code --client claude_desktop
```
Sin `--yes`, `rea setup` muestra el plan y pide aprobación antes de escribir.

### Verificar
```bash
rea --version
rea doctor --client claude_code --provider ghidra
```
En Claude Code, `/mcp` debe mostrar `rea` conectado. También puedes preguntarle a Claude: *"¿tienes disponibles las herramientas de REA?"*.

### Cómo hablarle (lenguaje natural)

**No necesitas saber los comandos `rea`.** Háblale a Claude como a un colega: dile *qué* quieres entender y *dónde* está el programa. Claude elige la herramienta (JavaScript, .NET, Ghidra, navegador, APK), ejecuta los comandos y te responde con evidencia. Los comandos de la [sección de terminal](#ejemplos-de-uso-desde-la-terminal) son opcionales.

**Para mejores resultados, incluye en tu pedido:**
1. **Qué es y dónde está**: ruta del archivo o carpeta, URL, o el nombre de la app instalada ("está en `C:\Program Files\...`" o "búscala tú").
2. **La pregunta concreta**: "cómo detecta los puertos", no "analízalo todo". Un pedido enfocado da respuestas mucho mejores.
3. **Qué quieres al final**: una explicación, un diagrama del flujo, o código en tu proyecto que haga lo mismo.
4. Opcional: *"muéstrame la evidencia"* y *"separa lo comprobado de lo que supones"*.

La skill se activa sola cuando la tarea depende de un programa ya compilado. Si no se activa, menciona "usa REA" en el pedido.

#### Programas de escritorio
- **App Electron instalada**: *"Quiero saber cómo Arduino IDE 2 detecta y lista los puertos serie. Está instalado en mi PC, búscalo tú. Muéstrame los archivos, funciones y canales IPC involucrados."*
- **Copiar una funcionalidad**: *"Me gusta cómo funciona el buscador de Obsidian. Investiga cómo está hecho y arma algo parecido en mi proyecto en React."*
- **Herramienta .NET de un fabricante**: *"Tengo `C:\tools\ConfigTool.exe`, el configurador de un variador de frecuencia. Creo que es .NET. Averigua qué comandos manda por el puerto serie y con qué formato, para replicarlo en Python."*
- **Ejecutable nativo**: *"Inspecciona `C:\builds\mi_app.exe` (es mi build de Release, sin el código a mano) y explícame qué hace la función que procesa los paquetes recibidos."*
- **Formato de archivo**: *"El programa `C:\Program Files\DataLogger\logger.exe` guarda archivos `.dlg`. Averigua cómo los escribe para que pueda leerlos con un script en Python."*
- **Comparar versiones**: *"Tengo la versión 1.2 y la 1.3 de mi app Electron en `D:\releases\`. ¿Qué cambió en el manejo de la conexión?"*

#### Web y aplicaciones web
- **APIs de una web**: *"Abre https://ejemplo.com, usa el buscador con la palabra 'sensor' y dime a qué APIs llama, con qué parámetros y qué devuelve."*
- **Cómo está hecha una web**: *"Mira https://ejemplo.com y dime con qué framework está hecha, qué librerías carga y cómo arma el menú desplegable."*
- **Mi propia web app**: *"Tengo mi app corriendo en http://localhost:3000. Observa qué peticiones hace al cargar el dashboard y por qué tarda tanto."*
- **Sitio con login (vía HAR)**: *"Exporté un HAR desde Chrome mientras usaba el panel de mi router: `C:\temp\router.har`. Explícame cómo se autentica y qué endpoint cambia la configuración WiFi."*

#### Android
- **APK**: *"Analiza `C:\Downloads\app_domotica.apk` y dime cómo se comunica con el dispositivo: ¿Bluetooth, WiFi, MQTT? Muéstrame las clases y los mensajes que manda."*
- **Permisos y servicios**: *"¿Qué permisos pide `mi_app.apk` y qué servidores contacta?"*

#### Firmware (Linux/WSL)
- **STM32**: *"Decompila `build/firmware.bin` (STM32, ARM Cortex-M, cargado en 0x08000000) y compara la rutina de inicialización con mi código en `Core/Src/main.c`."*
- **Imagen de un equipo**: *"Extrae `router_fw.bin` y dime qué sistema de archivos tiene, qué servicios arranca y dónde guarda la configuración."*

#### Diagnóstico
- *"¿Tienes disponibles las herramientas de REA? Revisa qué falta para analizar APKs."*

### Ejemplos de uso desde la terminal
Opcional: lo mismo que hace Claude, pero a mano.
```bash
# App JavaScript/Electron (carpeta extraída o archivo .asar)
rea analyze-javascript-application "C:/ruta/MiApp/resources/app.asar" --json

# Resumen de un programa o binario
rea inspect "C:/builds/mi_app.exe" --provider ghidra --format md

# Decompilar una función (por nombre o dirección)
rea decompile "C:/builds/mi_app.exe" procesar_paquete --provider ghidra --format md

# Ensamblado .NET: miembros, firmas y strings, sin ejecutarlo
rea inspect-managed-members "C:/tools/MiHerramienta.exe"

# Firmware crudo ARM (solo Linux; ver limitaciones)
rea inspect build/firmware.bin --target-format raw-binary --architecture arm --entry-point 0x08000000 --provider ghidra

# Lista completa de comandos
rea --help
```

### Limitaciones
- **Windows + Ghidra es experimental en REA**: solo admite ejecutables nativos **x86-64 (.exe)**, no DLL, ARM ni 32 bits, y solo lectura. Para firmware ARM/ELF o análisis nativo completo, usa Linux (o WSL).
- El análisis estático de JavaScript/Electron y .NET funciona en Windows sin Ghidra.
- **APK**: el análisis es estático (lee el APK, no lo ejecuta). Necesita el JDK 17+ que instala el item `ghidra`; en macOS, donde ese item se omite, instala un JDK aparte. Los recursos con Apktool y los dispositivos por `adb` requieren instalar esas herramientas aparte.
- **Reinicia Claude Code y Claude Desktop después de instalar**, para que el servidor MCP de REA lea `REA_JADX_MCP_JAR` y `JAVA_HOME`.
- No se instalan IDA ni Hopper; REA los usa si los configuras aparte.
- **Webs**: necesita Chrome o Edge instalado. Solo ve el lado del navegador; el código del servidor queda fuera de alcance.
- **Observar un programa mientras corre** (procesos, archivos que abre): solo Linux/macOS. En Windows el análisis es estático (lee los archivos sin ejecutarlos).
- Firmware con Binwalk/Unblob y capturas de paquetes con TShark: solo Linux, con esas herramientas instaladas.
- **Sin desofuscación**: código ofuscado, empaquetado (UPX, Themida) o binarios sin símbolos dan resultados parciales.
- **El análisis cuesta contexto**: programas grandes generan mucha salida. Pide una pregunta concreta en vez de "analízalo todo".
- **Uso legal**: REA es para investigación, interoperabilidad, educación y software propio o que estés autorizado a analizar.

### Actualizar / desinstalar
```bash
# Actualizar: vuelve a correr el instalador, o solo REA:
rea update

# Desinstalar REA (registros MCP + skill); --purge-data borra también caché y estado
rea uninstall
```
Ghidra, JADX y el JDK se desinstalan borrando sus carpetas (tabla de arriba) y las variables `GHIDRA_INSTALL_DIR` / `REA_JADX_MCP_JAR` / `JAVA_HOME`.

<br>

## Agregar una skill externa

Cada skill externa necesita dos cosas: su **instalación** en `externals.json` y su **sección** en este README.

**1. Instalación** — agrega una entrada a [`externals.json`](./externals.json). Campos:

| Campo | Qué es |
|---|---|
| `name` | Identificador corto. |
| `description` | Se muestra durante la instalación. |
| `docs` | URL de referencia (opcional). |
| `enabled` | `false` para desactivarlo sin borrarlo. |
| `windows` | Lista de comandos PowerShell. La ruta del repo está en `$env:REPO_ROOT`. |
| `unix` | Lista de comandos bash. La ruta del repo está en `$REPO_ROOT`. |

Reglas:
- Los items se instalan **en orden**; si uno depende de otro, va después (REA va después de Ghidra y JADX).
- Si un comando falla, se saltan los demás comandos de ese item y se sigue con el siguiente item.
- Los comandos deben poder **repetirse sin romper nada**, porque re-correr el instalador es la forma de actualizar.
- Si necesitas más de 2 o 3 comandos, crea `externals/<nombre>/install.ps1` e `install.sh` y llámalos desde el JSON.
- En Windows, los comandos con `--` (como `claude mcp add ... -- npx ...`) van dentro de `cmd /c '...'`, porque PowerShell puede comerse el `--`.

Plantillas:

```json
{
  "name": "mi-mcp",
  "description": "Servidor MCP de ejemplo para Claude Code",
  "docs": "https://github.com/usuario/mi-mcp",
  "enabled": true,
  "windows": [
    "if (-not ((claude mcp list) -match '^mi-mcp:')) { cmd /c 'claude mcp add --scope user mi-mcp -- npx -y paquete-mi-mcp' }"
  ],
  "unix": [
    "claude mcp get mi-mcp >/dev/null 2>&1 || claude mcp add --scope user mi-mcp -- npx -y paquete-mi-mcp"
  ]
}
```

```json
{
  "name": "skill-de-otro-repo",
  "description": "Skill publicada en un repositorio de GitHub",
  "enabled": true,
  "windows": [
    "$d = Join-Path $env:TEMP 'skill-repo'; Remove-Item $d -Recurse -Force -ErrorAction SilentlyContinue; git clone --depth 1 https://github.com/usuario/repo $d",
    "Copy-Item (Join-Path $d 'skills\\nombre-skill') (Join-Path $env:USERPROFILE '.claude\\skills') -Recurse -Force"
  ],
  "unix": [
    "rm -rf /tmp/skill-repo && git clone --depth 1 https://github.com/usuario/repo /tmp/skill-repo && cp -r /tmp/skill-repo/skills/nombre-skill ~/.claude/skills/"
  ]
}
```

**2. Documentación** — agrega una fila a la tabla de [Skills Externas](#skills-externas) y una sección `## <nombre-de-la-skill>` nueva justo antes de esta, con esta estructura:

```markdown
## nombre-de-la-skill

Qué es, de dónde viene (link al repo) y licencia.

### Qué hace
### Qué instala el instalador
### Verificar
### Ejemplos de uso
### Limitaciones
### Actualizar / desinstalar

<br>
```

<br>

<br>

<br>

# Archivos *.md
## claude.md
```bash
# CLAUDE.md

Este archivo da guía **global** a Claude Code (claude.ai/code) en todos mis repositorios. Para que aplique en todos lados debe copiarse a `~/.claude/CLAUDE.md`; cualquier `CLAUDE.md` dentro de un proyecto específico complementa o sobreescribe lo que diga aquí.

Las convenciones específicas por lenguaje/plataforma viven como skills en `skills/` (se instalan en `~/.claude/skills/` y se activan solas según la tarea): `python-defaults`, `javascript-node-defaults`, `embedded-firmware-cpp`, `stm32-cubemx-project`, `research-references`, `source-metadata-header`. Instalar con `install.ps1` (Windows) o `install.sh` (macOS/Linux) — sobrescriben lo que ya exista con el mismo nombre.

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

## Skill stm32-cubemx-project
````bash
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
````

<br>

## install.ps1

```PowerShell
# install.ps1 - Instala en este PC todo lo del repo: CLAUDE.md y skills propias en ~/.claude/
# y los items externos (skills, repos, MCP, herramientas) declarados en externals.json.
# @author: Carlos Briceño <carjavi@hotmail.com>
# @date: 15-10-2026
# @copyright: Copyright (c) 2026 www.carjavi.com
# @version: V2.0
# @library: No external dependencies (cada item de externals.json declara las suyas)
#
# Sobrescribe archivos existentes con el mismo nombre. Volver a correrlo actualiza todo.

$ErrorActionPreference = "Stop"

$repoRoot = $PSScriptRoot
$env:REPO_ROOT = $repoRoot
$claudeDir = Join-Path $env:USERPROFILE ".claude"
$skillsDir = Join-Path $claudeDir "skills"

New-Item -ItemType Directory -Force -Path $claudeDir | Out-Null
New-Item -ItemType Directory -Force -Path $skillsDir | Out-Null

# --- 1. CLAUDE.md global -----------------------------------------------------
Copy-Item -Path (Join-Path $repoRoot "CLAUDE.md") -Destination (Join-Path $claudeDir "CLAUDE.md") -Force
Write-Output "CLAUDE.md instalado en $claudeDir"

# --- 2. Skills propias (carpeta completa: SKILL.md + references/scripts) -----
Get-ChildItem -Path (Join-Path $repoRoot "skills") -Directory | ForEach-Object {
    $destSkillDir = Join-Path $skillsDir $_.Name
    New-Item -ItemType Directory -Force -Path $destSkillDir | Out-Null
    Copy-Item -Path (Join-Path $_.FullName "*") -Destination $destSkillDir -Recurse -Force
    Write-Output "Skill instalada: $($_.Name)"
}

# --- 3. Externos (externals.json) --------------------------------------------
$manifestPath = Join-Path $repoRoot "externals.json"
$ok = @()
$failed = @()
$skipped = @()

if (Test-Path $manifestPath) {
    $manifest = Get-Content -Path $manifestPath -Raw -Encoding UTF8 | ConvertFrom-Json
    foreach ($item in $manifest.items) {
        if ($item.enabled -eq $false) { $skipped += $item.name; continue }
        if (-not $item.windows) {
            Write-Output "`n== $($item.name): sin comandos para Windows, se omite"
            $skipped += $item.name
            continue
        }
        Write-Output "`n== $($item.name): $($item.description)"
        try {
            foreach ($command in $item.windows) {
                $global:LASTEXITCODE = 0
                Invoke-Expression $command
                if ($LASTEXITCODE -ne 0) { throw "codigo de salida $LASTEXITCODE en: $command" }
            }
            $ok += $item.name
        } catch {
            Write-Warning "$($item.name) fallo: $($_.Exception.Message)"
            $failed += $item.name
        }
    }
}

# --- Resumen -----------------------------------------------------------------
Write-Output "`n================ Resumen ================"
if ($ok) { Write-Output ("Instalados: " + ($ok -join ", ")) }
if ($skipped) { Write-Output ("Omitidos:   " + ($skipped -join ", ")) }
if ($failed) {
    Write-Output ("Con errores: " + ($failed -join ", ") + "  (revisa los mensajes de arriba y vuelve a correr)")
}
Write-Output "Abre una terminal nueva y reinicia Claude Code / Claude Desktop para cargar los cambios."
Write-Output "Listo."
if ($failed) { exit 1 }
```

<br>

## install.sh

```bash
#!/usr/bin/env bash
# install.sh - Instala en este PC todo lo del repo: CLAUDE.md y skills propias en ~/.claude/
# y los items externos (skills, repos, MCP, herramientas) declarados en externals.json.
# @author: Carlos Briceño <carjavi@hotmail.com>
# @date: 15-10-2026
# @copyright: Copyright (c) 2026 www.carjavi.com
# @version: V2.0
# @library: node o python3 (solo para leer externals.json)
#
# Sobrescribe archivos existentes con el mismo nombre. Volver a correrlo actualiza todo.
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export REPO_ROOT="$repo_root"
claude_dir="$HOME/.claude"
skills_dir="$claude_dir/skills"
env_file="$HOME/.config/claude_carjavi/env.sh"   # variables que dejan los items externos

mkdir -p "$claude_dir" "$skills_dir"

# --- 1. CLAUDE.md global -----------------------------------------------------
cp -f "$repo_root/CLAUDE.md" "$claude_dir/CLAUDE.md"
echo "CLAUDE.md instalado en $claude_dir"

# --- 2. Skills propias (carpeta completa: SKILL.md + references/scripts) -----
for dir in "$repo_root"/skills/*/; do
    name="$(basename "$dir")"
    mkdir -p "$skills_dir/$name"
    cp -rf "$dir". "$skills_dir/$name/"
    echo "Skill instalada: $name"
done

# --- 3. Externos (externals.json) --------------------------------------------
# Convierte el manifiesto en lineas "ITEM<TAB>nombre<TAB>descripcion" / "CMD<TAB>comando" / "SKIP<TAB>nombre".
read_manifest() {
    local script='
const m = JSON.parse(require("fs").readFileSync(process.argv[1], "utf8"));
for (const it of m.items || []) {
  if (it.enabled === false || !(it.unix || []).length) { console.log(`SKIP\t${it.name}`); continue; }
  console.log(`ITEM\t${it.name}\t${it.description || ""}`);
  for (const c of it.unix) console.log(`CMD\t${c}`);
}'
    if command -v node >/dev/null 2>&1; then
        node -e "$script" "$1"
    elif command -v python3 >/dev/null 2>&1; then
        python3 -c '
import json, sys
m = json.load(open(sys.argv[1], encoding="utf-8"))
for it in m.get("items", []):
    cmds = it.get("unix") or []
    if it.get("enabled") is False or not cmds:
        print("SKIP\t" + it["name"]); continue
    print("ITEM\t%s\t%s" % (it["name"], it.get("description", "")))
    for c in cmds: print("CMD\t" + c)' "$1"
    else
        echo "ERROR: se necesita node o python3 para leer externals.json" >&2
        return 1
    fi
}

ok=(); failed=(); skipped=()
current=""; current_failed=0

# Cierra el item en curso y lo anota como instalado o con error.
finish_item() {
    [ -z "$current" ] && return
    if [ "$current_failed" -eq 0 ]; then ok+=("$current"); else failed+=("$current"); fi
    current=""
}

if [ -f "$repo_root/externals.json" ]; then
    manifest_lines="$(read_manifest "$repo_root/externals.json")"
    while IFS=$'\t' read -r kind name rest; do
        case "$kind" in
            SKIP) skipped+=("$name") ;;
            ITEM)
                finish_item
                current="$name"; current_failed=0
                printf '\n== %s: %s\n' "$name" "$rest"
                ;;
            CMD)
                [ "$current_failed" -ne 0 ] && continue
                command_line="$name${rest:+	$rest}"
                # Cada comando ve las variables que dejaron los items anteriores (p. ej. GHIDRA_INSTALL_DIR).
                if ! ( [ -f "$env_file" ] && . "$env_file"; bash -c "$command_line" ); then
                    echo "AVISO: $current fallo en: $command_line" >&2
                    current_failed=1
                fi
                ;;
        esac
    done <<< "$manifest_lines"
    finish_item
fi

# --- Resumen -----------------------------------------------------------------
echo
echo "================ Resumen ================"
[ ${#ok[@]} -gt 0 ] && echo "Instalados: ${ok[*]}"
[ ${#skipped[@]} -gt 0 ] && echo "Omitidos:   ${skipped[*]}"
[ ${#failed[@]} -gt 0 ] && echo "Con errores: ${failed[*]}  (revisa los mensajes de arriba y vuelve a correr)"
echo "Abre una terminal nueva y reinicia Claude Code / Claude Desktop para cargar los cambios."
echo "Listo."
[ ${#failed[@]} -eq 0 ]
```

<br>

## externals.json

```json
{
  "_help": [
    "Lista de skills, repositorios, MCP y herramientas externas que install.ps1 / install.sh instalan automaticamente.",
    "Se procesan en orden: si un item necesita otro (REA usa Ghidra), ponlo despues.",
    "Campos: name, description, docs (URL), enabled (false = se omite), windows (comandos PowerShell), unix (comandos bash).",
    "Los comandos se ejecutan uno por uno; si uno falla se salta el resto de ese item y se sigue con el siguiente.",
    "Variable disponible: la ruta del repo en $env:REPO_ROOT (Windows) o $REPO_ROOT (Linux/macOS).",
    "Los comandos deben ser idempotentes: volver a correr el instalador sirve para actualizar."
  ],
  "items": [
    {
      "name": "ghidra",
      "description": "Ghidra 12.1.4 + JDK 21: motor de analisis nativo que usa REA para decompilar binarios",
      "docs": "https://github.com/NationalSecurityAgency/ghidra",
      "enabled": true,
      "windows": [
        "& \"$env:REPO_ROOT\\externals\\ghidra\\install.ps1\" -Version 12.1.4"
      ],
      "unix": [
        "bash \"$REPO_ROOT/externals/ghidra/install.sh\" 12.1.4"
      ]
    },
    {
      "name": "jadx",
      "description": "jadx-headless-mcp 0.7.1: motor JADX que usa REA para decompilar APKs Android (usa el JDK 21 del item ghidra)",
      "docs": "https://github.com/morluto/rea/blob/main/docs/android-analysis.md",
      "enabled": true,
      "windows": [
        "& \"$env:REPO_ROOT\\externals\\jadx\\install.ps1\" -Version 0.7.1"
      ],
      "unix": [
        "bash \"$REPO_ROOT/externals/jadx/install.sh\" 0.7.1"
      ]
    },
    {
      "name": "rea",
      "description": "REA (Reverse Engineer Anything): CLI + servidor MCP + skill reverse-engineer-anything para Claude Code y Claude Desktop",
      "docs": "https://github.com/morluto/rea",
      "enabled": true,
      "windows": [
        "& \"$env:REPO_ROOT\\externals\\rea\\install.ps1\""
      ],
      "unix": [
        "bash \"$REPO_ROOT/externals/rea/install.sh\""
      ]
    }
  ]
}
```

Los scripts de cada externo están en [`externals/ghidra/`](./externals/ghidra), [`externals/jadx/`](./externals/jadx) y [`externals/rea/`](./externals/rea).

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





