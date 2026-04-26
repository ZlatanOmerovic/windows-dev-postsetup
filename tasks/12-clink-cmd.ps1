. (Join-Path $PSScriptRoot '_helpers.ps1')

$repoRoot = Get-RepoRoot

# --- Deploy starship.lua to %LOCALAPPDATA%\clink\ ---
Write-Step "Deploying starship.lua for Clink"
$srcStarshipLua = Join-Path $repoRoot 'configs\windows\AppData\Local\clink\starship.lua'
$dstStarshipLua = "$env:LOCALAPPDATA\clink\starship.lua"
$dstClinkDir    = Split-Path $dstStarshipLua -Parent
if (-not (Test-Path $dstClinkDir)) {
    New-Item -ItemType Directory -Path $dstClinkDir -Force | Out-Null
}
if (Test-Path $srcStarshipLua) {
    Copy-Item $srcStarshipLua $dstStarshipLua -Force
    Write-Ok "starship.lua -> $dstStarshipLua"
} else {
    Write-Warn "Source starship.lua missing: $srcStarshipLua"
}

# --- Deploy cmd_startup.cmd to %LOCALAPPDATA%\ ---
Write-Step "Deploying cmd_startup.cmd"
$srcCmdStartup = Join-Path $repoRoot 'configs\windows\AppData\Local\cmd_startup.cmd'
$dstCmdStartup = "$env:LOCALAPPDATA\cmd_startup.cmd"
if (Test-Path $srcCmdStartup) {
    Copy-Item $srcCmdStartup $dstCmdStartup -Force
    Write-Ok "cmd_startup.cmd -> $dstCmdStartup"
} else {
    Write-Warn "Source cmd_startup.cmd missing: $srcCmdStartup"
}

# --- Set HKCU CMD AutoRun to point at our wrapper ---
# The wrapper does: doskey aliases + chains to clink.bat inject --autorun
Write-Step "Setting HKCU Command Processor AutoRun = $dstCmdStartup"
$autoRunValue = "`"$dstCmdStartup`""
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Command Processor" -Name "AutoRun" -Value $autoRunValue -Type String -Force
$current = (Get-ItemProperty -Path "HKCU:\Software\Microsoft\Command Processor" -Name "AutoRun").AutoRun
Write-Ok "AutoRun = $current"

# --- Tell Clink to autorun in any cmd.exe (separate from CMD AutoRun) ---
Write-Step "Installing Clink autorun (so the cmd_startup wrapper's call to clink works cleanly)"
$clinkBat = "C:\Program Files (x86)\clink\clink.bat"
if (Test-Path $clinkBat) {
    & $clinkBat autorun install 2>&1 | Out-Host
    Write-Ok "Clink autorun installed"
} else {
    Write-Warn "Clink not found at $clinkBat. Did task 02-winget-batch install chrisant996.Clink?"
}
