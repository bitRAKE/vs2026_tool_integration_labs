[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string] $JsonPath
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$resolvedPath = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($JsonPath)
if (-not (Test-Path -LiteralPath $resolvedPath)) {
    throw "Generated JSON not found: $resolvedPath"
}

$document = Get-Content -Raw $resolvedPath | ConvertFrom-Json
Write-Output ("pipeline={0}" -f $document.pipeline)
Write-Output ("environment={0}" -f $document.environment)
Write-Output ("stageCount={0}" -f $document.stages.Count)

