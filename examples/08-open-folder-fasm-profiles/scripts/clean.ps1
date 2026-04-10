[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$exampleRoot = Split-Path -Parent $PSScriptRoot
$outputDirectory = Join-Path $exampleRoot "out"

if (Test-Path -LiteralPath $outputDirectory) {
    Remove-Item -LiteralPath $outputDirectory -Recurse -Force
    Write-Host ("Removed '{0}'." -f $outputDirectory)
}
else {
    Write-Host ("Nothing to clean at '{0}'." -f $outputDirectory)
}
