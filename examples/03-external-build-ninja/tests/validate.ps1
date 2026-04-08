[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$exampleRoot = Split-Path -Parent $PSScriptRoot

Push-Location $exampleRoot
try {
    & ninja -f build.ninja -t clean | Out-Null
    & ninja -f build.ninja

    $exePath = Join-Path $exampleRoot "out\ninja-lab.exe"
    if (-not (Test-Path -LiteralPath $exePath)) {
        throw "Expected ninja output was not created."
    }

    $listedOutputs = & (Join-Path $exampleRoot "tests\list-outputs.ps1") -OutputDir (Join-Path $exampleRoot "out")
    if (-not $listedOutputs) {
        throw "List-output helper did not return any rows."
    }

    & (Join-Path $exampleRoot "tests\smoke.ps1") -Executable $exePath
}
finally {
    Pop-Location
}

Write-Host "Ninja build, clean, and smoke-test flow looks valid."
