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
