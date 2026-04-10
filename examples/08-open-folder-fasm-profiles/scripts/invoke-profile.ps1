[CmdletBinding(DefaultParameterSetName = "Slot")]
param(
    [Parameter(Mandatory = $true, ParameterSetName = "Slot")]
    [ValidateSet("build", "syntax", "inspect")]
    [string] $ProfileSlot,

    [Parameter(Mandatory = $true, ParameterSetName = "Name")]
    [string] $ProfileName,

    [string] $SourceOverride
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

Import-Module (Join-Path $PSScriptRoot "VsfFasmProfiles.psm1") -Force

$config = Get-VsfProfileConfig
$profile = if ($PSCmdlet.ParameterSetName -eq "Slot") {
    Get-VsfResolvedProfileBySlot -Config $config -ProfileSlot $ProfileSlot -SourceOverride $SourceOverride
}
else {
    Get-VsfResolvedProfile -Config $config -ProfileName $ProfileName -SourceOverride $SourceOverride
}

Invoke-VsfResolvedProfile -Profile $profile
