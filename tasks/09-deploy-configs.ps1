. (Join-Path $PSScriptRoot '_helpers.ps1')

$repoRoot = Get-RepoRoot
$src      = Join-Path $repoRoot 'configs\windows'

# (source-relative-to-configs/windows) -> (target absolute path)
# Shell rc/profile-style configs only. Terminal-emulator configs are deployed
# by their own tasks (10-windows-terminal, 11-wezterm).
$mappings = @(
    @{Src='.config\starship.toml';                                                 Dst="$env:USERPROFILE\.config\starship.toml"},
    @{Src='.bashrc';                                                               Dst="$env:USERPROFILE\.bashrc"},
    @{Src='.bash_profile';                                                         Dst="$env:USERPROFILE\.bash_profile"},
    @{Src='Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1';          Dst="$env:USERPROFILE\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1"},
    @{Src='Documents\PowerShell\Microsoft.PowerShell_profile.ps1';                 Dst="$env:USERPROFILE\Documents\PowerShell\Microsoft.PowerShell_profile.ps1"},
    @{Src='AppData\Roaming\Sublime Text\Packages\User\Preferences.sublime-settings'; Dst="$env:APPDATA\Sublime Text\Packages\User\Preferences.sublime-settings"}
)

foreach ($m in $mappings) {
    $srcPath = Join-Path $src $m.Src
    if (-not (Test-Path $srcPath)) {
        Write-Warn "Source missing: $srcPath — skipping"
        continue
    }
    $dstDir = Split-Path $m.Dst -Parent
    if (-not (Test-Path $dstDir)) {
        New-Item -ItemType Directory -Path $dstDir -Force | Out-Null
    }
    Copy-Item -Path $srcPath -Destination $m.Dst -Force
    Write-Ok "Deployed $($m.Dst.Replace($env:USERPROFILE,'~'))"
}

Write-Step "Setting PowerShell ExecutionPolicy = RemoteSigned (CurrentUser)"
# PS 5.1
Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned -Force
Write-Ok "PS 5.1 ExecutionPolicy set"

# PS 7 (pwsh) — only if installed
if (Test-CommandExists 'pwsh') {
    pwsh -NoProfile -Command "Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned -Force"
    Write-Ok "PS 7 ExecutionPolicy set"
} else {
    Write-Skip "pwsh not yet on PATH — open new shell to apply ExecutionPolicy for PS 7"
}
