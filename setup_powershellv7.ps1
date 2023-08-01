PowerShellGet\Install-Module posh-git -Scope CurrentUser -Force
winget install JanDeDobbeleer.OhMyPosh -s winget
oh-my-posh font install Meslo

Copy-Item -Path "$PSScriptRoot/Modules/*" -Destination "$Home/Documents/PowerShell/Modules" -Recurse -Force
Import-Module SettingsRepo -DisableNameChecking
SettingsRepo-Restore All

Write-Host "Press Enter to close"
Read-Host
