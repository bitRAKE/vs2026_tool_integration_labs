[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

Import-Module (Join-Path $PSScriptRoot "..\..\..\scripts\common\Vsf.VisualStudioTools.psm1") -Force

$exampleRoot = Split-Path -Parent $PSScriptRoot
$projectPath = Join-Path $exampleRoot "FasmSyntaxHighlighting.csproj"
$grammarPath = Join-Path $exampleRoot "Grammars\fasm.tmLanguage.json"
$languageConfigPath = Join-Path $exampleRoot "fasm-language-configuration.json"
$pkgDefPath = Join-Path $exampleRoot "FasmLanguage.pkgdef"

$grammar = Get-Content -Raw $grammarPath | ConvertFrom-Json
if ($grammar.fileTypes -notcontains "fasm" -or $grammar.fileTypes -notcontains "finc") {
    throw "Grammar does not register both .fasm and .finc."
}

if ($grammar.scopeName -ne "source.fasmg") {
    throw ("Grammar scope name was '{0}', expected 'source.fasmg'." -f $grammar.scopeName)
}

$repo = $grammar.repository.PSObject.Properties.Name
foreach ($requiredRule in @("numbers", "strings", "preprocessor", "directives", "calminstruction-block")) {
    if ($repo -notcontains $requiredRule) {
        throw ("Grammar repository is missing the '{0}' rule." -f $requiredRule)
    }
}

$null = Get-Content -Raw $languageConfigPath | ConvertFrom-Json

$pkgDefText = Get-Content -Raw $pkgDefPath
if ($pkgDefText -notmatch "source\.fasmg") {
    throw "Pkgdef does not contain the expected grammar mapping."
}

if ($pkgDefText -notmatch '"fasm"' -or $pkgDefText -notmatch '"finc"') {
    throw "Pkgdef does not register both content type mappings."
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
