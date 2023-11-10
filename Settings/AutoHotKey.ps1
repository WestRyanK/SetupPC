$BackupPath = "$PSScriptRoot/AutoHotKey"
$ScriptsPath = "$Home/AutoHotKey"

Function Backup {
    if (Test-Path $BackupPath) {
        Get-ChildItem -Path $BackupPath | Remove-Item -Recurse -Force
    }
    Get-ChildItem -Path $ScriptsPath | Copy-Item -Destination $BackupPath -Recurse -Force
}

Function Restore {
    if (Test-Path $ScriptsPath) {
        Get-ChildItem -Path $ScriptsPath -Recurse | Remove-Item -Recurse -Force
    }
    $null = New-Item -ItemType Directory -Path $ScriptsPath -Force
    Copy-Item -Recurse -Path "$BackupPath/*" -Destination $ScriptsPath -Force

    Get-ChildItem -Path $ScriptsPath -Filter "*.ahk" | Foreach-Object {
        $ScriptName = $_.BaseName
        $ShortcutPath = "$env:AppData/Microsoft/Windows/Start Menu/Programs/Startup/${ScriptName}.lnk"
        if (-not (Test-Path $ShortcutPath)) {
            $Shell = New-Object -comObject WScript.Shell
            $Shortcut = $shell.CreateShortcut($ShortcutPath)
            $Shortcut.TargetPath = $_.FullName
            $Shortcut.Arguments = $Arguments
            $Shortcut.Save()
        }
    }
}
