[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$exampleRoot = Split-Path -Parent $PSScriptRoot
$tasksPath = Join-Path $exampleRoot "tasks.vs.json"
$validateScript = Join-Path $exampleRoot "scripts\validate-profile-file.ps1"
$invokeScript = Join-Path $exampleRoot "scripts\invoke-profile.ps1"
$cleanScript = Join-Path $exampleRoot "scripts\clean.ps1"
$helloArtifact = Join-Path $exampleRoot "out\profiles\hello.com"
$restartoutArtifact = Join-Path $exampleRoot "out\profiles\restartout.com"

$tasks = Get-Content -Raw $tasksPath | ConvertFrom-Json
if ($tasks.tasks.Count -lt 8) {
    throw "tasks.vs.json does not contain the expected schema-backed profile tasks."
}

& $validateScript

& $invokeScript -ProfileSlot build
if (-not (Test-Path -LiteralPath $helloArtifact)) {
    throw "Expected active build artifact '$helloArtifact' was not produced."
}

& $invokeScript -ProfileSlot inspect
& $invokeScript -ProfileSlot syntax
& $invokeScript -ProfileName include-syntax
& $invokeScript -ProfileName restartout-com

if (-not (Test-Path -LiteralPath $restartoutArtifact)) {
    throw "Expected named build artifact '$restartoutArtifact' was not produced."
}

try {
    & $invokeScript -ProfileName broken-syntax
    throw "Broken syntax profile unexpectedly passed."
}
catch {
    if ($_.Exception.Message -eq "Broken syntax profile unexpectedly passed.") {
        throw
    }

    Write-Host "Observed expected syntax failure for the broken-syntax profile."
}

& $cleanScript
Write-Host ("Example 08 validation succeeded: {0}" -f $helloArtifact)
