#!/usr/bin/env bash
# install.sh (rea) - Instala/actualiza REA (rea-agents) y lo registra como MCP + skill
# en Claude Code y Claude Desktop con 'rea setup'.
# @author: Carlos Briceño <carjavi@hotmail.com>
# @date: 15-10-2026
# @copyright: Copyright (c) 2026 www.carjavi.com
# @version: V1.0
# @library:
# - npm install --global rea-agents
set -euo pipefail

# Agentes donde se registra REA (ids de 'rea setup --client').
clients=(claude_code claude_desktop)

# --- Node.js ---------------------------------------------------------------
if ! command -v node >/dev/null 2>&1 || ! command -v npm >/dev/null 2>&1; then
    echo "Falta Node.js/npm. Instala Node.js LTS (https://nodejs.org o nvm) y vuelve a correr el instalador." >&2
    exit 1
fi
node_version="$(node -p 'process.versions.node')"
IFS=. read -r node_major node_minor _ <<< "$node_version"
if ! { [ "$node_major" -eq 22 ] && [ "$node_minor" -ge 19 ]; } &&
   ! { [ "$node_major" -eq 24 ] && [ "$node_minor" -ge 11 ]; } &&
   ! [ "$node_major" -ge 26 ]; then
    echo "REA necesita Node.js 22.19+, 24.11+ o 26+ (tienes $node_version)." >&2
    exit 1
fi

# --- Paquete ---------------------------------------------------------------
echo "Instalando/actualizando rea-agents..."
if ! npm install --global rea-agents@latest; then
    echo "npm install --global fallo. Si es por permisos (EACCES), configura un prefijo de usuario:" >&2
    echo "  npm config set prefix ~/.npm-global && echo 'export PATH=~/.npm-global/bin:\$PATH' >> ~/.profile" >&2
    exit 1
fi
if ! command -v rea >/dev/null 2>&1; then
    PATH="$(npm prefix --global)/bin:$PATH"
fi
command -v rea >/dev/null 2>&1 || { echo "No se encuentra 'rea' en PATH tras instalarlo." >&2; exit 1; }
echo "REA $(rea --version)"

# --- Claude Desktop abierto (macOS) ----------------------------------------
# Si Claude Desktop esta corriendo puede reescribir su config y borrar el registro.
if [ "$(uname -s)" = "Darwin" ] && pgrep -x Claude >/dev/null 2>&1; then
    echo "AVISO: Claude Desktop esta abierto: se omite su registro. Cierralo (Cmd+Q) y vuelve a correr el instalador." >&2
    clients=(claude_code)
fi

# --- Registro MCP + skill --------------------------------------------------
setup_args=(setup --yes)
for client in "${clients[@]}"; do setup_args+=(--client "$client"); done
echo "rea ${setup_args[*]}"
rea "${setup_args[@]}"

# Diagnostico informativo: no detiene el instalador.
echo "Diagnostico (rea doctor):"
rea doctor --client claude_code --format md || true
