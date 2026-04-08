[CmdletBinding()]
param(
    [string] $SourcePath,
    [string] $OutputPath
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

Import-Module (Join-Path $PSScriptRoot "..\..\..\scripts\common\Vsf.VisualStudioTools.psm1") -Force

$exampleRoot = Split-Path -Parent $PSScriptRoot
if (-not $SourcePath) {
    $SourcePath = Join-Path $exampleRoot "src\hello.fasm"
}

if (-not $OutputPath) {
    $OutputPath = Join-Path $exampleRoot "out\hello.com"
}

$outputDirectory = Split-Path -Path $OutputPath -Parent
if (-not (Test-Path -LiteralPath $outputDirectory)) {
    New-Item -ItemType Directory -Path $outputDirectory -Force | Out-Null
}

$toolchain = Invoke-VsfFasmSource -SourcePath $SourcePath -OutputPath $OutputPath
$artifact = Get-Item -LiteralPath $OutputPath
$fasm2Path = if ($toolchain.Fasm2Path) { $toolchain.Fasm2Path } else { "<not found>" }
$fasmgPath = if ($toolchain.FasmgPath) { $toolchain.FasmgPath } else { "<not found>" }

Write-Host ("Built artifact: {0}" -f $artifact.FullName)
Write-Host ("Artifact size : {0} bytes" -f $artifact.Length)
Write-Host ("fasm2 path    : {0}" -f $fasm2Path)
Write-Host ("fasmg path    : {0}" -f $fasmgPath)
