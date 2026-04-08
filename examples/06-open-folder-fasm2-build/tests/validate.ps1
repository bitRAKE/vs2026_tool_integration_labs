[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$exampleRoot = Split-Path -Parent $PSScriptRoot
$tasksPath = Join-Path $exampleRoot "tasks.vs.json"
$buildScript = Join-Path $exampleRoot "scripts\build-sample.ps1"
$syntaxScript = Join-Path $exampleRoot "scripts\test-syntax.ps1"
$showOutputScript = Join-Path $exampleRoot "scripts\show-output.ps1"
$artifactPath = Join-Path $exampleRoot "out\hello.com"

$tasks = Get-Content -Raw $tasksPath | ConvertFrom-Json
if ($tasks.tasks.Count -lt 5) {
    throw "tasks.vs.json does not contain the expected FASM tasks."
}

& $buildScript
if (-not (Test-Path -LiteralPath $artifactPath)) {
    throw "Expected build artifact '$artifactPath' was not produced."
}

& $showOutputScript

& $syntaxScript -InputPath (Join-Path $exampleRoot "src\hello.fasm")
& $syntaxScript -InputPath (Join-Path $exampleRoot "src\showcase.finc")
& $syntaxScript -InputPath (Join-Path $exampleRoot "src\restartout-demo.fasm")

$originalFasm2Path = $env:FASM2_PATH
$originalFasmgPath = $env:FASMG_PATH

try {
    $env:FASM2_PATH = "C:\git\~tgrysztar\fasm2\fasm2.cmd"
    $env:FASMG_PATH = "C:\git\~tgrysztar\fasmg\core\fasmg.exe"
    & $buildScript -OutputPath (Join-Path $exampleRoot "out\override\hello.com")
}
finally {
    $env:FASM2_PATH = $originalFasm2Path
    $env:FASMG_PATH = $originalFasmgPath
}

try {
    & $syntaxScript -InputPath (Join-Path $exampleRoot "src\broken-quote.fasm")
    throw "Broken quote sample unexpectedly passed syntax validation."
}
catch {
    if ($_.Exception.Message -eq "Broken quote sample unexpectedly passed syntax validation.") {
        throw
    }

    Write-Host "Observed expected syntax failure for broken-quote.fasm."
}

Write-Host ("Example 06 validation succeeded: {0}" -f $artifactPath)
