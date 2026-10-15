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
