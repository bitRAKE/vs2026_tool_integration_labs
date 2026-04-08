[CmdletBinding()]
param(
    [ValidateSet("Standard", "Diagnostic")]
    [string] $Mode = "Standard"
)

Write-Output ("service-mode={0}" -f $Mode.ToLowerInvariant())
Write-Output "ready=true"

