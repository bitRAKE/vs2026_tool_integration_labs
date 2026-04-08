[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string] $Executable
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$exePath = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($Executable)
if (-not (Test-Path -LiteralPath $exePath)) {
    throw "Smoke test target does not exist: $exePath"
}

$output = & $exePath "smoke"
$text = $output -join "`n"

if ($text -notmatch "ninja-lab" -or $text -notmatch "arg1=smoke") {
    throw "Unexpected smoke test output.`n$text"
}

Write-Host "Smoke test passed."

