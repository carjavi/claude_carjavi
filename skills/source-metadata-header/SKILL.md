---
name: source-metadata-header
description: Formato del bloque de metadata (@author, @date, @copyright, @version, @library) y esquema de versionado para todo archivo de código fuente nuevo o modificado, con sintaxis de comentario por lenguaje. Usar al crear o modificar un archivo de código fuente.
---

Todo archivo de código fuente que genere o modifique lleva un bloque de metadata al inicio absoluto del archivo. **Excepciones:** archivos de configuración/lockfiles (`package-lock.json`, `.env*`, etc.), código autogenerado, y código de terceros/vendored.

Campos obligatorios: descripción breve (máx. 2 líneas), `@author`, `@date`, `@copyright`, `@version`, `@library`.

```text
@author: Carlos Briceño <carjavi@hotmail.com>
@date: dd-mm-aaaa
@copyright: Copyright (c) 2026 www.carjavi.com
@version: V1.0
@library:
- pip install pyserial
- npm install mqtt
```

- Versionado incremental: `V1.0` inicial, `V1.1` mejoras menores, `V2.0` cambios importantes. Actualizar `@version` y `@date` cuando el archivo se modifica.
- `@library`: solo dependencias externas realmente usadas, con el comando de instalación real. Si no hay ninguna: `@library: No external dependencies`.

Comentarios por lenguaje: `#` (Python/Shell/YAML) · `//` o `/** */` (JS/TS/C/C++/Java) · `<!-- -->` (HTML/XML) · `--` (SQL/Lua).
