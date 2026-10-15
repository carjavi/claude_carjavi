#!/usr/bin/env bash
# install.sh (ghidra) - Instala Ghidra y un JDK 21 en ~/.local/opt sin sudo, y deja
# GHIDRA_INSTALL_DIR / JAVA_HOME en ~/.config/claude_carjavi/env.sh.
# @author: Carlos Briceño <carjavi@hotmail.com>
# @date: 15-10-2026
# @copyright: Copyright (c) 2026 www.carjavi.com
# @version: V1.0
# @library:
# - Ghidra (descargado de github.com/NationalSecurityAgency/ghidra)
# - Eclipse Temurin JDK 21 (descargado de api.adoptium.net)
# - curl, tar y unzip (o python3) del sistema
set -euo pipefail

version="${1:-12.1.4}"   # Version exacta de Ghidra que exige REA.
java_major="${2:-21}"    # Version mayor del JDK que exige esa version de Ghidra.

if [ "$(uname -s)" = "Darwin" ]; then
    echo "macOS: REA no admite Ghidra en macOS (usa Hopper, que 'rea setup' ofrece instalar). Se omite."
    exit 0
fi

case "$(uname -m)" in
    x86_64|amd64) jdk_arch="x64" ;;
    aarch64|arm64) jdk_arch="aarch64" ;;
    *) echo "Arquitectura no soportada: $(uname -m)" >&2; exit 1 ;;
esac

opt_dir="$HOME/.local/opt"
ghidra_root="$opt_dir/ghidra"
jdk_root="$opt_dir/jdk"
env_dir="$HOME/.config/claude_carjavi"
env_file="$env_dir/env.sh"
tmp_dir="$(mktemp -d)"
trap 'rm -rf "$tmp_dir"' EXIT

mkdir -p "$ghidra_root" "$jdk_root" "$env_dir"

# Devuelve la version mayor de un JDK completo (con javac), o 0 si no es valido.
# Uso: jdk_major /ruta/al/jdk
jdk_major() {
    local home="${1:-}"
    if [ -z "$home" ] || [ ! -f "$home/release" ] || [ ! -x "$home/bin/javac" ]; then
        echo 0; return
    fi
    sed -n 's/^JAVA_VERSION="\([0-9]*\).*/\1/p' "$home/release" | head -n1 | grep . || echo 0
}

# Descarga una URL a un archivo (sigue redirecciones y falla con HTTP >= 400).
download() {
    curl -L --fail --retry 3 --connect-timeout 30 --progress-bar -o "$2" "$1"
}

# --- JDK -------------------------------------------------------------------
jdk_home=""
for candidate in "${JAVA_HOME:-}" "$jdk_root"/* /usr/lib/jvm/*"$java_major"*; do
    if [ "$(jdk_major "$candidate")" = "$java_major" ]; then
        jdk_home="$candidate"; break
    fi
done

if [ -n "$jdk_home" ]; then
    echo "JDK $java_major encontrado: $jdk_home"
else
    echo "Descargando JDK $java_major (Eclipse Temurin)..."
    if ! download "https://api.adoptium.net/v3/binary/latest/$java_major/ga/linux/$jdk_arch/jdk/hotspot/normal/eclipse" "$tmp_dir/jdk.tar.gz"; then
        # Respaldo: el mismo JDK publicado en los releases de GitHub de Adoptium.
        echo "api.adoptium.net no respondio; usando los releases de GitHub de Temurin..."
        jdk_url="$(curl -fsSL --retry 3 "https://api.github.com/repos/adoptium/temurin${java_major}-binaries/releases/latest" \
            | grep -o "https://[^\"]*OpenJDK${java_major}U-jdk_${jdk_arch}_linux_hotspot_[^\"]*\.tar\.gz" | head -n1)"
        [ -n "$jdk_url" ] || { echo "No se encontro un JDK $java_major para linux/$jdk_arch" >&2; exit 1; }
        download "$jdk_url" "$tmp_dir/jdk.tar.gz"
    fi
    tar -xzf "$tmp_dir/jdk.tar.gz" -C "$jdk_root"
    for candidate in "$jdk_root"/*; do
        if [ "$(jdk_major "$candidate")" = "$java_major" ]; then jdk_home="$candidate"; fi
    done
    [ -n "$jdk_home" ] || { echo "El JDK descargado no es un JDK $java_major valido" >&2; exit 1; }
    echo "JDK $java_major instalado en $jdk_home"
fi

# --- Ghidra ----------------------------------------------------------------
ghidra_dir="$ghidra_root/ghidra_${version}_PUBLIC"
if grep -qx "application.version=$version" "$ghidra_dir/Ghidra/application.properties" 2>/dev/null; then
    echo "Ghidra $version ya instalado en $ghidra_dir"
else
    echo "Buscando Ghidra $version en GitHub..."
    url="$(curl -fsSL --retry 3 "https://api.github.com/repos/NationalSecurityAgency/ghidra/releases/tags/Ghidra_${version}_build" \
        | grep -o "https://[^\"]*ghidra_${version}_PUBLIC_[0-9]*\.zip" | head -n1)"
    [ -n "$url" ] || { echo "No se encontro el zip de Ghidra $version en el release" >&2; exit 1; }
    echo "Descargando $(basename "$url") (~550 MB)..."
    download "$url" "$tmp_dir/ghidra.zip"
    if command -v unzip >/dev/null 2>&1; then
        unzip -q -o "$tmp_dir/ghidra.zip" -d "$ghidra_root"
    else
        python3 -m zipfile -e "$tmp_dir/ghidra.zip" "$ghidra_root"
    fi
    chmod +x "$ghidra_dir/support/analyzeHeadless" "$ghidra_dir/ghidraRun" 2>/dev/null || true
    [ -f "$ghidra_dir/support/analyzeHeadless" ] || { echo "Ghidra no quedo en $ghidra_dir" >&2; exit 1; }
    echo "Ghidra $version instalado en $ghidra_dir"
fi

# --- Variables de entorno --------------------------------------------------
# JAVA_HOME solo se define si no existe o no es un JDK valido, para no pisar el Java de otras herramientas.
cat > "$env_file" <<EOF
# Generado por claude_carjavi/externals/ghidra/install.sh
export GHIDRA_INSTALL_DIR="$ghidra_dir"
if [ -z "\${JAVA_HOME:-}" ] || [ ! -x "\$JAVA_HOME/bin/javac" ]; then
    export JAVA_HOME="$jdk_home"
fi
EOF

for rc in "$HOME/.profile" "$HOME/.bashrc" "$HOME/.zshrc"; do
    if [ -f "$rc" ] || [ "$rc" = "$HOME/.profile" ]; then
        grep -qF "$env_file" "$rc" 2>/dev/null || \
            printf '\n[ -f "%s" ] && . "%s"\n' "$env_file" "$env_file" >> "$rc"
    fi
done
echo "Variables guardadas en $env_file (cargadas desde ~/.profile y ~/.bashrc)"

if [ -n "${JAVA_HOME:-}" ] && [ -x "$JAVA_HOME/bin/javac" ] && [ "$(jdk_major "$JAVA_HOME")" != "$java_major" ]; then
    echo "AVISO: JAVA_HOME ya apunta a otro Java ($JAVA_HOME). REA necesita JDK $java_major:" \
         "si 'rea doctor' falla en Java, usa JAVA_HOME=$jdk_home" >&2
fi
