Set-StrictMode -Version Latest

Import-Module (Join-Path $PSScriptRoot "..\..\..\scripts\common\Vsf.VisualStudioTools.psm1") -Force

function ConvertTo-VsfHashtable {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        $InputObject
    )

    if ($null -eq $InputObject) {
        return $null
    }

    if ($InputObject -is [string] -or $InputObject -is [ValueType]) {
        return $InputObject
    }

    if ($InputObject -is [System.Collections.IDictionary]) {
        $table = @{}
        foreach ($key in $InputObject.Keys) {
            $table[$key] = ConvertTo-VsfHashtable -InputObject $InputObject[$key]
        }

        return $table
    }

    if ($InputObject -is [System.Collections.IEnumerable] -and -not ($InputObject -is [string])) {
        $items = @()
        foreach ($item in $InputObject) {
            $items += @(ConvertTo-VsfHashtable -InputObject $item)
        }

        return $items
    }

    $propertyTable = @{}
    foreach ($property in $InputObject.PSObject.Properties) {
        $propertyTable[$property.Name] = ConvertTo-VsfHashtable -InputObject $property.Value
    }

    return $propertyTable
}

function Get-VsfProfileExampleRoot {
    return (Split-Path -Parent $PSScriptRoot)
}

function Get-VsfProfileConfigPath {
    return (Join-Path (Get-VsfProfileExampleRoot) "fasm-profiles.json")
}

function Get-VsfProfileSchemaPath {
    return (Join-Path (Get-VsfProfileExampleRoot) "schemas\fasm-profiles.schema.json")
}

function Resolve-VsfProfilePath {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string] $Path
    )

    if ($Path -eq "nul") {
        return "nul"
    }

    if ([System.IO.Path]::IsPathRooted($Path)) {
        return $Path
    }

    return (Join-Path (Get-VsfProfileExampleRoot) $Path)
}

function Get-VsfProfileValue {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [hashtable] $Defaults,

        [Parameter(Mandatory = $true)]
        [hashtable] $Profile,

        [Parameter(Mandatory = $true)]
        [string] $Name,

        $Fallback = $null
    )

    if ($Profile.ContainsKey($Name)) {
        return $Profile[$Name]
    }

    if ($Defaults.ContainsKey($Name)) {
        return $Defaults[$Name]
    }

    return $Fallback
}

function Assert-VsfProfileSemantics {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [hashtable] $Config
    )

    $profiles = $Config["profiles"]
    foreach ($slot in @("build", "syntax", "inspect")) {
        $profileName = $Config["activeProfiles"][$slot]
        if (-not $profiles.ContainsKey($profileName)) {
            throw "Active profile slot '$slot' points to missing profile '$profileName'."
        }
    }

    if ($profiles[$Config["activeProfiles"]["build"]]["kind"] -ne "assemble") {
        throw "The active build profile must be of kind 'assemble'."
    }

    if ($profiles[$Config["activeProfiles"]["syntax"]]["kind"] -ne "syntaxCheck") {
        throw "The active syntax profile must be of kind 'syntaxCheck'."
    }

    if ($profiles[$Config["activeProfiles"]["inspect"]]["kind"] -ne "inspectOutput") {
        throw "The active inspect profile must be of kind 'inspectOutput'."
    }

    foreach ($profileName in $profiles.Keys) {
        $profile = $profiles[$profileName]
        switch ($profile["kind"]) {
            "assemble" {
                $sourcePath = Resolve-VsfProfilePath -Path $profile["source"]
                if (-not (Test-Path -LiteralPath $sourcePath)) {
                    throw "Assemble profile '$profileName' points to missing source '$sourcePath'."
                }
            }
            "syntaxCheck" {
                $sourcePath = Resolve-VsfProfilePath -Path $profile["source"]
                if (-not (Test-Path -LiteralPath $sourcePath)) {
                    throw "Syntax profile '$profileName' points to missing source '$sourcePath'."
                }
            }
            "inspectOutput" { }
            default {
                throw "Profile '$profileName' uses unsupported kind '$($profile["kind"])'."
            }
        }
    }
}

function Get-VsfProfileConfig {
    [CmdletBinding()]
    param()

    $configPath = Get-VsfProfileConfigPath
    $schemaPath = Get-VsfProfileSchemaPath
    $rawJson = Get-Content -Raw $configPath

    $testJson = Get-Command -Name Test-Json -ErrorAction SilentlyContinue
    if ($testJson) {
        if (-not (Test-Json -Json $rawJson -SchemaFile $schemaPath)) {
            throw "Profile file '$configPath' did not validate against '$schemaPath'."
        }
    }

    $configObject = $rawJson | ConvertFrom-Json
    $config = ConvertTo-VsfHashtable -InputObject $configObject
    Assert-VsfProfileSemantics -Config $config
    return $config
}

