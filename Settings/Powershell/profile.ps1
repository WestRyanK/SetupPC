Import-Module posh-git
Import-Module SettingsRepo -DisableNameChecking
Set-PSReadLineKeyHandler -Chord 'Ctrl+j' -Function NextHistory
Set-PSReadLineKeyHandler -Chord 'Ctrl+k' -Function PreviousHistory
oh-my-posh init pwsh --config "$home/.oh_my_posh.omp.json" | iex
