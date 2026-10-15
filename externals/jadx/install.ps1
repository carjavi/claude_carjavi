# install.ps1 (jadx) - Descarga jadx-headless-mcp (el motor JADX que usa REA para
# decompilar APKs) en %LOCALAPPDATA%\Programs\jadx, verifica su SHA-256 y define
# REA_JADX_MCP_JAR para el usuario.
# @author: Carlos Briceño <carjavi@hotmail.com>
# @date: 15-10-2026
# @copyright: Copyright (c) 2026 www.carjavi.com
# @version: V1.0
# @library:
# - jadx-headless-mcp (descargado de github.com/1013503897/jadx-headless-mcp)
# - curl.exe (incluido en Windows 10/11)

param(
    # Version exacta de jadx-headless-mcp que exige REA (docs/android-analysis.md).
    [string]$Version = "0.7.1",
    # SHA-256 fijado por REA para esa version (src/android/JadxRelease.ts).
    [string]$Sha256 = "6e5eacf500b64292bfb73c49797c1958f6ee44646e43e868039ae7feb573ff75",
    # Version mayor minima del JDK que pide REA para el puente de JADX.
    [int]$MinJavaMajor = 17
)

$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue"

$jadxRoot = Join-Path $env:LOCALAPPDATA "Programs\jadx"
$jarName = "jadx-headless-mcp-$Version-all.jar"
$jarPath = Join-Path $jadxRoot $jarName
$jarUrl = "https://github.com/1013503897/jadx-headless-mcp/releases/download/v$Version/$jarName"

<#
.SYNOPSIS
Indica si el archivo existe y su SHA-256 coincide con el esperado.
.PARAMETER Path
Ruta del archivo a verificar.
.EXAMPLE
Test-Sha256 "C:\temp\a.jar"
#>
function Test-Sha256([string]$Path) {
    if (-not (Test-Path $Path)) { return $false }
    return (Get-FileHash -Algorithm SHA256 $Path).Hash.ToLowerInvariant() -eq $Sha256
}

New-Item -ItemType Directory -Force -Path $jadxRoot | Out-Null

# --- JAR -------------------------------------------------------------------
if (Test-Sha256 $jarPath) {
    Write-Output "jadx-headless-mcp $Version ya instalado en $jarPath"
} else {
    Write-Output "Descargando $jarName..."
    $tmpJar = "$jarPath.part"
    & curl.exe -L --fail --retry 3 --connect-timeout 30 -o $tmpJar $jarUrl
    if ($LASTEXITCODE -ne 0) { throw "No se pudo descargar $jarUrl (curl codigo $LASTEXITCODE)" }
    if (-not (Test-Sha256 $tmpJar)) {
        Remove-Item $tmpJar -Force
        throw "El SHA-256 de $jarName no coincide con el fijado por REA; no se instala"
    }
    Move-Item $tmpJar $jarPath -Force
    Write-Output "jadx-headless-mcp $Version instalado en $jarPath"
}

# --- Variable de entorno ---------------------------------------------------
[Environment]::SetEnvironmentVariable("REA_JADX_MCP_JAR", $jarPath, "User")
$env:REA_JADX_MCP_JAR = $jarPath
Write-Output "REA_JADX_MCP_JAR = $jarPath (variable de usuario)"

# --- JDK (solo aviso) ------------------------------------------------------
# El JDK lo instala el item 'ghidra'; aqui solo se avisa si no hay uno valido.
$javaHome = $env:JAVA_HOME
if (-not $javaHome) { $javaHome = [Environment]::GetEnvironmentVariable("JAVA_HOME", "User") }
if (-not $javaHome) { $javaHome = [Environment]::GetEnvironmentVariable("JAVA_HOME", "Machine") }
$javaMajor = 0
if ($javaHome -and (Test-Path (Join-Path $javaHome "release")) -and (Test-Path (Join-Path $javaHome "bin\javac.exe"))) {
    $line = Select-String -Path (Join-Path $javaHome "release") -Pattern '^JAVA_VERSION="(\d+)' | Select-Object -First 1
    if ($line) { $javaMajor = [int]$line.Matches[0].Groups[1].Value }
}
if ($javaMajor -lt $MinJavaMajor) {
    Write-Warning ("REA necesita un JDK $MinJavaMajor+ completo para analizar APKs y JAVA_HOME no apunta a uno. " +
        "Activa el item 'ghidra' (instala JDK 21) o define JAVA_HOME a mano.")
}
