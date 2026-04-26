. (Join-Path $PSScriptRoot '_helpers.ps1')

$repoRoot = Get-RepoRoot
$packagesFile = Join-Path $repoRoot 'packages.txt'

if (-not (Test-Path $packagesFile)) {
    throw "packages.txt not found at $packagesFile"
}

# Read packages.txt: skip blank lines + comments
$packages = Get-Content $packagesFile |
    Where-Object { $_ -and -not $_.StartsWith('#') } |
    ForEach-Object { $_.Trim() } |
    Where-Object { $_ }

Write-Step "Found $($packages.Count) packages in packages.txt"

$results = @{}
$i = 0
foreach ($pkg in $packages) {
    $i++
    Write-Host ""
    Write-Step "[$i/$($packages.Count)] Installing $pkg"

    $output = winget install -e --id $pkg `
        --accept-source-agreements `
        --accept-package-agreements `
        --silent `
        --disable-interactivity 2>&1 | Out-String

    $exit = $LASTEXITCODE
    $results[$pkg] = $exit
    switch ($exit) {
        0            { Write-Ok "$pkg installed" }
        -1978335189  { Write-Skip "$pkg already up to date" }
        default      {
            Write-Warn "$pkg FAILED (exit $exit)"
            Write-Host $output -ForegroundColor DarkGray
        }
    }
}

Write-Host ""
Write-Step "Summary"
$ok      = ($results.Values | Where-Object { $_ -eq 0 -or $_ -eq -1978335189 }).Count
$failed  = ($results.GetEnumerator() | Where-Object { $_.Value -ne 0 -and $_.Value -ne -1978335189 })
Write-Host "  $ok of $($packages.Count) packages OK"
if ($failed.Count -gt 0) {
    Write-Host "  Failed:" -ForegroundColor Yellow
    foreach ($f in $failed) {
        Write-Host "    $($f.Name)  (exit $($f.Value))" -ForegroundColor Yellow
    }
}

Refresh-Path
