PowerShellGet\Install-Module posh-git -Scope CurrentUser -Force

. "$PSScriptRoot/commit_settings.ps1"
Write-Host "Restoring Powershell Profile"
Restore-Settings Powershell
