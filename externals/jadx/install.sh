#!/usr/bin/env bash
# install.sh (jadx) - Descarga jadx-headless-mcp (el motor JADX que usa REA para
# decompilar APKs) en ~/.local/opt/jadx, verifica su SHA-256 y deja REA_JADX_MCP_JAR
# en ~/.config/claude_carjavi/jadx.sh.
# @author: Carlos Briceño <carjavi@hotmail.com>
# @date: 15-10-2026
# @copyright: Copyright (c) 2026 www.carjavi.com
# @version: V1.0
# @library:
# - jadx-headless-mcp (descargado de github.com/1013503897/jadx-headless-mcp)
# - curl y sha256sum (o shasum) del sistema
set -euo pipefail

version="${1:-0.7.1}"   # Version exacta de jadx-headless-mcp que exige REA.
# SHA-256 fijado por REA para esa version (src/android/JadxRelease.ts).
sha256="${2:-6e5eacf500b64292bfb73c49797c1958f6ee44646e43e868039ae7feb573ff75}"
min_java_major=17       # Version mayor minima del JDK que pide REA para el puente de JADX.

jadx_root="$HOME/.local/opt/jadx"
jar_name="jadx-headless-mcp-${version}-all.jar"
jar_path="$jadx_root/$jar_name"
jar_url="https://github.com/1013503897/jadx-headless-mcp/releases/download/v${version}/${jar_name}"
env_dir="$HOME/.config/claude_carjavi"
# Archivo propio (no env.sh) porque el instalador de ghidra reescribe env.sh completo.
env_file="$env_dir/jadx.sh"

mkdir -p "$jadx_root" "$env_dir"

# Indica si el archivo existe y su SHA-256 coincide con el esperado.
# Uso: sha256_ok /ruta/al/archivo
sha256_ok() {
    [ -f "$1" ] || return 1
    local actual
    if command -v sha256sum >/dev/null 2>&1; then
        actual="$(sha256sum "$1" | cut -d' ' -f1)"
    else
        actual="$(shasum -a 256 "$1" | cut -d' ' -f1)"
    fi
    [ "$actual" = "$sha256" ]
}

# --- JAR -------------------------------------------------------------------
if sha256_ok "$jar_path"; then
    echo "jadx-headless-mcp $version ya instalado en $jar_path"
else
    echo "Descargando $jar_name..."
    curl -L --fail --retry 3 --connect-timeout 30 --progress-bar -o "$jar_path.part" "$jar_url"
    if ! sha256_ok "$jar_path.part"; then
        rm -f "$jar_path.part"
        echo "El SHA-256 de $jar_name no coincide con el fijado por REA; no se instala" >&2
        exit 1
    fi
    mv -f "$jar_path.part" "$jar_path"
    echo "jadx-headless-mcp $version instalado en $jar_path"
fi

# --- Variable de entorno ---------------------------------------------------
cat > "$env_file" <<EOF
# Generado por claude_carjavi/externals/jadx/install.sh
export REA_JADX_MCP_JAR="$jar_path"
EOF

for rc in "$HOME/.profile" "$HOME/.bashrc" "$HOME/.zshrc"; do
    if [ -f "$rc" ] || [ "$rc" = "$HOME/.profile" ]; then
        grep -qF "$env_file" "$rc" 2>/dev/null || \
            printf '\n[ -f "%s" ] && . "%s"\n' "$env_file" "$env_file" >> "$rc"
    fi
done
export REA_JADX_MCP_JAR="$jar_path"
echo "REA_JADX_MCP_JAR guardada en $env_file (cargada desde ~/.profile y ~/.bashrc)"

# --- JDK (solo aviso) ------------------------------------------------------
# El JDK lo instala el item 'ghidra' (en Linux); aqui solo se avisa si no hay uno valido.
[ -f "$HOME/.config/claude_carjavi/env.sh" ] && . "$HOME/.config/claude_carjavi/env.sh"
java_major=0
if [ -n "${JAVA_HOME:-}" ] && [ -f "$JAVA_HOME/release" ] && [ -x "$JAVA_HOME/bin/javac" ]; then
    java_major="$(sed -n 's/^JAVA_VERSION="\([0-9]*\).*/\1/p' "$JAVA_HOME/release" | head -n1)"
    java_major="${java_major:-0}"
fi
if [ "$java_major" -lt "$min_java_major" ]; then
    echo "AVISO: REA necesita un JDK $min_java_major+ completo para analizar APKs y JAVA_HOME no apunta a uno." \
         "En Linux lo instala el item 'ghidra'; en macOS instala uno (p. ej. brew install --cask temurin@21)." >&2
fi
