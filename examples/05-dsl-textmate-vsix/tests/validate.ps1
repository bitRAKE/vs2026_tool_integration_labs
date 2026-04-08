[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

Import-Module (Join-Path $PSScriptRoot "..\..\..\scripts\common\Vsf.VisualStudioTools.psm1") -Force

$exampleRoot = Split-Path -Parent $PSScriptRoot
$projectPath = Join-Path $exampleRoot "VsfDslSyntaxHighlighting.csproj"
$grammarPath = Join-Path $exampleRoot "Grammars\vsfdsl.tmLanguage.json"
$languageConfigPath = Join-Path $exampleRoot "vsf-language-configuration.json"
$pkgDefPath = Join-Path $exampleRoot "VsfDslLanguage.pkgdef"

$null = Get-Content -Raw $grammarPath | ConvertFrom-Json
$null = Get-Content -Raw $languageConfigPath | ConvertFrom-Json

$pkgDefText = Get-Content -Raw $pkgDefPath
if ($pkgDefText -notmatch "source\.vsfdsl") {
    throw "Pkgdef does not contain the expected grammar mapping."
}

$msbuildPath = Get-VsfMSBuildPath
& $msbuildPath $projectPath /restore /t:Build /p:Configuration=Release /nologo /verbosity:minimal
if ($LASTEXITCODE -ne 0) {
    throw "MSBuild returned exit code $LASTEXITCODE."
}

$vsix = Get-ChildItem -Path (Join-Path $exampleRoot "bin\Release") -Filter *.vsix -Recurse | Sort-Object LastWriteTime -Descending | Select-Object -First 1
if (-not $vsix) {
    throw "No VSIX package was produced."
}

Write-Host ("VSIX build succeeded: {0}" -f $vsix.FullName)
