# install.ps1 (rea) - Instala/actualiza REA (rea-agents) y lo registra como MCP + skill
# en Claude Code y Claude Desktop con 'rea setup'.
# @author: Carlos Briceño <carjavi@hotmail.com>
# @date: 15-10-2026
# @copyright: Copyright (c) 2026 www.carjavi.com
# @version: V1.0
# @library:
# - npm install --global rea-agents

param(
    # Agentes donde se registra REA (ids de 'rea setup --client').
    [string[]]$Clients = @("claude_code", "claude_desktop")
)

$ErrorActionPreference = "Stop"

# --- Node.js ---------------------------------------------------------------
if (-not (Get-Command node -ErrorAction SilentlyContinue) -or -not (Get-Command npm -ErrorAction SilentlyContinue)) {
    throw "Falta Node.js/npm. Instala Node.js LTS (winget install OpenJS.NodeJS.LTS) y vuelve a correr el instalador."
}
$nodeVersion = [version](& node -p "process.versions.node")
$nodeOk = ($nodeVersion.Major -eq 22 -and $nodeVersion.Minor -ge 19) -or
          ($nodeVersion.Major -eq 24 -and $nodeVersion.Minor -ge 11) -or
          ($nodeVersion.Major -ge 26)
if (-not $nodeOk) {
    throw "REA necesita Node.js 22.19+, 24.11+ o 26+ (tienes $nodeVersion). Actualiza con: winget upgrade OpenJS.NodeJS.LTS"
}

# --- Paquete ---------------------------------------------------------------
Write-Output "Instalando/actualizando rea-agents..."
& npm install --global rea-agents@latest
if ($LASTEXITCODE -ne 0) { throw "npm install --global rea-agents fallo" }

$rea = Get-Command rea -ErrorAction SilentlyContinue
if (-not $rea) {
    $npmPrefix = (& npm prefix --global).Trim()
    # En Windows los comandos globales quedan en el prefijo; en Linux/macOS, en prefijo/bin.
    $env:PATH = $npmPrefix + [IO.Path]::PathSeparator + (Join-Path $npmPrefix "bin") + [IO.Path]::PathSeparator + $env:PATH
    $rea = Get-Command rea -ErrorAction SilentlyContinue
    if (-not $rea) { throw "No se encuentra el comando 'rea' despues de instalarlo (revisa que $npmPrefix este en PATH)" }
}
Write-Output ("REA " + (& rea --version))

# --- Claude Desktop abierto ------------------------------------------------
# Si Claude Desktop esta corriendo puede reescribir su config y borrar el registro.
# Se distingue de Claude Code (tambien claude.exe) por la ruta del ejecutable.
$desktopRunning = Get-Process -Name "claude" -ErrorAction SilentlyContinue |
    Where-Object { $_.Path -and $_.Path -match '\\AnthropicClaude\\|\\WindowsApps\\Claude_' }
if ($desktopRunning -and $Clients -contains "claude_desktop") {
    Write-Warning ("Claude Desktop esta abierto: se omite su registro. Cierralo por completo " +
        "(icono de la bandeja > Quit) y vuelve a correr el instalador.")
    $Clients = $Clients | Where-Object { $_ -ne "claude_desktop" }
}

# --- Registro MCP + skill --------------------------------------------------
$setupArgs = @("setup", "--yes")
foreach ($client in $Clients) { $setupArgs += @("--client", $client) }
Write-Output ("rea " + ($setupArgs -join " "))
& rea @setupArgs
if ($LASTEXITCODE -ne 0) { throw "rea setup fallo (codigo $LASTEXITCODE)" }

# Diagnostico informativo: no detiene el instalador.
Write-Output "Diagnostico (rea doctor):"
& rea doctor --client claude_code --format md
$global:LASTEXITCODE = 0
