[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
$tests = @(
    "examples/01-open-folder-multi-root/tests/validate.ps1",
    "examples/02-open-folder-cpp-environments/tests/validate.ps1",
    "examples/03-external-build-ninja/tests/validate.ps1",
    "examples/04-external-build-dsl-pipeline/tests/validate.ps1",
    "examples/05-dsl-textmate-vsix/tests/validate.ps1",
    "examples/06-open-folder-fasm2-build/tests/validate.ps1",
    "examples/07-fasm-textmate-vsix/tests/validate.ps1"
)

$failures = @()

foreach ($relativePath in $tests) {
    $testPath = Join-Path $repoRoot $relativePath
    Write-Host ""
    Write-Host "==> Running $relativePath" -ForegroundColor Cyan

    try {
        & $testPath
        Write-Host "PASS $relativePath" -ForegroundColor Green
    }
    catch {
        Write-Host "FAIL $relativePath" -ForegroundColor Red
        Write-Host $_
        $failures += $relativePath
    }
}

if ($failures.Count -gt 0) {
    throw ("Validation failed for: " + ($failures -join ", "))
}

Write-Host ""
Write-Host "All validations passed." -ForegroundColor Green
