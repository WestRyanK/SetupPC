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

# Use Tab for prediction completion and Capslock/Shift+Capslock to cycle options.
# Only works when Capslock is bound to the PageDown key with Registry Tweak
Remove-PSReadLineKeyHandler -Chord 'Shift+Tab'
Set-PSReadLineKeyHandler -Chord 'Tab' -Function ForwardChar
Set-PSReadLineKeyHandler -Chord 'PageDown' -Function TabCompleteNext
Set-PSReadLineKeyHandler -Chord 'PageDown' -Function ViTabCompleteNext
Set-PSReadLineKeyHandler -Chord 'Shift+PageDown' -Function TabCompletePrevious
Set-PSReadLineKeyHandler -Chord 'Shift+PageDown' -Function ViTabCompletePrevious

oh-my-posh init pwsh --config "$home/.oh_my_posh.omp.json" | iex

function Start-VsDevShell {
    & 'C:\Program Files\Microsoft Visual Studio\2022\Enterprise\Common7\Tools\Launch-VsDevShell.ps1' -SkipAutomaticLocation
}

function git-PushNew {
    $branch = (Get-GitStatus).Branch
    git push --set-upstream origin ${branch}:dev/rwest/$branch
}
Set-Alias gitp git-PushNew

function git-DeleteBranch {
    param(
        $branchName,
        [switch] $force
        )
    if ($force) {
        git branch -D $branchName
    }
    else {
        git branch -d $branchName
    }
    if ($LASTEXITCODE -eq 0) {
        git push -d origin dev/rwest/$branchName
    }
}
Set-Alias gitd git-DeleteBranch

function git-OpenModified {
    $vsPath = "C:\Program Files\Microsoft Visual Studio\2022\Enterprise\Common7\IDE\devenv.exe"
    git-Status | Foreach-Object {
        Start $vsPath -ArgumentList "/edit $($_.Name)"
        Start-Sleep 2
    }
}
Set-Alias gito git-OpenModified

function git-Status {
    $statusString = git status --porcelain 
    $statusObjects = $statusString | Select-Object @{ 
            Name = 'Status'; 
            Expression = { $_.Substring(0, 1) } 
        }, 
        @{
            Name = 'Status2'; 
            Expression = { $_.Substring(1, 1) } 
        }, 
        @{ 
            Name = 'Name'; 
            Expression = { $_.Substring(3) } 
        }
    return $statusObjects
}
Set-Alias gits git-Status

function MakeChange-Directory {
    param(
        [string] $Path
        )
    mkdir $Path
    cd $Path
}
Set-Alias mkcd MakeChange-Directory
