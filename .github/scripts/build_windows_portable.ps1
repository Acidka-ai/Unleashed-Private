Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$buildDir = Join-Path $repoRoot "build-win-gh"
$distDir = Join-Path $buildDir "qFlipper"
$qmake = (Get-Command qmake.exe -ErrorAction Stop).Source
$windeployqt = (Get-Command windeployqt.exe -ErrorAction Stop).Source
$gitVersion = $env:GITHUB_REF_NAME
if ([string]::IsNullOrWhiteSpace($gitVersion)) {
    $gitVersion = (git -C $repoRoot describe --tags --abbrev=0).Trim()
}
$gitVersion = $gitVersion -replace '^v', ''

if (Test-Path $buildDir) {
    Remove-Item -Recurse -Force $buildDir
}

New-Item -ItemType Directory -Path $buildDir | Out-Null
Push-Location $buildDir

& $qmake "$repoRoot\qFlipper.pro" -spec win32-msvc "CONFIG+=release qtquickcompiler" "GIT_VERSION=$gitVersion"
nmake qmake_all
nmake
nmake install

if (!(Test-Path "$distDir\qFlipper.exe")) {
    throw "qFlipper.exe was not produced"
}

& $windeployqt --release --no-compiler-runtime --qmldir "$repoRoot\application" "$distDir\qFlipper.exe"
$cliExe = Join-Path $distDir "qFlipper-cli.exe"
if (Test-Path $cliExe) {
    & $windeployqt --release --no-compiler-runtime $cliExe
}

$qtRoot = Split-Path -Parent (Split-Path -Parent $qmake)
$opensslCandidates = Get-ChildItem -Path $qtRoot -Recurse -File -Include "libssl-*.dll","libcrypto-*.dll","libssl*.dll","libcrypto*.dll" -ErrorAction SilentlyContinue
foreach ($file in $opensslCandidates) {
    Copy-Item $file.FullName -Destination $distDir -Force
}

Copy-Item "$distDir\qFlipper.exe" "$buildDir\qFlipper.exe" -Force

$zipPath = Join-Path $buildDir "qFlipper-windows-portable.zip"
if (Test-Path $zipPath) {
    Remove-Item $zipPath -Force
}
Compress-Archive -Path "$distDir\*" -DestinationPath $zipPath

Pop-Location
