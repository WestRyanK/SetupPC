$BackupPath = "$PSScriptRoot/AutoHotKey"
$HotkeysPath = "$Home/hotkeys.ahk"

Function Backup {
    Copy-Item -Path $HotkeysPath -Destination $BackupPath
}

Function Restore {
    Copy-Item -Path "$BackupPath/hotkeys.ahk" -Destination $HotkeysPath

    $ShortcutPath = "$env:AppData/Microsoft/Windows/Start Menu/Programs/Startup/hotkeys.lnk"
    if (-not (Test-Path $ShortcutPath)) {
        $Shell = New-Object -comObject WScript.Shell
        $Shortcut = $shell.CreateShortcut($ShortcutPath)
        $Shortcut.TargetPath = $HotkeysPath
        $Shortcut.Arguments = $Arguments
        $Shortcut.Save()
    }
}
