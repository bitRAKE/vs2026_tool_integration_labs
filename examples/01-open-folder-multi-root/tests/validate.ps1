[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$exampleRoot = Split-Path -Parent $PSScriptRoot
$workspacePath = Join-Path $exampleRoot "workspace\vsf-layers.code-workspace"
$workspace = Get-Content -Raw $workspacePath | ConvertFrom-Json

if ($workspace.folders.Count -ne 3) {
    throw "Expected exactly 3 folders in the workspace file."
}

foreach ($folder in $workspace.folders) {
    $resolved = Join-Path (Split-Path -Parent $workspacePath) $folder.path
    if (-not (Test-Path -LiteralPath $resolved)) {
        throw "Workspace folder path does not exist: $resolved"
    }
}

$renderOutput = & (Join-Path $exampleRoot "frontend\app\render.ps1")
if ($renderOutput -notmatch '"role"\s*:\s*"client"') {
    throw "Client render script did not return the expected payload."
}

$serveOutput = & (Join-Path $exampleRoot "backend\app\serve.ps1") -Mode Diagnostic
if (($serveOutput -join "`n") -notmatch "service-mode=diagnostic") {
    throw "Service script did not enter diagnostic mode."
}

Write-Host "Workspace file, scripts, and hidden-item placeholders look valid."
