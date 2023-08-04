$BackupPath = "$PSScriptRoot/Vim"
$NVimConfigDir = "$env:LocalAppData/nvim"
$NVimConfigPath = "$NVimConfigDir/init.vim"

Function Backup {
    Copy-Item -Path "$Home/_vimrc" -Destination $BackupPath
    Copy-Item -Path "$Home/_ideavimrc" -Destination $BackupPath
    if (Test-Path $NVimConfigPath) {
        Copy-Item -Path "$NVimConfigDir/init.vim" -Destination $BackupPath
    }
}

Function Restore {
    Copy-Item -Path "$BackupPath/_vimrc" -Destination $Home
    Copy-Item -Path "$BackupPath/_ideavimrc" -Destination $Home
    if (Test-Path "$BackupPath/init.vim") {
        $null = New-Item -ItemType Directory -Path $NVimConfigDir -Force
        Copy-Item -Path "$BackupPath/init.vim" -Destination $NVimConfigDir
    }
}
