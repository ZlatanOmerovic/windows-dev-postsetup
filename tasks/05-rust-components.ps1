. (Join-Path $PSScriptRoot '_helpers.ps1')

# rustup install puts everything in %USERPROFILE%\.cargo\bin — add to PATH for this session
$env:Path = "$env:USERPROFILE\.cargo\bin;" + $env:Path

if (-not (Test-CommandExists 'rustup')) {
    throw "rustup not found on PATH. Did task 02-winget-batch install Rustlang.Rustup?"
}

Write-Step "rustup version: $(rustup --version | Select-Object -First 1)"

Write-Step "Setting default toolchain to stable"
rustup default stable | Out-Host

Write-Step "Adding components: rust-analyzer, clippy, rustfmt"
rustup component add rust-analyzer clippy rustfmt | Out-Host

Refresh-Path
if (Test-CommandExists 'rustc') {
    Write-Ok "rustc $(rustc --version)"
    Write-Ok "cargo $(cargo --version)"
} else {
    Write-Warn "rustc not on PATH yet — open a new shell to use it."
}
