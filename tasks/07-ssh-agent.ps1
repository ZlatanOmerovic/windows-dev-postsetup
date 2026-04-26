. (Join-Path $PSScriptRoot '_helpers.ps1')

$sshDir = Join-Path $env:USERPROFILE '.ssh'

if (-not (Test-Path $sshDir)) {
    Write-Warn "$sshDir does not exist."
    Write-Host "  Drop your SSH keys at $sshDir, then re-run this task with:" -ForegroundColor Yellow
    Write-Host "      .\bootstrap.ps1 -Only 07" -ForegroundColor Yellow
    return
}

# Find private keys (anything in .ssh/ that isn't .pub, .ppk, config, or known_hosts)
$privateKeys = Get-ChildItem $sshDir -File -ErrorAction SilentlyContinue | Where-Object {
    $_.Name -notmatch '\.(pub|ppk)$' -and
    $_.Name -ne 'config' -and
    $_.Name -ne 'known_hosts' -and
    $_.Name -ne 'authorized_keys'
}

if ($privateKeys.Count -eq 0) {
    Write-Warn "No private SSH keys found in $sshDir."
    Write-Host "  Drop your keys there, then re-run this task with:" -ForegroundColor Yellow
    Write-Host "      .\bootstrap.ps1 -Only 07" -ForegroundColor Yellow
    return
}

Write-Step "Enabling and starting Windows ssh-agent service"
Get-Service ssh-agent | Set-Service -StartupType Automatic
Start-Service ssh-agent
$svc = Get-Service ssh-agent
Write-Ok "ssh-agent: $($svc.Status), startup=$($svc.StartType)"

Write-Step "Locking down ACLs on $($privateKeys.Count) private key(s)"
foreach ($key in $privateKeys) {
    icacls $key.FullName /inheritance:r 2>&1 | Out-Null
    icacls $key.FullName /grant:r "${env:USERNAME}:(R)" 2>&1 | Out-Null
    Write-Ok "ACL fixed: $($key.Name)"
}

Write-Step "Loading keys into ssh-agent (using Windows OpenSSH explicitly to avoid Git Bash's ssh-add)"
$winSshAdd = "C:\Windows\System32\OpenSSH\ssh-add.exe"
foreach ($key in $privateKeys) {
    & $winSshAdd $key.FullName 2>&1 | Out-Host
}

Write-Step "Loaded keys:"
& $winSshAdd -l | Out-Host

Write-Step "Pointing git at Windows OpenSSH (so 'git push' uses the loaded agent)"
git config --global core.sshCommand "C:/Windows/System32/OpenSSH/ssh.exe"
Write-Ok "git core.sshCommand = $(git config --global core.sshCommand)"

# Lock down ACL on .ssh/config too if it exists
$sshConfig = Join-Path $sshDir 'config'
if (Test-Path $sshConfig) {
    icacls $sshConfig /inheritance:r 2>&1 | Out-Null
    icacls $sshConfig /grant:r "${env:USERNAME}:(R,W)" 2>&1 | Out-Null
    Write-Ok "ACL locked on .ssh/config"
}
