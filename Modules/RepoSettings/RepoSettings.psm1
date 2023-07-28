$AllRepoSettings = ("AutoHotKey", "OhMyPosh", "PowerToys", "Powershell", "Terminal", "Vim")
$RepoSettingsRoot = "C:/repos/setup/Settings"

Function RepoSettings-Restore {
    param(
        [ValidateSet("All", "AutoHotKey", "OhMyPosh", "PowerToys", "Powershell", "Terminal", "Vim")] 
            [String] $Name
    )

    $Names = $Name
    if ($Name -eq "All" -or $Name -eq '') {
        $Names = $AllRepoSettings
    }
    $Names | Foreach-Object {
        Write-Host "Restoring $_..."
        . "$RepoSettingsRoot/$_.ps1"
        Restore
    }
}

Function RepoSettings-Add {
    param(
        [ValidateSet("All", "AutoHotKey", "OhMyPosh", "PowerToys", "Powershell", "Terminal", "Vim")]
            [String] $Name
    )

    $Names = $Name
    if ($Name -eq "All" -or $Name -eq '') {
        $Names = $AllRepoSettings
    }
    $Names | Foreach-Object {
        Write-Host "Adding $_ to repo..."
        
        $RepoSettingsPath = "$RepoSettingsRoot/$_"
        if (Test-Path $RepoSettingsPath) {
            Remove-Item "$RepoSettingsPath" -Recurse
        }
        $null = New-Item -ItemType Directory -Path "$RepoSettingsPath" -Force
        . "$RepoSettingsRoot/$_.ps1"
        Backup
    }
    RepoSettings-Status
}

Function RepoSettings-Status {
    $ChangedFiles = (git -C "$RepoSettingsRoot" status --short)
    if ($ChangedFiles) {
        Write-Host "The following settings have changed:"
        Write-Host $ChangedFiles
    }
    else {
        Write-Host "No settings have changed"
    }
}

Function RepoSettings-Diff {
    git -C "$RepoSettingsRoot" diff
}

Function RepoSettings-Reset {
    git -C "$RepoSettingsRoot" reset head --hard
}

Function RepoSettings-Commit {
    param(
        [ValidateSet("All", "AutoHotKey", "OhMyPosh", "PowerToys", "Powershell", "Terminal", "Vim")]
            [String] $Name,
            [String] $Message
    )

    git -C "$RepoSettingsRoot" reset
    $Names = $Name
    if ($Name -eq "All" -or $Name -eq '') {
        $Names = $AllRepoSettings
    }
    $ChangeCount = 0
    $Names | Foreach-Object {
        $RepoSettingsPath = "$RepoSettingsRoot/$_"
        $ChangeCount += (git -C "$RepoSettingsRoot" status --porcelain | Where-Object { $_ -Like "* $RepoSettingsPath/*" }).Count
        git -C "$RepoSettingsRoot" add $RepoSettingsPath
    }
    if ($ChangeCount -gt 0) {
        if (-not $Message) {
            $CommitMessage = "**Backup $Name Settings**"
        }
        else {
            $CommitMessage = "**Backup ${Name}: $Message**"
        }
        git -C "$RepoSettingsRoot" commit -m "$CommitMessage"
        git -C "$RepoSettingsRoot" push
    }
}
