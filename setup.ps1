#Requires -RunAsAdministrator

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

function CreateShortcutIfNew { param ( $ShortcutName, $ShortcutPath, $TargetPath, $Arguments)
    DoIfNew $ShortcutName -At $ShortcutPath {
        $shell = New-Object -comObject WScript.Shell
        $shortcut = $shell.CreateShortcut($Path)
        $shortcut.TargetPath = $TargetPath
        $shortcut.Arguments = $Arguments
        $shortcut.Save()
    }
}

function PinToQuickAccess { param($FolderPath)
    $o = New-Object -com Shell.Application
    $o.Namespace($FolderPath).Self.InvokeVerb("PinToHome")
}



Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
Write-Host "Installing Applications"
choco install vim -y
choco install git -y
choco install powershell-core -y
choco install microsoft-windows-terminal -y
choco install autohotkey -y
choco install powertoys -y
choco install googlechrome -y
choco install spotify -y

Write-Host "Reloading environment variables so git will work"
Import-Module $env:ChocolateyInstall\helpers\chocolateyProfile.psm1
refreshenv

$reposdir = DoIfNew -Name repos -At $env:HomeDrive { mkdir $Path }
$westdir = DoIfNew -Name westryank -At "$env:HomeDrive/Users" { New-Item -ItemType junction -Name $Name -Path $At -Target $env:UserProfile }
$null = DoIfNew -Name repos -At $westdir { New-Item -ItemType junction -Name $Name -Path $At -Target $reposdir }

Write-Host "Downloading settings files from git repo and copying them to the home directory"
$setupdir = "$env:HomeDrive/repos/setup"
$setuphomedir = "$setupdir/homedir"
git clone --depth 1 https://github.com/WestRyanK/SetupPC $setupdir
Get-ChildItem $setuphomedir | Foreach-Object {
    $null = DoIfNew -Name $_.Name -At $westdir { mv $_.FullName $westdir }
}

Write-Host "Adding shortcut to run AutoHotKey script on Startup"
$null = CreateShortcutIfNew -ShortcutName hotkeys.lnk -ShortcutPath "$env:AppData/Microsoft/Windows/Start Menu/Programs/Startup" -TargetPath "$westdir/hotkeys.ahk"

Write-Host "Setting Windows to Dark Mode"
Set-ItemProperty -Path HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize -Name AppsUseLightTheme -Value 0 -Type Dword -Force; 
Set-ItemProperty -Path HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize -Name SystemUsesLightTheme -Value 0 -Type Dword -Force;

Write-Host "Install PoshGit"
# This script was most likely run from PowershellV1. To install Posh-Git for PowershellV7, it must be run from V7. So we run it for each version of powershell.
. $setupdir/setup_poshgit.ps1
start pwsh -ArgumentList "-c $setupdir/setup_poshgit.ps1"

PinToQuickAccess $westdir.Replace("/","\")
PinToQuickAccess $reposdir.Replace("/","\")

Write-Host "Installing 1Password"
$DownloadUrl = "https://downloads.1password.com/win/1PasswordSetup-latest.exe"
$DownloadPath = "$westdir/Downloads/install.exe"
Invoke-WebRequest -Uri $DownloadUrl -OutFile $DownloadPath
start $DownloadPath -wait


rm -recurse -force $setupdir

Write-Host "Setup complete."
Write-Host "Please restart your computer."

