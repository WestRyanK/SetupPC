Function Remove-Settings { param([String] $Name)

    $FolderToCommit = Get-SettingsFolder $Name
    if (Test-Path $FolderToCommit) {
        Remove-Item $FolderToCommit -Recurse
    }
}

Function Commit-Settings { param([String] $Name)

    $FolderToCommit = Get-SettingsFolder $Name
    git reset 
    $ChangeCount = (git status --porcelain | Where-Object { $_ -Like "* $FolderToCommit/*" }).Count
    if ($ChangeCount -gt 0) {
        git add $FolderToCommit
        git commit -m "** Commit $Name Settings**"
        git push
    }
}

Function Get-SettingsFolder { param([String] $Name)

    return "Settings/$Name"
}

Function Backup-Settings { param(
                                [Parameter(Mandatory)]
                                [ValidateSet("PowerToys", "Powershell", "Terminal")]
                                [String] $Name)

    . "$PSScriptRoot/Settings/$Name.ps1"
    Remove-Settings $Name
    $null = New-Item -ItemType Directory -Path (Get-SettingsFolder $Name) -Force
    Backup 
    Commit-Settings $Name
}

Function Restore-Settings { param(
                                [Parameter(Mandatory)]
                                [ValidateSet("PowerToys", "Powershell", "Terminal")]
                                [String] $Name)

    . "$PSScriptRoot/Settings/$Name.ps1"
    Restore 
}

