. ./commit_settings_utils.ps1

$SettingsName = "Terminal"
$SettingsFolder = Get-SettingsFolder $SettingsName

Remove-Settings $SettingsName
New-Item -ItemType Directory -Path $SettingsFolder
Copy-Item -Path "$env:LocalAppData/Packages/Microsoft.WindowsTerminal_8wekyb3d8bbwe/LocalState/settings.json" -Destination $SettingsFolder
Commit-Settings $SettingsName
