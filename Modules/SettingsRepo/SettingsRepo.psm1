$AllSettings = ("AutoHotKey", "Git", "OhMyPosh", "PowerToys", "Powershell", "Terminal", "Vim")
$SettingsRepoRoot = "C:/repos/setup/Settings"

Function SettingsRepo-Restore {
    param(
        [ValidateSet("All", "AutoHotKey", "Git", "OhMyPosh", "PowerToys", "Powershell", "Terminal", "Vim")] 
            [String] $Name
    )

    $Names = $Name
    if ($Name -eq "All" -or $Name -eq '') {
        $Names = $AllSettings
        $Name = "All"
    }
    $Names | Foreach-Object {
        Write-Host "Restoring $_..."
        . "$SettingsRepoRoot/$_.ps1"
        Restore
    }
}

Function SettingsRepo-Add {
    param(
        [ValidateSet("All", "AutoHotKey", "Git", "OhMyPosh", "PowerToys", "Powershell", "Terminal", "Vim")]
            [String] $Name
    )

    $Names = $Name
    if ($Name -eq "All" -or $Name -eq '') {
        $Names = $AllSettings
        $Name = "All"
    }

    git -C "$SettingsRepoRoot" pull

    $Names | Foreach-Object {
        Write-Host "Adding $_ to repo..."
        
        $SettingsRepoPath = "$SettingsRepoRoot/$_"
        if (Test-Path $SettingsRepoPath) {
            Remove-Item "$SettingsRepoPath" -Recurse
        }
        $null = New-Item -ItemType Directory -Path "$SettingsRepoPath" -Force
        . "$SettingsRepoRoot/$_.ps1"
        Backup
    }
    SettingsRepo-Status
}

Function SettingsRepo-Status {
    $ChangedFiles = (git -C "$SettingsRepoRoot" status --short)
    if ($ChangedFiles) {
        Write-Host "The following settings have changed:"
        Write-Host $ChangedFiles
    }
    else {
        Write-Host "No settings have changed"
    }
}

Function SettingsRepo-Log {
    git -C "$SettingsRepoRoot" log --graph --oneline --all
}

Function SettingsRepo-Diff {
    git -C "$SettingsRepoRoot" diff
}

Function SettingsRepo-Reset {
    git -C "$SettingsRepoRoot" reset head --hard
}

Function SettingsRepo-Commit {
    param(
        [ValidateSet("All", "AutoHotKey", "Git", "OhMyPosh", "PowerToys", "Powershell", "Terminal", "Vim")]
            [String] $Name,
            [String] $Message
    )

    $null = git -C "$SettingsRepoRoot" reset
    $Names = $Name
    if ($Name -eq "All" -or $Name -eq '') {
        $Names = $AllSettings
        $Name = "All"
    }
    $ChangeCount = 0
    $Names | Foreach-Object {
        $IndividualName = $_
        $SettingsRepoPath = "$SettingsRepoRoot/$IndividualName"
        $ChangeCount += (git -C "$SettingsRepoRoot" status --porcelain | Where-Object { $_ -Like "* Settings/$IndividualName/*" }).Count
        git -C "$SettingsRepoRoot" add $SettingsRepoPath
    }
    if ($ChangeCount -gt 0) {
        if (-not $Message) {
            $CommitMessage = "**Backup $Name Settings**"
        }
        else {
            $CommitMessage = "**Backup ${Name}: $Message**"
        }
        git -C "$SettingsRepoRoot" commit -m "$CommitMessage"
        git -C "$SettingsRepoRoot" push
    }
}
