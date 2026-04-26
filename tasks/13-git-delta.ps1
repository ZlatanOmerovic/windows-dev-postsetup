. (Join-Path $PSScriptRoot '_helpers.ps1')

Refresh-Path
if (-not (Test-CommandExists 'delta')) {
    Write-Warn "delta not found on PATH. Did task 02-winget-batch install dandavison.delta?"
    return
}
if (-not (Test-CommandExists 'git')) {
    Write-Warn "git not found on PATH. Did task 02-winget-batch install Git.Git?"
    return
}

Write-Step "Wiring delta into git config (global)"
git config --global core.pager           "delta"
git config --global interactive.diffFilter "delta --color-only"
git config --global delta.navigate        true
git config --global delta.line-numbers    true
git config --global delta.side-by-side    true
git config --global delta.syntax-theme    "Monokai Extended"
git config --global merge.conflictstyle   "diff3"
git config --global diff.colorMoved       "default"

Write-Ok "delta wired:"
git config --global --get-regexp '^(core\.pager|interactive\.diffFilter|delta\.|merge\.conflictstyle|diff\.colorMoved)' | ForEach-Object { Write-Host "  $_" -ForegroundColor DarkGray }
