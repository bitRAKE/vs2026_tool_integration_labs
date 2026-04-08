[CmdletBinding()]
param(
    [string] $Identifier = "vsf.visualstudio2026.dsl.highlighting",
    [switch] $Quiet,
    [switch] $ShutdownProcesses
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

Import-Module (Join-Path $PSScriptRoot "..\..\..\scripts\common\Vsf.VisualStudioTools.psm1") -Force

$instance = Get-VsfVisualStudioInstance -RequiredWorkload "Microsoft.VisualStudio.Workload.VisualStudioExtension"
$vsixInstallerPath = Join-Path $instance.installationPath "Common7\IDE\VSIXInstaller.exe"

if (-not (Test-Path -LiteralPath $vsixInstallerPath)) {
    throw "VSIXInstaller.exe was not found at '$vsixInstallerPath'."
}

$arguments = @("/uninstall:$Identifier", "/instanceIds:$($instance.instanceId)")
if ($Quiet) {
    $arguments += "/quiet"
}

if ($ShutdownProcesses) {
    if (-not $Quiet) {
        throw "Use -ShutdownProcesses only together with -Quiet. VSIXInstaller requires /shutdownprocesses to be paired with suppressed UI."
    }

    $arguments += "/shutdownprocesses"
}

Write-Host ("Launching VSIX installer: {0}" -f $vsixInstallerPath)
Write-Host ("Arguments: {0}" -f ($arguments -join " "))

& $vsixInstallerPath @arguments
if ($LASTEXITCODE -ne 0) {
    throw "VSIXInstaller exited with code $LASTEXITCODE."
}

