#Requires -RunAsAdministrator

function PromptInstall { param( [String] $Name, [ScriptBlock] $InstallBlock)
    if ((Read-Host "Install ${Name}? (Y/N)") -like "y*") {
        Write-Host "Installing $Name"
        $InstallBlock.Invoke()
    }
}

function DoIfNew { param ( $Name, $At, [scriptblock] $block)
    $Path = "$At/$Name"
    if (!(Test-Path $Path)) {
        $block.Invoke()
    }
    else {
        Write-Host "'$Path' already exists"
    }
    return $Path
}

function PinToQuickAccess { param($FolderPath)
    $o = New-Object -com Shell.Application
    $o.Namespace($FolderPath).Self.InvokeVerb("PinToHome")
}


Write-Host "Installing Applications"
PromptInstall "NeoVim" {
    winget install -e --id Neovim.Neovim
}
PromptInstall "Git" {
    winget install -e --id Git.Git
}
PromptInstall "Powershell" {
    winget install -e --id Microsoft.PowerShell
}
PromptInstall "Windows Terminal" {
    winget install -e --id Microsoft.WindowsTerminal
}
PromptInstall "PowerToys" {
    winget install -e --id Microsoft.PowerToys
}
PromptInstall "AutoHotKey" {
    winget install -e --id AutoHotkey.AutoHotkey
}
PromptInstall "Chrome" {
    winget install -e --id Google.Chrome
}
PromptInstall "Spotify" {
    winget install -e --id Spotify.Spotify
}
PromptInstall "1Password" {
    winget install -e --id AgileBits.1Password
}
PromptInstall "Steam" {
    winget install -e --id Valve.Steam
}
PromptInstall "Epic Games Launcher" {
    winget install -e --id EpicGames.EpicGamesLauncher
}
PromptInstall "Minecraft Launcher" {
    winget install -e --id Mojang.MinecraftLauncher
}

$reposdir = DoIfNew -Name repos -At $env:HomeDrive { mkdir $Path }
$westdir = DoIfNew -Name westryank -At "$env:HomeDrive/Users" { New-Item -ItemType junction -Name $Name -Path $At -Target $env:UserProfile }
$null = DoIfNew -Name repos -At $westdir { New-Item -ItemType junction -Name $Name -Path $At -Target $reposdir }

Write-Host "Downloading settings files from git repo"
$setupdir = "$env:HomeDrive/repos/setup"
if (Test-Path $setupdir) {
    rm $setupdir -recurse -force
}
git clone https://github.com/WestRyanK/SetupPC $setupdir
Get-ChildItem -Recurse -Path "$setupdir" -Force | Set-Acl -AclObject (Get-Acl "$Home/Documents")
Set-Acl "$setupdir" -AclObject (Get-Acl "$Home/Documents")

Write-Host "Setting Windows to Dark Mode"
Set-ItemProperty -Path HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize -Name AppsUseLightTheme -Value 0 -Type Dword -Force
Set-ItemProperty -Path HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize -Name SystemUsesLightTheme -Value 0 -Type Dword -Force

Write-Host "Restoring Explorer Settings"
Set-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer -Name ShowFrequent -Value 0 -Type Dword -Force # Hide Frequent Folders in Quick Access
Set-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer -Name ShowRecent -Value 0 -Type Dword -Force # Hide Recently used Files and Folders in Explorer
Set-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer -Name ShowCloudFilesInQuickAccess -Value 0 -Type Dword -Force # Hide Office Files in Quick Access
Set-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced -Name HideFileExt -Value 0 -Type Dword -Force # Show Extensions for Known File Types
Set-ItemProperty -Path HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced -Name Hidden -Value 1 -Type Dword -Force # Show Hidden Files and Folders

Write-Host "Running PowershellV7-Specific Setup"
# This script was most likely run from PowershellV1. To install Posh-Git for PowershellV7, it must be run from V7. So we run it for each version of powershell.
start pwsh -ArgumentList "-c $setupdir/setup_powershellv7.ps1"

PinToQuickAccess $westdir.Replace("/","\")
PinToQuickAccess $reposdir.Replace("/","\")

Write-Host "Rebinding some keyboard keys"
. "$setupdir/setup_keyboard.ps1"

Write-Host "Setup complete."
Write-Host "Please restart your computer."
Read-Host "Press Enter to Continue"
