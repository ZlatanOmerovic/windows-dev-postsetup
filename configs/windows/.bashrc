# ~/.bashrc — Git Bash on Windows
# Generated 2026-04-26 (Windows post-install setup)

# History
HISTFILE=~/.bash_history
HISTSIZE=10000
HISTFILESIZE=20000
HISTCONTROL=ignoreboth:erasedups
shopt -s histappend
shopt -s checkwinsize

# Ensure WinGet shim dir + Starship are on PATH (Git Bash's login profile sometimes drops User-scope Windows PATH entries)
export PATH="$PATH:$HOME/AppData/Local/Microsoft/WinGet/Links:/c/Program Files/starship/bin"

# Modern ls family via eza
alias ls='eza --group-directories-first'
alias ll='eza -lh --group-directories-first --git'
alias la='eza -lah --group-directories-first --git'
alias lt='eza --tree'
# bat and jq work as-is via their own names (no alias needed)

# Quality-of-life
alias g='git'
alias ..='cd ..'
alias ...='cd ../..'

# Shell identifier (read by starship.toml's env_var module to render the [ LABEL ] chip)
export STARSHIP_SHELL_LABEL="GIT BASH"

# Set terminal background (OSC 11) — hackerish dark green
printf '\033]11;#001a00\007'

# Starship prompt (cross-shell parity with WSL zsh, PowerShell 5.1, PowerShell 7)
eval "$(starship init bash)"
