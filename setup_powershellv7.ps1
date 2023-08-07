PowerShellGet\Install-Module posh-git -Scope CurrentUser -Force
winget install JanDeDobbeleer.OhMyPosh -s winget
oh-my-posh font install Meslo

. "$PSScriptRoot/Modules/install_settingsrepo.ps1"
SettingsRepo-Restore All

. "$PSScriptRoot/Modules/install_psreadline.ps1"

Write-Host "Press Enter to close"
Read-Host
