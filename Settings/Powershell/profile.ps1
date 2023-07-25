Import-Module posh-git
$GitPromptSettings.DefaultPromptAbbreviateHomeDirectory = $true
$GitPromptSettings.DefaultPromptPrefix.Text = "---------------------------------------`n$($GitPromptSettings.DefaultPromptPrefix.Text)"
Set-PSReadLineKeyHandler -Chord 'Ctrl+j' -Function NextHistory
Set-PSReadLineKeyHandler -Chord 'Ctrl+k' -Function PreviousHistory
