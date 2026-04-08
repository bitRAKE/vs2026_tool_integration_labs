[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$exampleRoot = Split-Path -Parent $PSScriptRoot
$cppPropsPath = Join-Path $exampleRoot "CppProperties.json"
$cppProps = Get-Content -Raw $cppPropsPath | ConvertFrom-Json

if ($cppProps.configurations.Count -lt 2) {
    throw "Expected at least two CppProperties configurations."
}

function Resolve-MacroPath {
    param(
        [Parameter(Mandatory = $true)]
        [string] $Value
    )

    return $Value.Replace('${workspaceRoot}', $exampleRoot)
}

foreach ($configuration in $cppProps.configurations) {
    $environment = $configuration.environments[0]
    $env:VSF_PROFILE = $environment.VSF_PROFILE
    $env:VSF_OUT_DIR = Resolve-MacroPath -Value $environment.VSF_OUT_DIR

    & (Join-Path $exampleRoot "scripts\build.ps1")

    $exePath = Join-Path $env:VSF_OUT_DIR "vsf-environments.exe"
    if (-not (Test-Path -LiteralPath $exePath)) {
        throw "Expected build output was not created: $exePath"
    }

    $output = & $exePath "--local-validation"
    if (($output -join "`n") -notmatch ("profile={0}" -f $env:VSF_PROFILE)) {
        throw "Executable output did not contain profile '$($env:VSF_PROFILE)'."
    }
}

& (Join-Path $exampleRoot "scripts\clean.ps1")
Remove-Item Env:\VSF_PROFILE -ErrorAction SilentlyContinue
Remove-Item Env:\VSF_OUT_DIR -ErrorAction SilentlyContinue

Write-Host "CppProperties environments, build script, and launch outputs look valid."
