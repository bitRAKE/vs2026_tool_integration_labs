[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$exampleRoot = Split-Path -Parent $PSScriptRoot
foreach ($relativePath in @("bin", "obj")) {
    $targetPath = Join-Path $exampleRoot $relativePath
    if (Test-Path -LiteralPath $targetPath) {
        Remove-Item -LiteralPath $targetPath -Recurse -Force
        Write-Host ("Removed '{0}'." -f $targetPath)
    }
}
