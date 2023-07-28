$PowerToysSettingsPath = "$env:localAppData/Microsoft/PowerToys"
$BackupPath = "$PSScriptRoot/PowerToys"

Function Backup {
    Copy-Item -Path $PowerToysSettingsPath -Destination ([System.IO.DirectoryInfo]$BackupPath).Parent -Recurse -Filter "*.json" -Force
    Get-ChildItem $BackupPath -Directory -Recurse | Where-Object { (Get-ChildItem $_ -File -Recurse) -eq $null } | Remove-Item -Recurse
}

Function Restore {
    if (Test-Path $PowerToysSettingsPath) {
        Get-ChildItem -Path $PowerToysSettingsPath -Filter "*.json" -Recurse | Remove-Item
    }
    $null = New-Item -ItemType Directory -Path $PowerToysSettingsPath -Force
    Copy-Item -Recurse -Path "$BackupPath/*" -Destination $PowerToysSettingsPath -Force
}
