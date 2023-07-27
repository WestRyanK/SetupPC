$BackupPath = "$PSScriptRoot/OhMyPosh"

Function Backup {
    Copy-Item -Path "$Home/.oh_my_posh.omp.json" -Destination $BackupPath
}

Function Restore {
    Copy-Item -Path "$BackupPath/*" -Destination $Home
}
