[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string] $Path
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$resolvedPath = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($Path)
$directory = Split-Path -Parent $resolvedPath

New-Item -ItemType Directory -Path $directory -Force | Out-Null
Set-Content -LiteralPath $resolvedPath -Value (Get-Date).ToString("s") -NoNewline

