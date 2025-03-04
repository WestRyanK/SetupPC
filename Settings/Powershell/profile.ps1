function Test-Interactive {
    $commandArgs = [Environment]::GetCommandLineArgs()
    $hasNonInteractiveArgs = $commandArgs | Where-Object { ($_ -ilike "-NonI*") }
    # $hasNonInteractiveArgs = $commandArgs | Where-Object { ($_ -ilike "-NonI*") -or ($_ -ilike "-Com*") }
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
    Set-PSReadLineKeyHandler -Chord 'F24' -Function TabCompleteNext
    Set-PSReadLineKeyHandler -Chord 'Shift+F24' -Function TabCompletePrevious

    oh-my-posh init pwsh --config "$home/.oh_my_posh.omp.json" | iex
} 
# End Interactive


function Get-VsPath {
    if (!(Get-Command Get-VsSetupInstance -ErrorAction SilentlyContinue)) {
        Install-Module VSSetup -Scope CurrentUser
    }
     $Installation = Get-VSSetupInstance | Sort-Object -Property InstallationVersion -Descending | Select-Object -First 1
     return $Installation.InstallationPath
}

function Start-VsDevShell {
    $VsPath = Get-VsPath
    if ($null -eq $VsPath) {
        Write-Error "Visual Studio is not installed"
        return
    }
    $DevShellPath = [System.IO.Path]::Join($VsPath, "Common7", "Tools", "Launch-VsDevShell.ps1")

    & $DevShellPath -SkipAutomaticLocation
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

function Get-GitRemoteBranch {
    param([string] $BranchName)

    if ([string]::IsNullOrWhitespace($BranchName)) {
        $BranchName = (git status) | Where-Object { $_ -match "On branch (.+)" } | Foreach-Object { $Matches[1] }
    }

    $Prefix = "refs/heads/"
    $RemoteName = git config --get-regexp "branch\.$BranchName\.merge"
    if ($null -eq $RemoteName) {
        return $null
    }
    return $RemoteName.Substring($RemoteName.IndexOf($Prefix) + $Prefix.Length)
}

function Remove-GitRemoteBranch {
    param(
        $branchName
        )

    $RemoteName = Get-GitRemoteBranch $branchName
    if ($null -eq $RemoteName) {
        Write-Host "error: unable to delete '$branchName': remote ref does not exist"
        return
    }

    git push -d origin $remoteName
}

function Rename-GitLocalAndRemoteBranch {
    param(
    [Parameter(Mandatory=$true)] [string] $NewBranchName,
    [string] $OldBranchName
    )

    if ([string]::IsNullOrWhitespace($OldBranchName)) {
        $OldBranchName = (git status) | Where-Object { $_ -match "On branch (.+)" } | Foreach-Object { $Matches[1] }
    }

    git branch -m $OldBranchName $NewBranchName
    git push -d origin $OldBranchName
    git branch --unset-upstream $NewBranchName
    git push origin $NewBranchName
    git push origin -u $NewBranchName
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
    $files = (Get-GitStatusWorking) + (Get-GitStatusIndex)
    $files | Foreach-Object {
        Open-DevEnv $_
    }
}
Set-Alias ogs Open-GitStatus

function Open-DevEnv {
    param(
        [string] $Path
        )

    $VsPath = Get-VsPath
    if ($null -eq $VsPath) {
        Write-Error "Visual Studio is not installed"
        return
    }
    $DevEnvPath = [System.IO.Path]::Join($VsPath, "Common7", "IDE", "devenv.exe")

    & $DevEnvPath /edit $Path
    Start-Sleep -Seconds 0.5
}

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

function Start-MyGitWatcher {
    Start-GitWatcher -Quake
}
Set-Alias gw Start-MyGitWatcher

function Invoke-GitRemoteUrl {
    Start-Process (git config --get remote.origin.url)
}

function Invoke-GitPullRequest {
    $OriginUrl = git config --get remote.origin.url
    $DefaultBranch = (git remote show origin) | Where-Object { $_ -match "HEAD branch\: (.+)" } | Foreach-Object { $Matches[1] }
    $RemoteBranch = [System.Web.HttpUtility]::UrlEncode( (Get-GitRemoteBranch) )
    if ($OriginUrl.Contains("_git")) {
        $PullRequestUrl = "${OriginUrl}/pullrequestcreate?sourceRef=${RemoteBranch}&targetRef=${DefaultBranch}"
    }
    elseif ($OriginUrl.Contains("github")) {
        $OriginUrl = $OriginUrl.SubString(0, $OriginUrl.Length - 4)
        $PullRequestUrl = "${OriginUrl}/compare/${DefaultBranch}...${RemoteBranch}?quick_pull=1"
    }
    else {
        Write-Host "Cannot open pull request for '$OriginUrl'"
        return
    }

    Start-Process $PullRequestUrl
}

function Invoke-GitPullMain {
    $CurrentBranch = git branch --show-current
    if ($CurrentBranch -eq "main") {
        git pull
    }
    else {
        git fetch
        git branch -f main origin/main
    }
}

function Edit-Profile {
    vim $PROFILE.CurrentUserAllHosts
}

function Format-GitCommitMessage {
    param (
        [Parameter(Mandatory=$true, ValueFromPipeline=$true)] [string] $CommitMessage
    )
    begin {
        $AllCommitMessageLines = @()
    }
    process {
        $AllCommitMessageLines += $CommitMessage
    }
    end {
        if ($null -eq $env:OpenAi_Api_Key) {
            Write-Error "You must set the environment variable `"env:OpenAi_Api_Key`" before using this command."
        }

        $url = "https://api.openai.com/v1/chat/completions"

        $requestBody = @{
            model = "gpt-4o"
            messages = @(
                @{
                    role = "system"
                    content = "You are an AI that rewrites Git commit messages to be clear, and professional. Respond with a commit message title and body and nothing else. Do not label the title or body. Prefer paragraphs, but if you need to make a list use a hyphen character for bullet points."
                },
                @{
                    role = "user"
                    content = "Rewrite this Git commit message: $AllCommitMessageLines"
                }
            )
            temperature = 0.7
        } | ConvertTo-Json -Depth 10

        $headers = @{
            "Content-Type"  = "application/json"
            "Authorization" = "Bearer ${env:OpenAi_Api_Key}"
        }

        $response = Invoke-RestMethod -Uri $url -Method Post -Headers $headers -Body $requestBody
        return $response.choices[0].message.content
    }
}
