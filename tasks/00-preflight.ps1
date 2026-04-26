. (Join-Path $PSScriptRoot '_helpers.ps1')

Write-Step "Checking PowerShell elevation"
if (-not (Test-IsAdmin)) {
    throw "Bootstrap must run as Administrator. Right-click PowerShell -> 'Run as administrator', then re-run."
}
Write-Ok "Running elevated"

Write-Step "Checking winget is available"
if (-not (Test-CommandExists 'winget')) {
    throw "winget not found. Update Windows 11 via Windows Update; winget ships with Win11 22H2+."
}
$wingetVer = (winget --version) 2>&1 | Select-Object -First 1
Write-Ok "winget present ($wingetVer)"

Write-Step "Checking WSL2 is enabled and a Debian distro is present"
$wslOk = $false
try {
    $distros = wsl -l -q 2>&1 | Where-Object { $_ -and $_.Trim() -ne '' } | ForEach-Object { ($_ -replace '\x00','').Trim() }
    if ($distros -contains 'Debian') {
        $wslOk = $true
    }
} catch {
    # wsl.exe not installed at all
}
if (-not $wslOk) {
    Write-Host ""
    Write-Host "  WSL2 + Debian not detected. Do this first, then re-run bootstrap:" -ForegroundColor Red
    Write-Host ""
    Write-Host "    1. Open admin PowerShell" -ForegroundColor Yellow
    Write-Host "    2. wsl --install -d Debian" -ForegroundColor Yellow
    Write-Host "    3. Reboot" -ForegroundColor Yellow
    Write-Host "    4. Launch Debian once from the Start menu and create your user (set a password)" -ForegroundColor Yellow
    Write-Host "    5. Re-run this bootstrap" -ForegroundColor Yellow
    Write-Host ""
    throw "WSL2 + Debian missing. See instructions above."
}
Write-Ok "Debian distro detected"

Write-Step "Checking git is available (needed to clone the repo for one-liner usage)"
if (-not (Test-CommandExists 'git')) {
    Write-Warn "git not found on PATH. Will be installed via winget in task 02. Continuing."
} else {
    Write-Ok "git present ($(git --version))"
}

Write-Step "Checking the SSH keys location"
$sshDir = Join-Path $env:USERPROFILE '.ssh'
if (Test-Path $sshDir) {
    $keys = Get-ChildItem $sshDir -ErrorAction SilentlyContinue | Where-Object { $_.Name -notmatch '\.(pub|ppk)$' -and $_.Name -ne 'config' -and $_.Name -ne 'known_hosts' }
    if ($keys.Count -gt 0) {
        Write-Ok "$($keys.Count) private key(s) found at $sshDir"
    } else {
        Write-Warn "No private SSH keys at $sshDir. Task 07 will skip the agent setup."
    }
} else {
    Write-Warn "$sshDir does not exist. Task 07 will skip the agent setup."
}
