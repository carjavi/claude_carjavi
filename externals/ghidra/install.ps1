# install.ps1 (ghidra) - Instala Ghidra y un JDK 21 en %LOCALAPPDATA%\Programs sin
# permisos de administrador, y define GHIDRA_INSTALL_DIR / JAVA_HOME para el usuario.
# @author: Carlos Briceño <carjavi@hotmail.com>
# @date: 15-10-2026
# @copyright: Copyright (c) 2026 www.carjavi.com
# @version: V1.0
# @library:
# - Ghidra (descargado de github.com/NationalSecurityAgency/ghidra)
# - Eclipse Temurin JDK 21 (descargado de api.adoptium.net)
# - curl.exe y tar.exe (incluidos en Windows 10/11)

param(
    # Version exacta de Ghidra que exige REA.
    [string]$Version = "12.1.4",
    # Version mayor del JDK que exige esa version de Ghidra.
    [int]$JavaMajor = 21
)

$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue"

$programsDir = Join-Path $env:LOCALAPPDATA "Programs"
$ghidraRoot = Join-Path $programsDir "ghidra"
$jdkRoot = Join-Path $programsDir "jdk"
$tempDir = Join-Path $env:TEMP "claude_carjavi"

<#
.SYNOPSIS
Devuelve la version mayor de un JDK completo (con javac.exe), o 0 si no es valido.
.PARAMETER JdkHome
Carpeta raiz del JDK (la que contiene bin\ y el archivo release).
.EXAMPLE
Get-JdkMajor "C:\Program Files\Eclipse Adoptium\jdk-21.0.8.9-hotspot"
#>
function Get-JdkMajor([string]$JdkHome) {
    if (-not $JdkHome) { return 0 }
    $release = Join-Path $JdkHome "release"
    $javac = Join-Path $JdkHome "bin\javac.exe"
    if (-not (Test-Path $release) -or -not (Test-Path $javac)) { return 0 }
    $line = Select-String -Path $release -Pattern '^JAVA_VERSION="(\d+)' | Select-Object -First 1
    if (-not $line) { return 0 }
    return [int]$line.Matches[0].Groups[1].Value
}

<#
.SYNOPSIS
Descarga una URL a un archivo con curl.exe (sigue redirecciones y falla con HTTP >= 400).
#>
function Save-Url([string]$Url, [string]$OutFile) {
    & curl.exe -L --fail --retry 3 --connect-timeout 30 -o $OutFile $Url
    if ($LASTEXITCODE -ne 0) { throw "No se pudo descargar $Url (curl codigo $LASTEXITCODE)" }
}

New-Item -ItemType Directory -Force -Path $ghidraRoot, $jdkRoot, $tempDir | Out-Null

# --- JDK -------------------------------------------------------------------
$candidates = @($env:JAVA_HOME, [Environment]::GetEnvironmentVariable("JAVA_HOME", "User"))
$candidates += Get-ChildItem -Directory -Path $jdkRoot -ErrorAction SilentlyContinue | ForEach-Object { $_.FullName }
foreach ($vendorDir in @("C:\Program Files\Eclipse Adoptium", "C:\Program Files\Java", "C:\Program Files\Microsoft")) {
    $candidates += Get-ChildItem -Directory -Path $vendorDir -Filter "jdk-$JavaMajor*" -ErrorAction SilentlyContinue | ForEach-Object { $_.FullName }
}
$jdkHome = $candidates | Where-Object { (Get-JdkMajor $_) -eq $JavaMajor } | Select-Object -First 1

