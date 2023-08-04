$BackupPath = "$PSScriptRoot/Git"
$ConfigPath = "$Home/.gitconfig"

Function Backup {
    Copy-Item -Path $ConfigPath -Destination $BackupPath
}

Function Restore {
    Copy-Item -Path "$BackupPath/.gitconfig" -Destination $ConfigPath
}

