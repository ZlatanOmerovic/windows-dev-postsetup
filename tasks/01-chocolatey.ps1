. (Join-Path $PSScriptRoot '_helpers.ps1')

if (Test-CommandExists 'choco') {
    Write-Skip "Chocolatey already installed ($(choco --version))"
    return
}

Write-Step "Installing Chocolatey"
Set-ExecutionPolicy Bypass -Scope Process -Force
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))

Refresh-Path
if (Test-CommandExists 'choco') {
    Write-Ok "Chocolatey installed ($(choco --version))"
} else {
    throw "Chocolatey install completed but 'choco' is still not on PATH. Open a new PowerShell and re-run."
}
