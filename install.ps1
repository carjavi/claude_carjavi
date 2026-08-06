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
