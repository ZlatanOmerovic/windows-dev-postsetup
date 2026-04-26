# Shared helpers for bootstrap.ps1 and all tasks/NN-*.ps1.
# Dot-source from the top of any task to make it runnable standalone:
#     . (Join-Path $PSScriptRoot '_helpers.ps1')

function Refresh-Path {
    $env:Path = [Environment]::GetEnvironmentVariable("Path","Machine") + ";" +
                [Environment]::GetEnvironmentVariable("Path","User")
}

function Write-Phase {
    param([string]$Title)
    Write-Host ""
    Write-Host ("=" * 72) -ForegroundColor DarkCyan
    Write-Host "  $Title" -ForegroundColor Cyan
    Write-Host ("=" * 72) -ForegroundColor DarkCyan
}

function Write-Step {
    param([string]$Message)
    Write-Host "  >> $Message" -ForegroundColor Yellow
}

function Write-Ok {
    param([string]$Message)
    Write-Host "  OK   $Message" -ForegroundColor Green
}

function Write-Warn {
    param([string]$Message)
    Write-Host "  WARN $Message" -ForegroundColor Yellow
}

function Write-Skip {
    param([string]$Message)
    Write-Host "  --   $Message (skipped)" -ForegroundColor DarkGray
}

function Test-IsAdmin {
    ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(
        [Security.Principal.WindowsBuiltInRole]::Administrator
    )
}

function Test-CommandExists {
    param([string]$Name)
    $null -ne (Get-Command $Name -ErrorAction SilentlyContinue)
}

# Repo root resolution — works whether dot-sourced from bootstrap.ps1 or a task.
function Get-RepoRoot {
    # When called from a task in tasks/, $PSScriptRoot is the tasks/ dir.
    # When called from bootstrap.ps1 at repo root, $PSScriptRoot is the repo root.
    $here = $PSScriptRoot
    if ((Split-Path $here -Leaf) -eq 'tasks') { return (Split-Path $here -Parent) }
    return $here
}
