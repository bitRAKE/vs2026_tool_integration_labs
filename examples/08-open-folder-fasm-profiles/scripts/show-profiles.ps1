[CmdletBinding()]
param()

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

Import-Module (Join-Path $PSScriptRoot "VsfFasmProfiles.psm1") -Force

$config = Get-VsfProfileConfig
Show-VsfProfileSummary -Config $config
