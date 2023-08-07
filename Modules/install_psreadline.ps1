Write-Host "Ryan forked PSReadLine and added the ability to copy and paste to the system clipboard using Vim mode."
$installAnswer = Read-Host "Do you want to install it? (y/n)"
if ($installAnswer -ne "y") {
    return
}

$PsReadLineDir = "$env:HomeDrive/repos/PSReadLine"
Push-Location $PSReadLineDir
git clone --depth 1 https://github.com/WestRyanK/PSReadLine --branch ViSystemClipboard

./build.ps1 -Bootstrap
./build.ps1 -Configuration Release -Framework net462
Copy-Item -Path "bin/Release/PSReadLine" -Destination "$Home/Documents/PowerShell/Modules" -Recurse -Force
Pop-Location
Write-Host "You must restart PowerShell to load PSReadLine"


