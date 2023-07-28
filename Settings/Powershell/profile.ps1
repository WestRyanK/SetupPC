Import-Module posh-git
Import-Module SettingsRepo -DisableNameChecking
Set-PSReadLineKeyHandler -Chord 'Ctrl+j' -Function NextHistory
Set-PSReadLineKeyHandler -Chord 'Ctrl+k' -Function PreviousHistory
# Use CapsLock for prediction completion when CapsLock is bound to PageDown with Registry Tweak
Set-PSReadLineKeyHandler -Chord 'PageDown' -Function ForwardChar 
oh-my-posh init pwsh --config "$home/.oh_my_posh.omp.json" | iex
