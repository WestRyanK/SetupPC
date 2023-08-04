Copy-Item -Path "$PSScriptRoot/SettingsRepo" -Destination "$Home/Documents/PowerShell/Modules" -Recurse -Force
Import-Module SettingsRepo -DisableNameChecking -Force
