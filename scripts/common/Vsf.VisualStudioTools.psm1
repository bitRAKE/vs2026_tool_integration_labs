Set-StrictMode -Version Latest

function Get-VsfExistingPathInfo {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [object[]] $Candidates
    )

    foreach ($candidate in $Candidates) {
        if (-not $candidate) {
            continue
        }

        if (-not $candidate.Path) {
            continue
        }

        if (Test-Path -LiteralPath $candidate.Path) {
            return [pscustomobject]@{
                Path = (Resolve-Path -LiteralPath $candidate.Path).Path
                Source = $candidate.Source
            }
        }
    }

    return $null
}

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

function Get-VsfFasmToolchain {
    [CmdletBinding()]
    param()

    $defaultFasm2Path = "C:\git\~tgrysztar\fasm2\fasm2.cmd"
    $defaultFasmgPath = "C:\git\~tgrysztar\fasmg\core\fasmg.exe"

    $fasm2Candidates = @()
    if ($env:FASM2_PATH) {
        $fasm2Candidates += [pscustomobject]@{
            Path = $env:FASM2_PATH
            Source = "FASM2_PATH"
        }
    }

    $fasm2Candidates += [pscustomobject]@{
        Path = $defaultFasm2Path
        Source = "default"
    }

    $fasm2Info = Get-VsfExistingPathInfo -Candidates $fasm2Candidates

    $fasmRoots = @()
    if ($fasm2Info) {
        $fasmRoots += (Split-Path -Path $fasm2Info.Path -Parent)
    }

    $fasmRoots += (Split-Path -Path $defaultFasm2Path -Parent)
    $fasmRoots = $fasmRoots | Where-Object { $_ } | Select-Object -Unique

    $fasm2IncludeCandidates = @()
    foreach ($root in $fasmRoots) {
        $source = if ($fasm2Info -and $root -eq (Split-Path -Path $fasm2Info.Path -Parent)) {
            if ($fasm2Info.Source -eq "FASM2_PATH") { "FASM2_PATH include" } else { "fasm2 sibling include" }
        }
        else {
            "default include"
        }

        $fasm2IncludeCandidates += [pscustomobject]@{
            Path = (Join-Path $root "include\fasm2.inc")
            Source = $source
        }
    }

    $fasm2IncludeInfo = Get-VsfExistingPathInfo -Candidates $fasm2IncludeCandidates

    $fasmgCandidates = @()
    if ($env:FASMG_PATH) {
        $fasmgCandidates += [pscustomobject]@{
            Path = $env:FASMG_PATH
            Source = "FASMG_PATH"
        }
    }

    if ($fasm2Info) {
        $fasmgCandidates += [pscustomobject]@{
            Path = (Join-Path (Split-Path -Path $fasm2Info.Path -Parent) "fasmg.exe")
            Source = "fasm2 sibling"
        }
    }

    $fasmgCandidates += [pscustomobject]@{
        Path = $defaultFasmgPath
        Source = "default"
    }

    $fasmgInfo = Get-VsfExistingPathInfo -Candidates $fasmgCandidates

    return [pscustomobject]@{
        Fasm2Path = if ($fasm2Info) { $fasm2Info.Path } else { $null }
        Fasm2Source = if ($fasm2Info) { $fasm2Info.Source } else { $null }
        Fasm2IncludePath = if ($fasm2IncludeInfo) { $fasm2IncludeInfo.Path } else { $null }
        Fasm2IncludeSource = if ($fasm2IncludeInfo) { $fasm2IncludeInfo.Source } else { $null }
        FasmgPath = if ($fasmgInfo) { $fasmgInfo.Path } else { $null }
        FasmgSource = if ($fasmgInfo) { $fasmgInfo.Source } else { $null }
        CanUseDirectFasmg = [bool]($fasmgInfo -and $fasm2IncludeInfo)
    }
}

function Invoke-VsfFasmSource {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string] $SourcePath,

        [Parameter(Mandatory = $true)]
        [string] $OutputPath,

        [switch] $PreferDirectFasmg
    )

    if (-not (Test-Path -LiteralPath $SourcePath)) {
        throw "Source file '$SourcePath' was not found."
    }

    $resolvedSource = (Resolve-Path -LiteralPath $SourcePath).Path
    $toolchain = Get-VsfFasmToolchain

    if ($PreferDirectFasmg -and $toolchain.CanUseDirectFasmg) {
        $injectedCommand = "Include('{0}')" -f ($toolchain.Fasm2IncludePath -replace "'", "''")
        $output = & $toolchain.FasmgPath "-i$injectedCommand" $resolvedSource $OutputPath 2>&1
        foreach ($line in $output) {
            Write-Host $line
        }

        if ($LASTEXITCODE -ne 0) {
            throw "fasmg.exe returned exit code $LASTEXITCODE."
        }

        return $toolchain
    }

    if ($toolchain.Fasm2Path) {
        $command = ('""{0}" "{1}" "{2}""' -f $toolchain.Fasm2Path, $resolvedSource, $OutputPath)
        $output = & cmd.exe /d /s /c $command 2>&1
        foreach ($line in $output) {
            Write-Host $line
        }

        if ($LASTEXITCODE -ne 0) {
            throw "fasm2.cmd returned exit code $LASTEXITCODE."
        }

        return $toolchain
    }

    if ($toolchain.CanUseDirectFasmg) {
        $injectedCommand = "Include('{0}')" -f ($toolchain.Fasm2IncludePath -replace "'", "''")
        $output = & $toolchain.FasmgPath "-i$injectedCommand" $resolvedSource $OutputPath 2>&1
        foreach ($line in $output) {
            Write-Host $line
        }

        if ($LASTEXITCODE -ne 0) {
            throw "fasmg.exe returned exit code $LASTEXITCODE."
        }

        return $toolchain
    }

    throw "Unable to locate a usable fasm toolchain. Set FASM2_PATH to fasm2.cmd or set both FASM2_PATH and FASMG_PATH to a compatible checkout."
}

Export-ModuleMember -Function Get-VsfVisualStudioInstance, Get-VsfVsDevCmdPath, Get-VsfMSBuildPath, Invoke-VsfVsDevCommand, Get-VsfFasmToolchain, Invoke-VsfFasmSource
