$ProfilePath = $Profile.CurrentUserAllHosts
$BackupPath = "$PSScriptRoot/Powershell/profile.ps1"
$StartToken = "#region https://github.com/westryank/SetupPC"
$EndToken = "#endregion https://github.com/westryank/SetupPC"

Function Backup {
    if (Test-Path $ProfilePath) {
        $ProfileContent = Get-Content $ProfilePath -Raw
        $StartIndex = $ProfileContent.IndexOf($StartToken)
        $EndIndex = $ProfileContent.IndexOf($EndToken)
        if ($StartIndex -ne -1 -and $EndIndex -ne -1) {
            $BackedUpProfileContent = $ProfileContent.SubString($StartIndex + $StartToken.Length, $EndIndex - $StartIndex - $StartToken.Length)
        }
    }
    Set-Content $BackedUpProfileContent.Trim() -Path $BackupPath
}

Function Restore {
    if (-not (Test-Path $ProfilePath)) {
        New-Item -ItemType File -Path $ProfilePath -Force
    }
    $BackupContent = ""
    if (Test-Path $BackupPath) {
        $BackupContent = Get-Content $BackupPath -Raw
    }

    $ProfileContent = Get-Content $ProfilePath -Raw
    if ($ProfileContent -eq $null) {
        $ProfileContent = ""
    }
    $StartIndex = $ProfileContent.IndexOf($StartToken)
    $EndIndex = $ProfileContent.IndexOf($EndToken)
    if ($StartIndex -ne -1 -and $EndIndex -ne -1) {
        $ProfileContentBefore = $ProfileContent.SubString(0, $StartIndex)
        $ProfileContentAfter = $ProfileContent.SubString($EndIndex + $EndToken.Length, $ProfileContent.Length - $EndIndex - $EndToken.Length)
    }
    else {
        $ProfileContentBefore = $ProfileContent
        $ProfileContentAfter = ""
    }

    $NewProfileContent = "$($ProfileContentBefore.Trim())`n$StartToken`n$($BackupContent.Trim())`n$EndToken`n$($ProfileContentAfter.Trim())"
    Set-Content $NewProfileContent -Path $ProfilePath
}
