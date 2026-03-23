$DocumentsPath = [Environment]::GetFolderPath("MyDocuments")
Copy-Item -Path "$PSScriptRoot/SettingsRepo" -Destination "$DocumentsPath/PowerShell/Modules" -Recurse -Force
Import-Module SettingsRepo -DisableNameChecking -Force
