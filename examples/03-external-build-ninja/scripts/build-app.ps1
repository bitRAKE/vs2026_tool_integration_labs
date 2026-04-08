[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string] $Source,

    [Parameter(Mandatory = $true)]
    [string] $Output
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

Import-Module (Join-Path $PSScriptRoot "..\..\..\scripts\common\Vsf.VisualStudioTools.psm1") -Force

$sourcePath = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($Source)
$outputPath = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($Output)
$outputDir = Split-Path -Parent $outputPath
$pdbPath = Join-Path $outputDir "ninja-lab.pdb"
$objPath = Join-Path $outputDir "ninja-lab.obj"

New-Item -ItemType Directory -Path $outputDir -Force | Out-Null

$commandLine = ('cl /nologo /std:c++20 /EHsc /Zi /Fo:"{0}" /Fe:"{1}" /Fd"{2}" "{3}" /link /INCREMENTAL:NO' -f $objPath, $outputPath, $pdbPath, $sourcePath)
Invoke-VsfVsDevCommand -CommandLine $commandLine
