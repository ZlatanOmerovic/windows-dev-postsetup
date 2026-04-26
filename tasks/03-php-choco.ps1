. (Join-Path $PSScriptRoot '_helpers.ps1')

Refresh-Path
if (-not (Test-CommandExists 'choco')) {
    throw "choco not found on PATH. Did task 01-chocolatey run successfully?"
}

if (Test-CommandExists 'php') {
    Write-Skip "PHP already installed ($(php --version | Select-Object -First 1))"
    return
}

Write-Step "Installing PHP via Chocolatey"
choco install php -y --no-progress 2>&1 | Out-String | Out-Host

Refresh-Path
if (Test-CommandExists 'php') {
    Write-Ok "PHP installed ($(php --version | Select-Object -First 1))"
} else {
    Write-Warn "PHP install reported success but 'php' isn't on PATH yet — open a new shell to use it."
}
