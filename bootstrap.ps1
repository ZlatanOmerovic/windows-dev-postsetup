#Requires -Version 5.1
<#
.SYNOPSIS
    windows-dev-postsetup — bootstrap orchestrator.

.DESCRIPTION
    Hit-and-run installer for a fresh Windows 11 dev machine. Runs each tasks/NN-*.ps1
    in numeric order, stopping on critical failure. See README.md for full prerequisites
    and what gets installed.

.EXAMPLE
    irm https://raw.githubusercontent.com/ZlatanOmerovic/windows-dev-postsetup/master/bootstrap.ps1 | iex

.EXAMPLE
    # From a local clone
    .\bootstrap.ps1

.EXAMPLE
    # Skip specific tasks by number prefix
    .\bootstrap.ps1 -Skip 02,08

.EXAMPLE
    # Run only one task
    .\bootstrap.ps1 -Only 07
#>
[CmdletBinding()]
param(
    [string[]]$Skip = @(),
    [string[]]$Only = @()
)

$ErrorActionPreference = 'Stop'
$ProgressPreference    = 'SilentlyContinue'

# ----------------------------------------------------------------------
# Bootstrap context
# ----------------------------------------------------------------------
# When invoked via `irm | iex`, $PSScriptRoot is empty. In that case we
# clone the repo to a tempdir and re-invoke ourselves from there.
if (-not $PSScriptRoot) {
    Write-Host "Detected one-liner invocation (irm | iex)." -ForegroundColor Cyan

    # ----------------------------------------------------------------------
    # Inline preflight — fail fast BEFORE we waste bandwidth on git + clone.
    # Mirrors tasks/00-preflight.ps1 (which still runs after clone for users
    # invoking from a local clone). Duplicated intentionally — _helpers.ps1
    # isn't available yet at this point.
    # ----------------------------------------------------------------------
    Write-Host "  Preflight checks..." -ForegroundColor Cyan

    $isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(
        [Security.Principal.WindowsBuiltInRole]::Administrator)
    if (-not $isAdmin) {
        throw "Bootstrap must run as Administrator. Right-click PowerShell -> 'Run as administrator', then re-run the one-liner."
    }
    Write-Host "    OK   running elevated" -ForegroundColor Green

    if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
        throw "winget not found. Update Windows 11 via Windows Update; winget ships with Win11 22H2+."
    }
    Write-Host "    OK   winget present" -ForegroundColor Green

    $wslOk = $false
    try {
        $distros = wsl -l -q 2>&1 | Where-Object { $_ -and $_.Trim() -ne '' } |
                   ForEach-Object { ($_ -replace '\x00','').Trim() }
        if ($distros -contains 'Debian') { $wslOk = $true }
    } catch { }
    if (-not $wslOk) {
        Write-Host ""
        Write-Host "    WSL2 + Debian not detected. Do this first, then re-run the one-liner:" -ForegroundColor Red
        Write-Host "      1. wsl --install -d Debian   (in this same admin PowerShell)" -ForegroundColor Yellow
        Write-Host "      2. Reboot." -ForegroundColor Yellow
        Write-Host "      3. Launch Debian once from the Start menu and create your sudoer user." -ForegroundColor Yellow
        Write-Host "      4. Re-run the irm | iex one-liner." -ForegroundColor Yellow
        Write-Host ""
        throw "WSL2 + Debian missing."
    }
    Write-Host "    OK   WSL2 Debian detected" -ForegroundColor Green

    # ----------------------------------------------------------------------
    # Now safe to install git (if missing) and clone.
    # ----------------------------------------------------------------------
    if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
        Write-Host "  Git not found — installing Git for Windows via winget (one-time)..." -ForegroundColor Yellow
        winget install -e --id Git.Git `
            --accept-source-agreements `
            --accept-package-agreements `
            --silent `
            --disable-interactivity
        $env:Path = [Environment]::GetEnvironmentVariable("Path","Machine") + ";" +
                    [Environment]::GetEnvironmentVariable("Path","User")
        if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
            throw "Git install completed but 'git' is still not on PATH. Open a new admin PowerShell and re-run the one-liner."
        }
        Write-Host "  Git installed and on PATH ($(git --version))" -ForegroundColor Green
    }

    Write-Host "  Cloning repo to a temp dir..." -ForegroundColor Cyan
    $temp = Join-Path $env:TEMP "windows-dev-postsetup-$(Get-Random)"
    git clone --depth 1 https://github.com/ZlatanOmerovic/windows-dev-postsetup.git $temp
    Push-Location $temp
    try {
        & "$temp\bootstrap.ps1" @PSBoundParameters
    } finally {
        Pop-Location
        # Clean up the cloned tempdir so we don't leave artifacts behind.
        if (Test-Path $temp) {
            Remove-Item -Recurse -Force $temp -ErrorAction SilentlyContinue
        }
    }
    return
}

