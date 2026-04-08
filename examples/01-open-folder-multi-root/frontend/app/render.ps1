[CmdletBinding()]
param()

$payload = [ordered]@{
    role = "client"
    script = $MyInvocation.MyCommand.Name
    message = "Client workspace task target"
}

$payload | ConvertTo-Json -Depth 3

