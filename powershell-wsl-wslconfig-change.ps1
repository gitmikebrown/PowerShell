# Define path to .wslconfig
$wslConfigPath = "$env:USERPROFILE\.wslconfig"

# Get last modified timestamp
$lastModified = (Get-Item $wslConfigPath).LastWriteTime

# Get last shutdown timestamp (stored locally)
$stampPath = "$env:USERPROFILE\.wsl_last_shutdown.txt"
$lastShutdown = if (Test-Path $stampPath) {
    Get-Content $stampPath | Out-String | ConvertFrom-StringData
} else {
    @{ Timestamp = "Never" }
}

# Compare timestamps
if ($lastModified -gt [datetime]$lastShutdown.Timestamp) {
    Write-Host "⚠️ .wslconfig was modified after the last shutdown." -ForegroundColor Yellow
    $confirm = Read-Host "Do you want to run 'wsl --shutdown' now? (Y/N)"
    if ($confirm -match '^[Yy]$') {
        wsl --shutdown
        @{ Timestamp = (Get-Date).ToString("o") } | Out-File $stampPath
        Write-Host "✅ WSL engine shut down and timestamp updated." -ForegroundColor Green
    } else {
        Write-Host "⏭️ Skipped shutdown. WSL may not reload new config." -ForegroundColor Cyan
    }
} else {
    Write-Host "✅ No changes detected in .wslconfig since last shutdown." -ForegroundColor Green
}