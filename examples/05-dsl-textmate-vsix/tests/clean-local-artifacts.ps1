[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$exampleRoot = Split-Path -Parent $PSScriptRoot
$paths = @(
    (Join-Path $exampleRoot "bin"),
    (Join-Path $exampleRoot "obj")
)

foreach ($path in $paths) {
    if (Test-Path -LiteralPath $path) {
        Remove-Item -LiteralPath $path -Recurse -Force
        Write-Host ("Removed {0}" -f $path)
    }
}

