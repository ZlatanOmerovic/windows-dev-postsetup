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
    Write-Host "Detected one-liner invocation (irm | iex). Cloning repo to a temp dir..." -ForegroundColor Cyan
    $temp = Join-Path $env:TEMP "windows-dev-postsetup-$(Get-Random)"
    git clone --depth 1 https://github.com/ZlatanOmerovic/windows-dev-postsetup.git $temp
    Push-Location $temp
    try {
        & "$temp\bootstrap.ps1" @PSBoundParameters
    } finally {
        Pop-Location
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
