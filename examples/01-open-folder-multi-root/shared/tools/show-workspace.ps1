[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string] $Role,

    [Parameter(Mandatory = $true)]
    [string] $SelectedItem
)

$result = [ordered]@{
    role = $Role
    selectedItem = $SelectedItem
    timestamp = (Get-Date).ToString("s")
}

$result | ConvertTo-Json -Depth 3

