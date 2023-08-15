Write-Host "Which version of Visual Studio do you want to install?"
Write-Host "(E)nterprise | (C)ommunity | (P)rofessional | (S)ettings Only | (N)one"
$VisualStudioVersion = Read-Host

if ($VisualStudioVersion -like "e*") {
    $VisualStudioVersion = "Enterprise"
}
elseif ($VisualStudioVersion -like "c*") {
    $VisualStudioVersion = "Community"
}
elseif ($VisualStudioVersion -like "p*") {
    $VisualStudioVersion = "Professional"
}
elseif ($VisualStudioVersion -like "s*") {
    $VisualStudioVersion = "Settings"
}
else {
    return
}

if ($VisualStudioVersion -ne "Settings") {
    winget install -e --id "Microsoft.VisualStudio.2022.$VisualStudioVersion"
}

Write-Host "Installing Navigate Tab Groups Extension for Visual Studio"
$DownloadUrl = "https://github.com/jagt/vs-NavigateTabGroups/releases/download/vs2022/TabGroupJump.vsix"
$DownloadPath = "$Home/Downloads/TabGroupJump.vsix"
Invoke-WebRequest -Uri $DownloadUrl -OutFile $DownloadPath
Start-Process $DownloadPath -wait
Remove-Item $DownloadPath

Write-Host "Installing VsVim Extension for Visual Studio"
$DownloadUrl = "https://marketplace.visualstudio.com/_apis/public/gallery/publishers/JaredParMSFT/vsextensions/VsVim/2.8.0.0/vspackage"
$DownloadPath = "$Home/Downloads/VsVim.vsix"
Invoke-WebRequest -Uri $DownloadUrl -OutFile $DownloadPath
Start-Process $DownloadPath -wait
Remove-Item $DownloadPath

