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
    
    Set-PSReadLineOption -BellStyle visual
    
# Use Tab for prediction completion and Capslock/Shift+Capslock to cycle options.
# Only works when Capslock is bound to the PageDown key with Registry Tweak
    Remove-PSReadLineKeyHandler -Chord 'Shift+Tab'
    Set-PSReadLineKeyHandler -Chord 'Tab' -Function ForwardChar
    Set-PSReadLineKeyHandler -Chord 'PageDown' -Function TabCompleteNext
    Set-PSReadLineKeyHandler -Chord 'Shift+PageDown' -Function TabCompletePrevious

    oh-my-posh init pwsh --config "$home/.oh_my_posh.omp.json" | iex
} 
# End Interactive

function Start-VsDevShell {
    if ((Get-Command "msbuild" -ErrorAction SilentlyContinue) -eq $null) {
        & 'C:\Program Files\Microsoft Visual Studio\2022\Enterprise\Common7\Tools\Launch-VsDevShell.ps1' -SkipAutomaticLocation
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

function Enter-NewDirectory {
    param(
        [string] $Path
        )
    mkdir $Path
    cd $Path
}
Set-Alias mkcd Enter-NewDirectory

function Git-CloseAndClean {
    $processes = Get-Process -name devenv -ErrorAction SilentlyContinue
    $processes | Foreach-Object { $_.CloseMainWindow() }
    $processes | Wait-Process
    # git clean -X leaves untracked files while -x deletes untracked files. I've burned myself several times by accidentally deleting new untracked files with -x
    git clean -Xfd
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

function Enter-GraphicsRepo {
    Set-Location C:/repos/Graphics
}
Set-Alias repog Enter-GraphicsRepo

function Start-Chrome {
    $Address = ($args -Join " ")
    $shortcuts = @{
        "tfs" = "https://tfs.novarad.net/tfs/defaultcollection/Novarad";
        "gmail" = "https://gmail.com"
    }
    if ($shortcuts.Contains($Address)) {
        $Address = $shortcuts[$Address]
    }
    if ($Address -NotLike "*.*") {
        $Address = $Address.Replace(" ", "+")
        $Address = "google.com/search?q=$Address"
        Write-Host "Is search: $Address"
    }
    Start-Process "C:\Program Files\Google\Chrome\Application\chrome.exe" -ArgumentList "$Address"
}
Set-Alias cr Start-Chrome
