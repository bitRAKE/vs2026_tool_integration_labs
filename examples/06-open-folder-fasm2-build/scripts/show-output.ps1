[CmdletBinding()]
param(
    [string] $OutputPath
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

Import-Module (Join-Path $PSScriptRoot "..\..\..\scripts\common\Vsf.VisualStudioTools.psm1") -Force

$exampleRoot = Split-Path -Parent $PSScriptRoot
if (-not $OutputPath) {
    $OutputPath = Join-Path $exampleRoot "out\hello.com"
}

if (-not (Test-Path -LiteralPath $OutputPath)) {
    throw "Build artifact '$OutputPath' was not found. Run the Build task first."
}

$toolchain = Get-VsfFasmToolchain
$artifact = Get-Item -LiteralPath $OutputPath
$previewBytes = [System.IO.File]::ReadAllBytes($artifact.FullName) |
    Select-Object -First 16 |
    ForEach-Object { $_.ToString("X2") }

$fasm2Path = if ($toolchain.Fasm2Path) { $toolchain.Fasm2Path } else { "<not found>" }
$fasmgPath = if ($toolchain.FasmgPath) { $toolchain.FasmgPath } else { "<not found>" }
$includePath = if ($toolchain.Fasm2IncludePath) { $toolchain.Fasm2IncludePath } else { "<not found>" }

Write-Host ("Artifact      : {0}" -f $artifact.FullName)
Write-Host ("Size          : {0} bytes" -f $artifact.Length)
Write-Host ("Hex preview   : {0}" -f ($previewBytes -join " "))
Write-Host ("fasm2 path    : {0}" -f $fasm2Path)
Write-Host ("fasmg path    : {0}" -f $fasmgPath)
Write-Host ("fasm2 include : {0}" -f $includePath)
