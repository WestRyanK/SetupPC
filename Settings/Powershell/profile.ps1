Import-Module posh-git
$GitPromptSettings.DefaultPromptAbbreviateHomeDirectory = $true
$GitPromptSettings.DefaultPromptPrefix.Text = "---------------------------------------`n$($GitPromptSettings.DefaultPromptPrefix.Text)"
