. (Join-Path $PSScriptRoot '_helpers.ps1')

$repoRoot = Get-RepoRoot
$src = Join-Path $repoRoot 'configs\windows\.wezterm.lua'
$dst = "$env:USERPROFILE\.wezterm.lua"

if (-not (Test-Path $src)) {
    throw "Source .wezterm.lua not found at $src"
}

# Backup existing if present
if (Test-Path $dst) {
    $backup = "$dst.bak.$(Get-Date -Format 'yyyyMMdd-HHmmss')"
    Copy-Item -Path $dst -Destination $backup -Force
    Write-Ok "Backed up existing .wezterm.lua -> $backup"
}

Copy-Item -Path $src -Destination $dst -Force
Write-Ok "Deployed .wezterm.lua -> $dst"

if (Test-CommandExists 'wezterm') {
    Write-Step "WezTerm version: $(wezterm --version)"
} else {
    Write-Skip "wezterm not on PATH yet — open a new shell or launch WezTerm directly to use it"
}
