[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

Import-Module (Join-Path $PSScriptRoot "..\..\..\scripts\common\Vsf.VisualStudioTools.psm1") -Force

$exampleRoot = Split-Path -Parent $PSScriptRoot
$projectPath = Join-Path $exampleRoot "FasmgSelectionCommands.csproj"
$manifestPath = Join-Path $exampleRoot "source.extension.vsixmanifest"
$stringsPath = Join-Path $exampleRoot ".vsextension\string-resources.json"
$transformPath = Join-Path $exampleRoot "FasmgSelectionTransforms.cs"

$manifestText = Get-Content -Raw $manifestPath
if ($manifestText -notmatch "VSSDK\+VisualStudio\.Extensibility") {
    throw "Manifest does not declare a VSSDK+VisualStudio.Extensibility installation type."
}

$strings = Get-Content -Raw $stringsPath | ConvertFrom-Json
foreach ($key in @(
    "FasmgSelectionCommands.Menu.DisplayName",
    "FasmgSelectionCommands.RenameRegister.DisplayName",
    "FasmgSelectionCommands.UppercaseRegisters.DisplayName",
    "FasmgSelectionCommands.LowercaseRegisters.DisplayName",
    "FasmgSelectionCommands.ConvertHex.DisplayName"
)) {
    if (-not $strings.PSObject.Properties.Name.Contains($key)) {
        throw "Missing expected string resource '$key'."
    }
}

Add-Type -TypeDefinition (Get-Content -Raw $transformPath) -Language CSharp

$sample = @"
mov eax, ebx
mov ecx, eax
db "eax 2Ah in string"
; eax 2Ah in comment
dw 2Ah, 100h
"@

$rename = [FasmgSelectionCommands.FasmgSelectionTransforms]::RenameRegisterInSelection($sample, "eax", "r11d")
if ($rename.Replacements -ne 2) {
    throw "Expected 2 register rename replacements, observed $($rename.Replacements)."
}

if ($rename.Text -notmatch "mov r11d, ebx" -or $rename.Text -notmatch "mov ecx, r11d") {
    throw "Register rename did not update code tokens as expected."
}

if ($rename.Text -cmatch 'db "r11d 2Ah in string"' -or $rename.Text -cmatch '; r11d 2Ah in comment') {
    throw "Register rename should not rewrite strings or comments."
}

$upper = [FasmgSelectionCommands.FasmgSelectionTransforms]::UppercaseRegistersInSelection($sample)
if ($upper.Text -notmatch "mov EAX, EBX" -or $upper.Text -notmatch "mov ECX, EAX") {
    throw "Uppercase register transform did not update code tokens as expected."
}

if ($upper.Text -cmatch 'db "EAX 2Ah in string"' -or $upper.Text -cmatch '; EAX 2Ah in comment') {
    throw "Uppercase register transform should not rewrite strings or comments."
}

$hex = [FasmgSelectionCommands.FasmgSelectionTransforms]::ConvertHexSuffixTo0xInSelection($sample)
if ($hex.Replacements -ne 2) {
    throw "Expected 2 hex conversions, observed $($hex.Replacements)."
}

if ($hex.Text -notmatch "dw 0x2A, 0x100") {
    throw "Hex conversion did not rewrite h-suffix literals as expected."
}

if ($hex.Text -cmatch 'db "eax 0x2A in string"' -or $hex.Text -cmatch '; eax 0x2A in comment') {
    throw "Hex conversion should not rewrite strings or comments."
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

Write-Host ("Example 09 validation succeeded: {0}" -f $vsix.FullName)
