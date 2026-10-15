<#
.SYNOPSIS
  Zips the Windows release build (flutter build windows --release) into
  <OutDir>\developer-toolbox-<version>-windows-<arch>.zip.

.DESCRIPTION
  The architecture comes from the machine this runs on (x64 or arm64), because
  Flutter builds for the host; pass -Arch to override it. The version comes from
  pubspec.yaml. The zip holds the contents of the Release folder at its top
  level (developer_toolbox.exe next to flutter_windows.dll).
#>
param(
    [string]$OutDir = 'out',
    [ValidateSet('x64', 'arm64')]
    [string]$Arch
)
$ErrorActionPreference = 'Stop'
Set-Location (Join-Path $PSScriptRoot '..')

if (-not $Arch) {
    switch ($env:PROCESSOR_ARCHITECTURE) {
        'AMD64' { $Arch = 'x64' }
        'ARM64' { $Arch = 'arm64' }
        default { throw "unsupported PROCESSOR_ARCHITECTURE '$env:PROCESSOR_ARCHITECTURE' (AMD64 or ARM64)" }
    }
}

$release = "build\windows\$Arch\runner\Release"
if (-not (Test-Path "$release\developer_toolbox.exe")) {
    throw "$release\developer_toolbox.exe not found; run 'flutter build windows --release' first"
}

$versionLine = Select-String -Path pubspec.yaml -Pattern '^version:\s*(\S+)' | Select-Object -First 1
$version = ($versionLine.Matches[0].Groups[1].Value -split '\+')[0]

New-Item -ItemType Directory -Force -Path $OutDir | Out-Null
$out = (Resolve-Path $OutDir).Path
$zip = Join-Path $out "developer-toolbox-$version-windows-$Arch.zip"
if (Test-Path $zip) { Remove-Item $zip }
Compress-Archive -Path "$release\*" -DestinationPath $zip
Write-Host "Built: $zip"
