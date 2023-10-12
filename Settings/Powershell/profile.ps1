function Test-Interactive {
    $commandArgs = [Environment]::GetCommandLineArgs()
    $hasNonInteractiveArgs = $commandArgs | Where-Object { ($_ -ilike "-NonI*") -or ($_ -ilike "-Com*") }
    return [Environment]::UserInteractive -and !$hasNonInteractiveArgs
}
$interactive = Test-Interactive

# Start Interactive
if ($interactive) { 
    Set-Alias g git

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
} 
# End Interactive

function Start-VsDevShell {
    if (-not $script:vsDevShellLoaded) {
        & 'C:\Program Files\Microsoft Visual Studio\2022\Enterprise\Common7\Tools\Launch-VsDevShell.ps1' -SkipAutomaticLocation
        $script:vsDevShellLoaded = $true
    }
}

function Invoke-GitPushDev {
    param(
        [switch]$force
    )

    $forceString = $null
    if ($force) {
        $forceString = "-f"
    }

    $status = Get-GitStatus
    if ($status.Upstream -and !($status.UpstreamGone)) {
        git push $forceString
    }
    else {
        $branch = (Get-GitStatus).Branch
        git push --set-upstream origin ${branch}:dev/rwest/$branch
    }
}

function Remove-GitRemoteBranch {
    param(
        $branchName
        )

    if ($branchName -eq $null) {
        $branchName = (Get-GitStatus).Branch
    }

    $prefix = "refs/heads/"
    $remoteName = git config --get-regexp "branch\.$branchName\.merge"
    if ($remoteName -eq $null) {
        Write-Host "error: unable to delete '$branchName': remote ref does not exist"
        return
    }
    $remoteName = $remoteName.Substring($remoteName.IndexOf($prefix) + $prefix.Length)

    git push -d origin $remoteName
}

function Get-GitStatusWorking {
    return (Get-GitStatus).Working
}

function Get-GitStatusIndex {
    return (Get-GitStatus).Index
}
Set-Alias ggs Get-GitStatus
Set-Alias ggsw Get-GitStatusWorking
Set-Alias ggsi Get-GitStatusIndex

function Open-GitStatus {
    $vsPath = "C:\Program Files\Microsoft Visual Studio\2022\Enterprise\Common7\IDE\devenv.exe"
    $files = (Get-GitStatusWorking) + (Get-GitStatusIndex)
    $files | Foreach-Object {
        Start $vsPath -ArgumentList "/edit $_"
        Start-Sleep 1
    }
}
Set-Alias ogs Open-GitStatus

function MakeChange-Directory {
    param(
        [string] $Path
        )
    mkdir $Path
    cd $Path
}
Set-Alias mkcd MakeChange-Directory

function Git-CloseAndClean {
    Stop-Process -Name devenv -ErrorAction SilentlyContinue
    git clean -xfd
}

function Build-LocalNugetPackages {
    Start-VsDevShell
    Push-Location C:/repos/Graphics/
    Git-CloseAndClean
    msbuild -t:restore ./Analyzers.sln
    msbuild ./Analyzers.sln /p:Configuration=Release /p:CI=true
    Get-ChildItem -Recurse -Include "*.nupkg", "*.snupkg" | Foreach {
        cp $_ C:/local_nuget
    }
}

function Remove-CachedNovaradPackages {
    Get-ChildItem C:\Users\westryank\.nuget\packages -Filter "novarad*" | Foreach-Object {
        rm -recurse $_
    }
}
