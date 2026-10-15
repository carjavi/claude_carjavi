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