function Get-VsfResolvedProfile {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [hashtable] $Config,

        [Parameter(Mandatory = $true)]
        [string] $ProfileName,

        [string] $SourceOverride
    )

    $profiles = $Config["profiles"]
    if (-not $profiles.ContainsKey($ProfileName)) {
        throw "Profile '$ProfileName' was not found."
    }

    $profile = $profiles[$ProfileName]
    $defaults = $Config["toolDefaults"]

    $sourcePath = $null
    if ($profile.ContainsKey("source")) {
        $sourcePath = Resolve-VsfProfilePath -Path $profile["source"]
    }

    if ($SourceOverride) {
        $sourcePath = (Resolve-Path -LiteralPath $SourceOverride).Path
    }

    $outputPath = $null
    if ($profile.ContainsKey("output")) {
        $outputPath = Resolve-VsfProfilePath -Path $profile["output"]
    }

    $targetPath = $null
    if ($profile.ContainsKey("target")) {
        $targetPath = Resolve-VsfProfilePath -Path $profile["target"]
    }

    return [pscustomobject]@{
        Name = $ProfileName
        Kind = $profile["kind"]
        Description = $profile["description"]
        Source = $sourcePath
        Output = $outputPath
        Target = $targetPath
        FrontendPreference = [string](Get-VsfProfileValue -Defaults $defaults -Profile $profile -Name "frontendPreference" -Fallback "auto")
        MaxErrors = [int](Get-VsfProfileValue -Defaults $defaults -Profile $profile -Name "maxErrors" -Fallback 1)
        MaxPasses = [int](Get-VsfProfileValue -Defaults $defaults -Profile $profile -Name "maxPasses" -Fallback 100)
        MaxRecursionDepth = [int](Get-VsfProfileValue -Defaults $defaults -Profile $profile -Name "maxRecursionDepth" -Fallback 10000)
        Verbose = [int](Get-VsfProfileValue -Defaults $defaults -Profile $profile -Name "verbose" -Fallback 0)
        InjectedCommands = [string[]](Get-VsfProfileValue -Defaults $defaults -Profile $profile -Name "injectedCommands" -Fallback @())
        PreviewBytes = [int]$(if ($profile.ContainsKey("previewBytes")) { $profile["previewBytes"] } else { 16 })
    }
}

function Get-VsfResolvedProfileBySlot {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [hashtable] $Config,

        [Parameter(Mandatory = $true)]
        [ValidateSet("build", "syntax", "inspect")]
        [string] $ProfileSlot,

        [string] $SourceOverride
    )

    $profileName = $Config["activeProfiles"][$ProfileSlot]
    return Get-VsfResolvedProfile -Config $Config -ProfileName $profileName -SourceOverride $SourceOverride
}

function New-VsfSyntaxWrapperSource {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string] $InputPath
    )

    $resolvedInput = (Resolve-Path -LiteralPath $InputPath).Path
    $escapedIncludePath = ($resolvedInput -replace "\\", "/") -replace "'", "''"
    $tempDirectory = Join-Path (Get-VsfProfileExampleRoot) "out\tmp"
    New-Item -ItemType Directory -Path $tempDirectory -Force | Out-Null

    $wrapperPath = Join-Path $tempDirectory ([System.IO.Path]::GetFileNameWithoutExtension($resolvedInput) + ".syntax-wrapper.fasm")
    Set-Content -LiteralPath $wrapperPath -Value @(
        ("include '{0}'" -f $escapedIncludePath)
    )

    return $wrapperPath
}

function Show-VsfToolchainSummary {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        $Toolchain
    )

    $fasm2Path = if ($Toolchain.Fasm2Path) { $Toolchain.Fasm2Path } else { "<not found>" }
    $fasmgPath = if ($Toolchain.FasmgPath) { $Toolchain.FasmgPath } else { "<not found>" }
    $includePath = if ($Toolchain.Fasm2IncludePath) { $Toolchain.Fasm2IncludePath } else { "<not found>" }

    Write-Host ("fasm2 path    : {0}" -f $fasm2Path)
    Write-Host ("fasmg path    : {0}" -f $fasmgPath)
    Write-Host ("fasm2 include : {0}" -f $includePath)
}

