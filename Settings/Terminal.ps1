$TerminalSettingsPath = "$env:LocalAppData/Packages/Microsoft.WindowsTerminal_8wekyb3d8bbwe/LocalState"
$BackupPath = "$PSScriptRoot/Terminal"

Function Backup {
    Copy-Item -Path "$TerminalSettingsPath/settings.json" -Destination $BackupPath
}

Function Restore {
    Copy-Item -Path "$BackupPath/*" -Destination $TerminalSettingsPath
}
