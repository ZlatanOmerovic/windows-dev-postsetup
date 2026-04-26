. (Join-Path $PSScriptRoot '_helpers.ps1')

$repoRoot = Get-RepoRoot
$src      = Join-Path $repoRoot 'configs\windows-terminal\settings.json'

if (-not (Test-Path $src)) {
    throw "Source settings.json not found at $src"
}

# Find the WT package state dir. Could be Microsoft.WindowsTerminal_* or
# Microsoft.WindowsTerminalPreview_*; we target stable.
$wtPkg = Get-ChildItem "$env:LOCALAPPDATA\Packages\" -Filter "Microsoft.WindowsTerminal_*" -Directory -ErrorAction SilentlyContinue |
         Where-Object { $_.Name -notlike '*Preview*' } | Select-Object -First 1

if (-not $wtPkg) {
    Write-Warn "Windows Terminal package state dir not found. WT not installed yet, or not from MS Store."
    Write-Host "  Open Windows Terminal once, then re-run with: .\bootstrap.ps1 -Only 10" -ForegroundColor Yellow
    return
}

$dstDir = Join-Path $wtPkg.FullName 'LocalState'
$dst    = Join-Path $dstDir 'settings.json'

if (-not (Test-Path $dstDir)) {
    New-Item -ItemType Directory -Path $dstDir -Force | Out-Null
}

# Backup existing settings before overwriting
if (Test-Path $dst) {
    $backup = "$dst.bak.$(Get-Date -Format 'yyyyMMdd-HHmmss')"
    Copy-Item -Path $dst -Destination $backup -Force
    Write-Ok "Backed up existing settings.json -> $backup"
}

Copy-Item -Path $src -Destination $dst -Force
Write-Ok "Deployed settings.json -> $dst"

Write-Host ""
Write-Host "  NOTE: dynamic profile GUIDs (Git Bash, Debian, PS 7) are deterministic" -ForegroundColor DarkGray
Write-Host "  hashes of source+name, so they should match across machines. If a profile" -ForegroundColor DarkGray
Write-Host "  appears as a 'ghost' (no commandline), edit settings.json to fix the GUID." -ForegroundColor DarkGray
