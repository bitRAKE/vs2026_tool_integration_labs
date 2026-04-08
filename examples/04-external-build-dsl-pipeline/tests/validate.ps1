[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$exampleRoot = Split-Path -Parent $PSScriptRoot
$inputPath = Join-Path $exampleRoot "specs\pipeline.vsfdsl"
$outputPath = Join-Path $exampleRoot "generated\pipeline.json"

& (Join-Path $exampleRoot "scripts\compile-vsfdsl.ps1") -InputPath $inputPath -OutputPath $outputPath

if (-not (Test-Path -LiteralPath $outputPath)) {
    throw "Generated JSON file was not created."
}

$document = Get-Content -Raw $outputPath | ConvertFrom-Json
if ($document.pipeline -ne "sample") {
    throw "Unexpected pipeline name '$($document.pipeline)'."
}

if ($document.stages.Count -ne 2) {
    throw "Expected exactly 2 stages."
}

$summary = & (Join-Path $exampleRoot "scripts\show-generated.ps1") -JsonPath $outputPath
if (($summary -join "`n") -notmatch "stageCount=2") {
    throw "Generated summary did not report the expected stage count."
}

& (Join-Path $exampleRoot "scripts\clean.ps1")

Write-Host "DSL compilation and preview flow looks valid."