function Invoke-VsfResolvedProfile {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        $Profile
    )

    switch ($Profile.Kind) {
        "assemble" {
            $outputDirectory = Split-Path -Path $Profile.Output -Parent
            if (-not (Test-Path -LiteralPath $outputDirectory)) {
                New-Item -ItemType Directory -Path $outputDirectory -Force | Out-Null
            }

            $toolchain = Invoke-VsfFasmCommand `
                -SourcePath $Profile.Source `
                -OutputPath $Profile.Output `
                -FrontendPreference $Profile.FrontendPreference `
                -MaxErrors $Profile.MaxErrors `
                -MaxPasses $Profile.MaxPasses `
                -MaxRecursionDepth $Profile.MaxRecursionDepth `
                -Verbosity $Profile.Verbose `
                -InjectedCommands $Profile.InjectedCommands

            $artifact = Get-Item -LiteralPath $Profile.Output
            Write-Host ("Profile       : {0}" -f $Profile.Name)
            Write-Host ("Description   : {0}" -f $Profile.Description)
            Write-Host ("Source        : {0}" -f $Profile.Source)
            Write-Host ("Artifact      : {0}" -f $artifact.FullName)
            Write-Host ("Size          : {0} bytes" -f $artifact.Length)
            Show-VsfToolchainSummary -Toolchain $toolchain
        }
        "syntaxCheck" {
            $syntaxSource = $Profile.Source
            $tempWrapper = $null

            try {
                if ([System.IO.Path]::GetExtension($syntaxSource).ToLowerInvariant() -eq ".finc") {
                    $tempWrapper = New-VsfSyntaxWrapperSource -InputPath $syntaxSource
                    $syntaxSource = $tempWrapper
                }

                $syntaxOutput = if ($Profile.Output) { $Profile.Output } else { "nul" }
                $toolchain = Invoke-VsfFasmCommand `
                    -SourcePath $syntaxSource `
                    -OutputPath $syntaxOutput `
                    -FrontendPreference $Profile.FrontendPreference `
                    -MaxErrors $Profile.MaxErrors `
                    -MaxPasses $Profile.MaxPasses `
                    -MaxRecursionDepth $Profile.MaxRecursionDepth `
                    -Verbosity $Profile.Verbose `
                    -InjectedCommands $Profile.InjectedCommands
            }
            finally {
                if ($tempWrapper -and (Test-Path -LiteralPath $tempWrapper)) {
                    Remove-Item -LiteralPath $tempWrapper -Force
                }
            }

            Write-Host ("Profile       : {0}" -f $Profile.Name)
            Write-Host ("Description   : {0}" -f $Profile.Description)
            Write-Host ("Syntax target : {0}" -f $Profile.Source)
            Show-VsfToolchainSummary -Toolchain $toolchain
        }
        "inspectOutput" {
            if (-not (Test-Path -LiteralPath $Profile.Target)) {
                throw "Inspect target '$($Profile.Target)' was not found. Run the build profile first."
            }

            $toolchain = Get-VsfFasmToolchain
            $artifact = Get-Item -LiteralPath $Profile.Target
            $previewBytes = [System.IO.File]::ReadAllBytes($artifact.FullName) |
                Select-Object -First $Profile.PreviewBytes |
                ForEach-Object { $_.ToString("X2") }

            Write-Host ("Profile       : {0}" -f $Profile.Name)
            Write-Host ("Description   : {0}" -f $Profile.Description)
            Write-Host ("Artifact      : {0}" -f $artifact.FullName)
            Write-Host ("Size          : {0} bytes" -f $artifact.Length)
            Write-Host ("Hex preview   : {0}" -f ($previewBytes -join " "))
            Show-VsfToolchainSummary -Toolchain $toolchain
        }
        default {
            throw "Unsupported profile kind '$($Profile.Kind)'."
        }
    }
}

function Show-VsfProfileSummary {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [hashtable] $Config
    )

    Write-Host ("Profile file   : {0}" -f (Get-VsfProfileConfigPath))
    Write-Host ("Schema file    : {0}" -f (Get-VsfProfileSchemaPath))
    Write-Host ("Active build   : {0}" -f $Config["activeProfiles"]["build"])
    Write-Host ("Active syntax  : {0}" -f $Config["activeProfiles"]["syntax"])
    Write-Host ("Active inspect : {0}" -f $Config["activeProfiles"]["inspect"])
    Write-Host ""
    Write-Host "Profiles:"

    foreach ($name in ($Config["profiles"].Keys | Sort-Object)) {
        $profile = $Config["profiles"][$name]
        Write-Host ("- {0} [{1}] {2}" -f $name, $profile["kind"], $profile["description"])
    }
}

Export-ModuleMember -Function Get-VsfProfileConfig, Get-VsfResolvedProfile, Get-VsfResolvedProfileBySlot, Invoke-VsfResolvedProfile, Show-VsfProfileSummary
