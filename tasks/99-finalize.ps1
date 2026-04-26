. (Join-Path $PSScriptRoot '_helpers.ps1')

$repoRoot = Get-RepoRoot
$srcTemplate = Join-Path $repoRoot 'MANUAL_STEPS.md'
$dst = "$env:USERPROFILE\MANUAL_STEPS_GENERATED.md"

if (-not (Test-Path $srcTemplate)) {
    Write-Warn "Template MANUAL_STEPS.md not found in repo. Skipping generation."
    return
}

Write-Step "Generating $dst"
$content = Get-Content $srcTemplate -Raw

$header = @"
# MANUAL_STEPS — generated $(Get-Date -Format 'yyyy-MM-dd HH:mm')

This is the personalized post-install checklist. Source repo:
https://github.com/ZlatanOmerovic/windows-dev-postsetup

Machine: $env:COMPUTERNAME
User:    $env:USERNAME
.NET SDKs detected: $(if (Test-CommandExists 'dotnet') { (dotnet --list-sdks 2>&1 | ForEach-Object { ($_ -split ' ')[0] }) -join ', ' } else { 'none' })
Node:    $(if (Test-Path "$env:NVM_SYMLINK\node.exe") { & "$env:NVM_SYMLINK\node.exe" --version } else { 'not active (open new shell or run nvm use)' })
Rust:    $(if (Test-CommandExists 'rustc') { (rustc --version) } else { 'not on PATH (open new shell)' })

---

"@

# Strip the "this is the template" preamble from MANUAL_STEPS.md
$body = $content -replace '(?s)^.*?---\s*\n', ''

Set-Content -Path $dst -Value ($header + $body) -Encoding UTF8
Write-Ok "Generated $dst"

Write-Step "Opening $dst in Notepad"
Start-Process notepad.exe $dst
