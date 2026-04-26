. (Join-Path $PSScriptRoot '_helpers.ps1')

$repoRoot = Get-RepoRoot
$setupSh  = Join-Path $repoRoot 'configs\debian\setup-debian.sh'

if (-not (Test-Path $setupSh)) {
    throw "configs/debian/setup-debian.sh not found at $setupSh"
}

# --- Get the WSL Debian sudo password ---
# 1. Check $env:WSL_SUDO_PASS first (for unattended runs)
# 2. Otherwise prompt interactively (Read-Host -AsSecureString — never echoed, never logged)
$sudoPass = $env:WSL_SUDO_PASS
if (-not $sudoPass) {
    Write-Step "WSL Debian sudo password is needed for the apt installs."
    $secure = Read-Host -Prompt "  Enter your Debian sudo password" -AsSecureString
    $bstr   = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($secure)
    try {
        $sudoPass = [System.Runtime.InteropServices.Marshal]::PtrToStringBSTR($bstr)
    } finally {
        [System.Runtime.InteropServices.Marshal]::ZeroFreeBSTR($bstr)
    }
} else {
    Write-Skip "WSL_SUDO_PASS env var detected — using it (unattended mode)"
}

if (-not $sudoPass) {
    throw "No sudo password provided. Aborting WSL setup."
}

Write-Step "Running Debian setup script (apt installs, zsh, plugins, SSH copy)"
Write-Host "  This is the longest task — apt + tools + Starship + plugin clones." -ForegroundColor DarkGray

# Path translation: /mnt/c/Users/.../setup-debian.sh
$setupShWsl = "/mnt/c" + ($setupSh.Substring(2).Replace('\','/'))

# Pass sudo password + Windows username via env vars to the bash script.
# WIN_USER tells the script where to look for SSH keys to copy into WSL.
$winUser = $env:USERNAME
wsl -d Debian -- /bin/bash -c "SUDO_PASS='$sudoPass' WIN_USER='$winUser' bash '$setupShWsl'"

if ($LASTEXITCODE -ne 0) {
    throw "Debian setup script exited with code $LASTEXITCODE"
}

# Now deploy the Debian dotfiles (.zshrc, .config/starship.toml)
Write-Step "Deploying Debian dotfiles (.zshrc, starship.toml, .ssh/config)"
$debianConfigs = Join-Path $repoRoot 'configs\debian'

$dotfiles = @(
    @{Src='.zshrc';                Dst='~/.zshrc'},
    @{Src='.config/starship.toml'; Dst='~/.config/starship.toml'}
)

foreach ($f in $dotfiles) {
    $srcWin = Join-Path $debianConfigs ($f.Src -replace '/','\')
    if (-not (Test-Path $srcWin)) {
        Write-Warn "Source missing: $srcWin"
        continue
    }
    $srcWsl = "/mnt/c" + ($srcWin.Substring(2).Replace('\','/'))
    $dstDir = Split-Path $f.Dst -Parent
    wsl -d Debian -- /bin/bash -c "mkdir -p $dstDir && cp '$srcWsl' $($f.Dst)"
    Write-Ok "Deployed $($f.Dst)"
}

# Also write a sensible ~/.ssh/config inside WSL (mirrors the Windows one).
# Only write if the user actually has the github + starnet keys present.
Write-Step "Writing ~/.ssh/config in WSL (idempotent)"
$sshConfigContent = @'
# GitHub
Host github.com
    HostName github.com
    User git
    IdentityFile ~/.ssh/github_ed25519
    IdentitiesOnly yes

# Azure DevOps Git
Host ssh.dev.azure.com
    HostName ssh.dev.azure.com
    User git
    IdentityFile ~/.ssh/starnet_rsa
    IdentitiesOnly yes
'@
# Write the config file via heredoc inside wsl
$tmpConfig = Join-Path $env:TEMP "wsl_ssh_config_$(Get-Random)"
$sshConfigContent | Out-File -Encoding ASCII -NoNewline $tmpConfig
$tmpConfigWsl = "/mnt/c" + ($tmpConfig.Substring(2).Replace('\','/'))
wsl -d Debian -- /bin/bash -c "if [ -f ~/.ssh/github_ed25519 ] || [ -f ~/.ssh/starnet_rsa ]; then cp '$tmpConfigWsl' ~/.ssh/config && chmod 600 ~/.ssh/config && echo 'Wrote ~/.ssh/config'; else echo 'Skipped ~/.ssh/config (no keys present)'; fi"
Remove-Item $tmpConfig -ErrorAction SilentlyContinue

Write-Ok "WSL Debian setup complete"
