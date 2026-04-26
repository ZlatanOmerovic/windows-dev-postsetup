. (Join-Path $PSScriptRoot '_helpers.ps1')

# .wezterm.lua already deployed by 09-deploy-configs.ps1 — this task is a no-op
# kept for symmetry / future expansion (e.g. WezTerm shell integration scripts).

$wezConfig = "$env:USERPROFILE\.wezterm.lua"
if (Test-Path $wezConfig) {
    Write-Ok "WezTerm config present at $wezConfig"
    Write-Skip "Already deployed by task 09 — nothing to do here"
} else {
    Write-Warn "WezTerm config missing at $wezConfig. Did task 09 run?"
}
