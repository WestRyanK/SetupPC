PowerShellGet\Install-Module posh-git -Scope CurrentUser -Force
Add-PoshGitToProfile -AllUsers -AllHosts 
'$GitPromptSettings.DefaultPromptAbbreviateHomeDirectory = $true' | Add-Content $PROFILE.AllUsersAllHosts
