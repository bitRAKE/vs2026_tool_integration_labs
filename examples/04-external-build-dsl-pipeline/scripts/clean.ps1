[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$exampleRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
$generatedDir = Join-Path $exampleRoot "generated"

if (Test-Path -LiteralPath $generatedDir) {
    Remove-Item -LiteralPath $generatedDir -Recurse -Force
}

Write-Host "Removed $generatedDir"

