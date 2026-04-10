[CmdletBinding()]
param(
    [ValidateSet("Debug", "Release")]
    [string] $Configuration = "Release"
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

Import-Module (Join-Path $PSScriptRoot "..\..\..\scripts\common\Vsf.VisualStudioTools.psm1") -Force

$exampleRoot = Split-Path -Parent $PSScriptRoot
$instance = Get-VsfVisualStudioInstance -RequiredWorkload "Microsoft.VisualStudio.Workload.VisualStudioExtension"
$vsixInstallerPath = Join-Path $instance.installationPath "Common7\IDE\VSIXInstaller.exe"

if (-not (Test-Path -LiteralPath $vsixInstallerPath)) {
    throw "VSIXInstaller.exe was not found at '$vsixInstallerPath'."
}

$vsixPath = Join-Path $exampleRoot ("bin\{0}\FasmgSelectionCommands.vsix" -f $Configuration)
if (-not (Test-Path -LiteralPath $vsixPath)) {
    throw "VSIX file not found at '$vsixPath'. Build the project first."
}

Write-Host ("Launching VSIX installer: {0}" -f $vsixInstallerPath)
Write-Host ("Package: {0}" -f $vsixPath)

& $vsixInstallerPath $vsixPath
if ($LASTEXITCODE -ne 0) {
    throw "VSIXInstaller exited with code $LASTEXITCODE."
}
