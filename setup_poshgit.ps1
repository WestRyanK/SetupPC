# These commands need to be run from the newly install Powershell v7

PowerShellGet\Install-Module posh-git -Scope CurrentUser -Force
winget install JanDeDobbeleer.OhMyPosh -s winget
oh-my-posh font install Meslo

. "$PSScriptRoot/commit_settings.ps1"
Write-Host "Restoring Powershell Profile"
Restore-Settings Powershell
Write-Host "Restoring Oh_My_Posh Settings"
Restore-Settings Oh_My_Posh
