[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string] $InputPath,

    [Parameter(Mandatory = $true)]
    [string] $OutputPath
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$resolvedInput = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($InputPath)
$resolvedOutput = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($OutputPath)
$outputDir = Split-Path -Parent $resolvedOutput
New-Item -ItemType Directory -Path $outputDir -Force | Out-Null

$lines = Get-Content -LiteralPath $resolvedInput
$pipelineName = $null
$environmentName = $null
$stages = New-Object System.Collections.Generic.List[object]
$currentStage = $null

foreach ($rawLine in $lines) {
    $line = $rawLine.Trim()
    if (-not $line -or $line.StartsWith("#")) {
        continue
    }

    if ($line -match '^pipeline\s+([A-Za-z_][A-Za-z0-9_-]*)$') {
        $pipelineName = $Matches[1]
        continue
    }

    if ($line -match '^env\s+([A-Za-z_][A-Za-z0-9_-]*)$') {
        $environmentName = $Matches[1]
        continue
    }

    if ($line -match '^stage\s+([A-Za-z_][A-Za-z0-9_-]*)$') {
        $currentStage = [ordered]@{
            name = $Matches[1]
            tasks = New-Object System.Collections.Generic.List[object]
        }
        $stages.Add($currentStage)
        continue
    }

    if ($line -match '^task\s+([A-Za-z_][A-Za-z0-9_-]*)\s+uses\s+"(.+)"$') {
        if (-not $currentStage) {
            throw "Encountered task before any stage definition."
        }

        $currentStage.tasks.Add([ordered]@{
            name = $Matches[1]
            command = $Matches[2]
        })
        continue
    }

    throw "Unrecognized DSL line: $rawLine"
}

if (-not $pipelineName) {
    throw "No pipeline name was found."
}

$document = [ordered]@{
    pipeline = $pipelineName
    environment = $environmentName
    stages = $stages
}

$document | ConvertTo-Json -Depth 8 | Set-Content -LiteralPath $resolvedOutput
Write-Host "Generated $resolvedOutput"

