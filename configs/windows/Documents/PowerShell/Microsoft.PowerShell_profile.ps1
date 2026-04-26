# PowerShell 7+ profile — Windows post-install setup
# Generated 2026-04-26

# Shell identifier (read by starship.toml's env_var module to render the [ LABEL ] chip)
$env:STARSHIP_SHELL_LABEL = "PS-7"

# Set terminal background (OSC 11) — much darker navy
[Console]::Write([char]27 + "]11;#000a26" + [char]7)

# Starship prompt (cross-shell parity with WSL zsh + Windows PowerShell 5.1)
Invoke-Expression (& starship init powershell)

# Quality-of-life aliases
Set-Alias -Name g -Value git

# Unshadow wget/curl: PowerShell ships built-in aliases that point to Invoke-WebRequest,
# preventing the real binaries from being callable as 'wget' / 'curl'.
Remove-Item Alias:wget -Force -ErrorAction SilentlyContinue
Remove-Item Alias:curl -Force -ErrorAction SilentlyContinue

# Modern ls family via eza (functions because aliases can't take args).
# Functions override built-in aliases (ls -> Get-ChildItem) for this session.
function ls { eza --group-directories-first @args }
function ll { eza -lh --group-directories-first --git @args }
function la { eza -lah --group-directories-first --git @args }
function lt { eza --tree @args }
# bat and jq work as-is via their own names (no alias needed)
