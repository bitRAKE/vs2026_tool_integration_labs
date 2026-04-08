[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

Import-Module (Join-Path $PSScriptRoot "..\..\..\scripts\common\Vsf.VisualStudioTools.psm1") -Force

$exampleRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
$sourcePath = Join-Path $exampleRoot "src\main.cpp"
$outDir = if ($env:VSF_OUT_DIR) { $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($env:VSF_OUT_DIR) } else { Join-Path $exampleRoot "out\manual" }

New-Item -ItemType Directory -Path $outDir -Force | Out-Null

$outputPath = Join-Path $outDir "vsf-environments.exe"
$pdbPath = Join-Path $outDir "vsf-environments.pdb"
$objPath = Join-Path $outDir "vsf-environments.obj"
$commandLine = ('cl /nologo /std:c++20 /EHsc /Zi /Fo:"{0}" /Fe:"{1}" /Fd"{2}" "{3}" /link /INCREMENTAL:NO' -f $objPath, $outputPath, $pdbPath, $sourcePath)

Invoke-VsfVsDevCommand -CommandLine $commandLine
Write-Host "Built $outputPath"