$RepoRoot = $PSScriptRoot
$TasksDir = Join-Path $RepoRoot 'tasks'

# ----------------------------------------------------------------------
# Helpers — also dot-sourced by tasks, so each task can run standalone
# ----------------------------------------------------------------------
. (Join-Path $TasksDir '_helpers.ps1')

# ----------------------------------------------------------------------
# Task discovery
# ----------------------------------------------------------------------
$AllTasks = Get-ChildItem -Path $TasksDir -Filter '*.ps1' |
            Where-Object { $_.Name -notlike '_*' } |
            Sort-Object Name

if ($AllTasks.Count -eq 0) {
    throw "No tasks found in $TasksDir. Did the clone succeed?"
}

# Filter by -Only / -Skip
$tasks = $AllTasks
if ($Only.Count -gt 0) {
    $tasks = $tasks | Where-Object {
        $prefix = ($_.Name -split '-')[0]
        $Only -contains $prefix
    }
}
if ($Skip.Count -gt 0) {
    $tasks = $tasks | Where-Object {
        $prefix = ($_.Name -split '-')[0]
        -not ($Skip -contains $prefix)
    }
}

# ----------------------------------------------------------------------
# Banner
# ----------------------------------------------------------------------
Write-Phase "windows-dev-postsetup"
Write-Host "  Repo:        $RepoRoot"
Write-Host "  Tasks dir:   $TasksDir"
Write-Host "  Tasks found: $($AllTasks.Count) total, $($tasks.Count) selected"
if ($Only.Count -gt 0) { Write-Host "  -Only:       $($Only -join ', ')" }
if ($Skip.Count -gt 0) { Write-Host "  -Skip:       $($Skip -join ', ')" }
Write-Host ""

# Ensure PATH is fresh before any task runs
Refresh-Path

# ----------------------------------------------------------------------
# Task execution
# ----------------------------------------------------------------------
$failed = @()
foreach ($task in $tasks) {
    $taskName = $task.BaseName
    Write-Phase "Task: $taskName"
    try {
        . $task.FullName
        Refresh-Path
        Write-Host ""
        Write-Ok "$taskName completed"
    } catch {
        Write-Warn "$taskName FAILED: $($_.Exception.Message)"
        $failed += $taskName
        # 00-preflight is the only fatal task — bail if it fails.
        if ($taskName -like '00-*') {
            Write-Host ""
            Write-Host "Preflight failed. Aborting bootstrap." -ForegroundColor Red
            exit 1
        }
        # Otherwise continue to next task — failed list is summarized at end.
    }
}

# ----------------------------------------------------------------------
# Summary
# ----------------------------------------------------------------------
Write-Phase "Bootstrap complete"
$ran  = $tasks.Count - $failed.Count
Write-Host "  Tasks run:    $ran of $($tasks.Count)"
if ($failed.Count -gt 0) {
    Write-Host "  Failed:       $($failed -join ', ')" -ForegroundColor Red
    Write-Host ""
    Write-Host "  You can re-run failed tasks individually with:" -ForegroundColor Yellow
    Write-Host "      .\bootstrap.ps1 -Only $($failed | ForEach-Object { ($_ -split '-')[0] } | Join-String -Separator ',')" -ForegroundColor Yellow
} else {
    Write-Host "  All tasks succeeded." -ForegroundColor Green
}
Write-Host ""
Write-Host "  See MANUAL_STEPS_GENERATED.md in your home dir for post-install actions." -ForegroundColor Cyan