if ($jdkHome) {
    Write-Output "JDK $JavaMajor encontrado: $jdkHome"
} else {
    Write-Output "Descargando JDK $JavaMajor (Eclipse Temurin)..."
    $jdkZip = Join-Path $tempDir "jdk$JavaMajor.zip"
    try {
        Save-Url "https://api.adoptium.net/v3/binary/latest/$JavaMajor/ga/windows/x64/jdk/hotspot/normal/eclipse" $jdkZip
    } catch {
        # Respaldo: el mismo JDK publicado en los releases de GitHub de Adoptium.
        Write-Output "api.adoptium.net no respondio; usando los releases de GitHub de Temurin..."
        $jdkRelease = Invoke-RestMethod -Uri "https://api.github.com/repos/adoptium/temurin$JavaMajor-binaries/releases/latest" `
            -Headers @{ "User-Agent" = "claude_carjavi-installer" } -TimeoutSec 60
        $jdkAsset = $jdkRelease.assets | Where-Object { $_.name -like "OpenJDK${JavaMajor}U-jdk_x64_windows_hotspot_*.zip" } | Select-Object -First 1
        if (-not $jdkAsset) { throw "No se encontro un JDK $JavaMajor para Windows x64" }
        Save-Url $jdkAsset.browser_download_url $jdkZip
    }
    & tar.exe -xf $jdkZip -C $jdkRoot
    if ($LASTEXITCODE -ne 0) { throw "No se pudo descomprimir $jdkZip" }
    Remove-Item $jdkZip -Force
    $jdkHome = Get-ChildItem -Directory -Path $jdkRoot | Where-Object { (Get-JdkMajor $_.FullName) -eq $JavaMajor } |
        Sort-Object Name -Descending | Select-Object -First 1 -ExpandProperty FullName
    if (-not $jdkHome) { throw "El JDK descargado no contiene un JDK $JavaMajor valido en $jdkRoot" }
    Write-Output "JDK $JavaMajor instalado en $jdkHome"
}

# --- Ghidra ----------------------------------------------------------------
$ghidraDir = Join-Path $ghidraRoot "ghidra_${Version}_PUBLIC"
$properties = Join-Path $ghidraDir "Ghidra\application.properties"
$installed = (Test-Path $properties) -and (Select-String -Path $properties -Pattern "^application.version=$([regex]::Escape($Version))$" -Quiet)

if ($installed) {
    Write-Output "Ghidra $Version ya instalado en $ghidraDir"
} else {
    Write-Output "Buscando Ghidra $Version en GitHub..."
    $release = Invoke-RestMethod -Uri "https://api.github.com/repos/NationalSecurityAgency/ghidra/releases/tags/Ghidra_${Version}_build" `
        -Headers @{ "User-Agent" = "claude_carjavi-installer" } -TimeoutSec 60
    $asset = $release.assets | Where-Object { $_.name -like "ghidra_${Version}_PUBLIC_*.zip" } | Select-Object -First 1
    if (-not $asset) { throw "No se encontro el zip de Ghidra $Version en el release" }
    $ghidraZip = Join-Path $tempDir $asset.name
    Write-Output ("Descargando {0} ({1:N0} MB)..." -f $asset.name, ($asset.size / 1MB))
    Save-Url $asset.browser_download_url $ghidraZip
    & tar.exe -xf $ghidraZip -C $ghidraRoot
    if ($LASTEXITCODE -ne 0) { throw "No se pudo descomprimir $ghidraZip" }
    Remove-Item $ghidraZip -Force
    if (-not (Test-Path (Join-Path $ghidraDir "support\analyzeHeadless.bat"))) {
        throw "Ghidra no quedo en la ruta esperada: $ghidraDir"
    }
    Write-Output "Ghidra $Version instalado en $ghidraDir"
}

# --- Variables de entorno --------------------------------------------------
[Environment]::SetEnvironmentVariable("GHIDRA_INSTALL_DIR", $ghidraDir, "User")
$env:GHIDRA_INSTALL_DIR = $ghidraDir
Write-Output "GHIDRA_INSTALL_DIR = $ghidraDir (variable de usuario)"

$userJavaHome = [Environment]::GetEnvironmentVariable("JAVA_HOME", "User")
$machineJavaHome = [Environment]::GetEnvironmentVariable("JAVA_HOME", "Machine")
$currentJavaHome = if ($userJavaHome) { $userJavaHome } else { $machineJavaHome }

if (-not $currentJavaHome -or -not (Test-Path (Join-Path $currentJavaHome "bin\javac.exe"))) {
    [Environment]::SetEnvironmentVariable("JAVA_HOME", $jdkHome, "User")
    Write-Output "JAVA_HOME = $jdkHome (variable de usuario)"
} elseif ((Get-JdkMajor $currentJavaHome) -ne $JavaMajor) {
    # No se pisa un JAVA_HOME que otras herramientas pueden estar usando.
    Write-Warning (("JAVA_HOME ya apunta a otro Java ({0}). REA necesita JDK {1}: si 'rea doctor' falla en Java, " +
        "cambia JAVA_HOME a {2}") -f $currentJavaHome, $JavaMajor, $jdkHome)
} else {
    Write-Output "JAVA_HOME ya apunta a un JDK $JavaMajor : $currentJavaHome"
}
# En esta sesion siempre se usa el JDK correcto para que el paso de REA lo detecte.
$env:JAVA_HOME = $jdkHome
