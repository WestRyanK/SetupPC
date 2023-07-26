$BackupPath = "$PSScriptRoot/Vim"

Function Backup {
    Copy-Item -Path "$Home/_vimrc" -Destination $BackupPath
    Copy-Item -Path "$Home/_ideavimrc" -Destination $BackupPath
}

Function Restore {
    Copy-Item -Path "$BackupPath/*" -Destination $Home
}
