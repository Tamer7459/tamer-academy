# Tamer Academy — APK release script
# Usage: .\build-apk.ps1   (run from the tamer_academy project folder)
# Builds a release APK, bumps the version code, and keeps only ONE apk in
# C:\Users\CAR INFO\Desktop\Tamer academy\TamerAcademy-vN.apk

$ErrorActionPreference = "Stop"
$projectRoot = Split-Path -Parent $MyInvocation.MyCommand.Definition
$apkDir      = "C:\Users\CAR INFO\Desktop\Tamer academy"
$pubspec     = Join-Path $projectRoot "pubspec.yaml"

# --- 1. Bump version code (1.0.0+NN) -------------------------------------
$versionLine = (Select-String -Path $pubspec -Pattern "^version:\s*(.+)$").Line
$oldVersion  = ($versionLine -replace "^version:\s*","").Trim()
if ($oldVersion -notmatch "^\d+\.\d+\.\d+\+(\d+)$") {
    Write-Host "Cannot parse version: $oldVersion" -ForegroundColor Red
    exit 1
}
$buildNumber = [int]$matches[1]
$newVersion  = "1.0.0+$($buildNumber + 1)"
$newBuild    = $buildNumber + 1

$oldEscaped = [regex]::Escape($oldVersion)
(Get-Content $pubspec) -replace "^version:\s*$oldEscaped", "version: $newVersion" |
    Set-Content $pubspec
Write-Host "Bumped version: $oldVersion -> $newVersion" -ForegroundColor Cyan

# --- 2. Build release APK -------------------------------------------------
Set-Location $projectRoot
Write-Host "Building APK..." -ForegroundColor Cyan
flutter build apk --release
if ($LASTEXITCODE -ne 0) { throw "flutter build failed" }

# --- 3. Copy to project root, keep only the latest -----------------------
$src = Join-Path $projectRoot "build\app\outputs\flutter-apk\app-release.apk"
$dst = Join-Path $apkDir "TamerAcademy-v$newBuild.apk"
Copy-Item -LiteralPath $src -Destination $dst -Force

# Remove every other .apk in the project root + build output dir
Get-ChildItem -LiteralPath $apkDir -Filter "*.apk" -Force |
    Where-Object { $_.FullName -ne $dst } | Remove-Item -Force
Get-ChildItem -LiteralPath (Join-Path $projectRoot "build\app\outputs") -Recurse -Filter "*.apk" -Force |
    Remove-Item -Force

Write-Host "Done -> $dst" -ForegroundColor Green
Write-Host "Size: $((Get-Item $dst).Length) bytes"