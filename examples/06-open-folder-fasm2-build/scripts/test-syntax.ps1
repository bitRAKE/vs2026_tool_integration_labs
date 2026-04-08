[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string] $InputPath
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

Import-Module (Join-Path $PSScriptRoot "..\..\..\scripts\common\Vsf.VisualStudioTools.psm1") -Force

$resolvedInput = (Resolve-Path -LiteralPath $InputPath).Path
$extension = [System.IO.Path]::GetExtension($resolvedInput).ToLowerInvariant()

if ($extension -notin @(".fasm", ".finc")) {
    throw "Unsupported source extension '$extension'. Expected .fasm or .finc."
}

$syntaxSource = $resolvedInput
$tempWrapperPath = $null

try {
    if ($extension -eq ".finc") {
        $tempDirectory = Join-Path (Split-Path -Parent $PSScriptRoot) "out\tmp"
        New-Item -ItemType Directory -Path $tempDirectory -Force | Out-Null

        $escapedIncludePath = ($resolvedInput -replace "\\", "/") -replace "'", "''"
        $wrapperLines = @(
            ("include '{0}'" -f $escapedIncludePath)
        )

        $tempWrapperPath = Join-Path $tempDirectory ([System.IO.Path]::GetFileNameWithoutExtension($resolvedInput) + ".syntax-wrapper.fasm")
        Set-Content -LiteralPath $tempWrapperPath -Value $wrapperLines
        $syntaxSource = $tempWrapperPath
    }

    $toolchain = Invoke-VsfFasmSource -SourcePath $syntaxSource -OutputPath "nul" -PreferDirectFasmg
}
finally {
    if ($tempWrapperPath -and (Test-Path -LiteralPath $tempWrapperPath)) {
        Remove-Item -LiteralPath $tempWrapperPath -Force
    }
}

$fasm2Path = if ($toolchain.Fasm2Path) { $toolchain.Fasm2Path } else { "<not found>" }
$fasmgPath = if ($toolchain.FasmgPath) { $toolchain.FasmgPath } else { "<not found>" }

Write-Host ("Syntax check passed: {0}" -f $resolvedInput)
Write-Host ("fasm2 path        : {0}" -f $fasm2Path)
Write-Host ("fasmg path        : {0}" -f $fasmgPath)
