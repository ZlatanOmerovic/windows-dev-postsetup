. (Join-Path $PSScriptRoot '_helpers.ps1')

# nvm-windows lives at %LOCALAPPDATA%\nvm and needs NVM_HOME + NVM_SYMLINK in
# the *current* shell (the env vars from winget install only show up in new shells).
$env:NVM_HOME    = "$env:LOCALAPPDATA\nvm"
$env:NVM_SYMLINK = "C:\nvm4w\nodejs"
$env:Path        = "$env:NVM_HOME;$env:NVM_SYMLINK;" + $env:Path

if (-not (Test-Path "$env:NVM_HOME\nvm.exe")) {
    throw "nvm.exe not found at $env:NVM_HOME. Did task 02-winget-batch install CoreyButler.NVMforWindows?"
}

Write-Step "nvm version: $(nvm version)"
Write-Step "Installing Node LTS"
nvm install lts | Out-Host

Write-Step "Activating Node LTS"
$installed = (nvm list | ForEach-Object { ($_ -replace '\*','').Trim() } | Where-Object { $_ -match '^\d+\.\d+\.\d+$' } | Select-Object -First 1)
if (-not $installed) {
    throw "nvm install lts seemed to succeed but no version is listed. Investigate manually."
}
nvm use $installed | Out-Host

Refresh-Path
if (Test-Path "$env:NVM_SYMLINK\node.exe") {
    $nodeVer = & "$env:NVM_SYMLINK\node.exe" --version
    $npmVer  = & "$env:NVM_SYMLINK\npm.cmd" --version
    Write-Ok "Node $nodeVer / npm $npmVer active"
} else {
    Write-Warn "Node symlink not present at $env:NVM_SYMLINK — open a new shell to use 'node'."
}
