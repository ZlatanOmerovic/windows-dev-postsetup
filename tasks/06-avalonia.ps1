. (Join-Path $PSScriptRoot '_helpers.ps1')

Refresh-Path
if (-not (Test-CommandExists 'dotnet')) {
    throw "dotnet not found on PATH. Did task 02-winget-batch install Microsoft.DotNet.SDK.10?"
}

Write-Step "Installed .NET SDKs:"
dotnet --list-sdks | Out-Host

Write-Step "Installing Avalonia project templates"
# `dotnet new install` is idempotent — re-running just no-ops if already installed
dotnet new install Avalonia.Templates 2>&1 | Out-String | Out-Host

Write-Ok "Avalonia templates installed"
