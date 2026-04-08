Set-StrictMode -Version Latest

function Get-VsfVswherePath {
    $path = Join-Path ${env:ProgramFiles(x86)} "Microsoft Visual Studio\Installer\vswhere.exe"
    if (-not (Test-Path -LiteralPath $path)) {
        throw "vswhere.exe was not found at '$path'."
    }

    return $path
}

function Get-VsfVisualStudioInstance {
    [CmdletBinding()]
    param(
        [string] $RequiredWorkload
    )

    $arguments = @("-latest", "-products", "*", "-format", "json")
    if ($RequiredWorkload) {
        $arguments += @("-requires", $RequiredWorkload)
    }

    $rawJson = & (Get-VsfVswherePath) @arguments
    if (-not $rawJson) {
        if ($RequiredWorkload) {
            throw "No Visual Studio instance matched workload '$RequiredWorkload'."
        }

        throw "No Visual Studio instance was found."
    }

    $instances = $rawJson | ConvertFrom-Json
    if ($instances -isnot [System.Array]) {
        $instances = @($instances)
    }

    return $instances[0]
}

function Get-VsfVsDevCmdPath {
    [CmdletBinding()]
    param(
        [string] $RequiredWorkload = "Microsoft.VisualStudio.Workload.NativeDesktop"
    )

    $instance = Get-VsfVisualStudioInstance -RequiredWorkload $RequiredWorkload
    $path = Join-Path $instance.installationPath "Common7\Tools\VsDevCmd.bat"
    if (-not (Test-Path -LiteralPath $path)) {
        throw "VsDevCmd.bat was not found at '$path'."
    }

    return $path
}

function Get-VsfMSBuildPath {
    [CmdletBinding()]
    param(
        [string] $RequiredWorkload = "Microsoft.VisualStudio.Workload.VisualStudioExtension"
    )

    $instance = Get-VsfVisualStudioInstance -RequiredWorkload $RequiredWorkload
    $path = Join-Path $instance.installationPath "MSBuild\Current\Bin\MSBuild.exe"
    if (-not (Test-Path -LiteralPath $path)) {
        throw "MSBuild.exe was not found at '$path'."
    }

    return $path
}

function Invoke-VsfVsDevCommand {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string] $CommandLine,

        [string] $RequiredWorkload = "Microsoft.VisualStudio.Workload.NativeDesktop"
    )

    $vsDevCmd = Get-VsfVsDevCmdPath -RequiredWorkload $RequiredWorkload
    $fullCommand = ('"{0}" -no_logo -arch=x64 -host_arch=x64 >nul && {1}' -f $vsDevCmd, $CommandLine)

    & cmd.exe /d /s /c $fullCommand
    if ($LASTEXITCODE -ne 0) {
        throw "Developer command failed with exit code $LASTEXITCODE."
    }
}

Export-ModuleMember -Function Get-VsfVisualStudioInstance, Get-VsfVsDevCmdPath, Get-VsfMSBuildPath, Invoke-VsfVsDevCommand
