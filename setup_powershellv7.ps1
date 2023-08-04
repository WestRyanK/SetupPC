PowerShellGet\Install-Module posh-git -Scope CurrentUser -Force
winget install JanDeDobbeleer.OhMyPosh -s winget
oh-my-posh font install Meslo

. "$PSScriptRoot/install_modules.ps1"
SettingsRepo-Restore All

Write-Host "Press Enter to close"
Read-Host
