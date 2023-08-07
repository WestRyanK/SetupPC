Import-Module posh-git
Import-Module SettingsRepo -DisableNameChecking
Set-Alias -Name vim -Value nvim
Set-Alias -Name vi -Value nvim

function OnViModeChange {
    if ($args[0] -eq 'Command') {
        # Set the cursor to a blinking block.
        Write-Host -NoNewLine "`e[1 q"
    } else {
        # Set the cursor to a blinking line.
        Write-Host -NoNewLine "`e[5 q"
    }
}
Set-PSReadLineOption -EditMode vi
Set-PSReadLineOption -ViModeIndicator Script -ViModeChangeHandler $Function:OnViModeChange
Set-PSReadLineOption -BellStyle visual
if ((Get-Module PSReadLine).PrivateData.PSData.PreRelease -ne $null) {
    Set-PSReadLineOption -ViClipboardMode SystemClipboard
}

# Use two quick presses of the 'j' key to exit Vim Insert mode in the PowerShell prompt
$LastJTime = $null
Set-PSReadLineKeyHandler -Chord j -ViMode Insert -ScriptBlock {
    $LastJTime = $script:LastJTime
    $script:LastJTime = Get-Date

    if ($LastJTime -eq $null) {
        $LastJTime = (Get-Date -Year 1 -Month 1 -Day 1)
    }

    $TimeSinceLastJ = New-TimeSpan -Start $LastJTime -End (Get-Date)

    if (($TimeSinceLastJ.TotalSeconds) -lt .25) {
        [Microsoft.PowerShell.PSConsoleReadLine]::BackwardDeleteChar()
        [Microsoft.PowerShell.PSConsoleReadLine]::ViCommandMode()
    }
    else {
        [Microsoft.PowerShell.PSConsoleReadLine]::Insert('j')
    }
}

# Use CapsLock for prediction completion when CapsLock is bound to PageDown with Registry Tweak
Set-PSReadLineKeyHandler -Chord 'PageDown' -Function ForwardChar
oh-my-posh init pwsh --config "$home/.oh_my_posh.omp.json" | iex
