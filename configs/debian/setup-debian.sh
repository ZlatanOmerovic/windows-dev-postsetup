#!/bin/bash
# Debian setup script — runs INSIDE WSL Debian as the WSL user.
# Invoked by tasks/08-wsl-debian.ps1 with $SUDO_PASS env var injected (never written to disk).
#
# What this does:
#   - apt updates + installs zsh + modern CLI tools (fzf, eza, bat, zoxide, ripgrep, etc.)
#   - chsh to zsh as default shell
#   - installs Starship to ~/.local/bin (no sudo)
#   - clones zsh-autosuggestions + zsh-syntax-highlighting
#   - copies SSH keys from /mnt/c/Users/<user>/.ssh/ with proper Linux perms (if present)
#
# Idempotent — safe to re-run.

set -e

if [ -z "$SUDO_PASS" ]; then
    echo "ERROR: SUDO_PASS env var is required (the WSL Debian sudo password)."
    echo "       The Windows-side bootstrap.ps1 task injects this; if you're running"
    echo "       this script standalone, prefix with: SUDO_PASS='...' bash setup-debian.sh"
    exit 1
fi

if [ -z "$WIN_USER" ]; then
    # Fallback: derive from /mnt/c/Users — pick the first dir that has a .ssh in it
    for dir in /mnt/c/Users/*/; do
        if [ -d "$dir.ssh" ]; then
            WIN_USER=$(basename "$dir")
            break
        fi
    done
fi

echo "=== Caching sudo credentials ==="
echo "$SUDO_PASS" | sudo -S -v

echo ""
echo "=== Updating apt cache ==="
sudo apt-get update -qq

echo ""
echo "=== Installing zsh, modern CLI tools, ffmpeg, fastfetch, wget ==="
sudo apt-get install -y --no-install-recommends \
    zsh fzf bat eza zoxide ripgrep curl git ca-certificates \
    build-essential ffmpeg fastfetch wget

echo ""
echo "=== Setting zsh as default shell for $(whoami) ==="
if [ "$(getent passwd $(whoami) | cut -d: -f7)" != "$(which zsh)" ]; then
    sudo chsh -s "$(which zsh)" "$(whoami)"
    echo "Default shell changed to $(which zsh)"
else
    echo "Default shell already $(which zsh) — skipping chsh"
fi

echo ""
echo "=== Installing Starship to ~/.local/bin ==="
mkdir -p "$HOME/.local/bin"
if [ ! -x "$HOME/.local/bin/starship" ]; then
    curl -sS https://starship.rs/install.sh | sh -s -- -y -b "$HOME/.local/bin"
else
    echo "Starship already installed at $HOME/.local/bin/starship — skipping"
fi

echo ""
echo "=== Cloning zsh plugins ==="
mkdir -p "$HOME/.zsh"
[ -d "$HOME/.zsh/zsh-autosuggestions" ] || git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions "$HOME/.zsh/zsh-autosuggestions"
[ -d "$HOME/.zsh/zsh-syntax-highlighting" ] || git clone --depth=1 https://github.com/zsh-users/zsh-syntax-highlighting "$HOME/.zsh/zsh-syntax-highlighting"

echo ""
echo "=== Setting up ~/.ssh directory ==="
mkdir -p "$HOME/.ssh"
chmod 700 "$HOME/.ssh"

if [ -n "$WIN_USER" ] && [ -d "/mnt/c/Users/$WIN_USER/.ssh" ]; then
    echo "Copying SSH keys from /mnt/c/Users/$WIN_USER/.ssh/ ..."
    cp -n /mnt/c/Users/$WIN_USER/.ssh/* "$HOME/.ssh/" 2>/dev/null || true
    # Set proper Linux perms — private keys 0600, public + config 0644
    find "$HOME/.ssh" -type f ! -name "*.pub" ! -name "config" ! -name "known_hosts" -exec chmod 600 {} \;
    find "$HOME/.ssh" -type f \( -name "*.pub" -o -name "config" \) -exec chmod 644 {} \;
    echo "SSH keys copied with Linux perms"
else
    echo "No SSH keys found at /mnt/c/Users/<user>/.ssh — skipping copy"
fi

echo ""
echo "=== Done ==="
echo "  Default shell:   $(getent passwd $(whoami) | cut -d: -f7)"
echo "  Starship:        $($HOME/.local/bin/starship --version 2>/dev/null | head -1)"
echo "  zsh plugins:     $(ls $HOME/.zsh 2>/dev/null | wc -l) installed"
