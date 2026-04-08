[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string] $OutputDir
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$resolvedDir = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($OutputDir)
if (-not (Test-Path -LiteralPath $resolvedDir)) {
    throw "Output directory does not exist: $resolvedDir"
}

Get-ChildItem -LiteralPath $resolvedDir | Select-Object Name, Length, LastWriteTime

