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
choco install vim -y
choco install git -y
choco install powershell-core -y
choco install microsoft-windows-terminal -y
choco install autohotkey -y
choco install powertoys -y
choco install googlechrome -y

# Reload environment variables so git will work
Import-Module $env:ChocolateyInstall\helpers\chocolateyProfile.psm1
refreshenv

$reposdir = DoIfNew -Name repos -At $env:HomeDrive { mkdir $Path }
$westdir = DoIfNew -Name westryank -At "$env:HomeDrive/Users" { New-Item -ItemType junction -Name $Name -Path $At -Target $env:UserProfile }
$null = DoIfNew -Name repos -At $westdir { New-Item -ItemType junction -Name $Name -Path $At -Target $reposdir }

# Download settings files from git repo and copy to home directory
$setupdir = "$env:HomeDrive/repos/setup"
$setuphomedir = "$setupdir/homedir"
git clone --depth 1 https://github.com/WestRyanK/SetupPC $setupdir
Get-ChildItem $setuphomedir | Foreach-Object {
    $null = DoIfNew -Name $_.Name -At $westdir { mv $_.FullName $westdir }
}

# Shortcut to run AutoHotKey script on Startup
$null = CreateShortcutIfNew -ShortcutName hotkeys.lnk -ShortcutPath "$env:AppData/Microsoft/Windows/Start Menu/Programs/Startup" -TargetPath "$westdir/hotkeys.ahk"

# Set Windows to Dark Mode
Set-ItemProperty -Path HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize -Name AppsUseLightTheme -Value 0 -Type Dword -Force; 
Set-ItemProperty -Path HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize -Name SystemUsesLightTheme -Value 0 -Type Dword -Force;

# Install PoshGit
PowerShellGet\Install-Module posh-git -Scope CurrentUser -Force
Add-PoshGitToProfile -AllUsers -AllHosts 
start pwsh -ArgumentList "-c PowerShellGet\Install-Module posh-git -Scope CurrentUser -Force; Add-PoshGitToProfile -AllUsers -AllHosts"

PinToQuickAccess $westdir.Replace("/","\")
PinToQuickAccess $reposdir.Replace("/","\")

rm -recurse -force $setupdir

Write-Host "Setup complete."
Write-Host "Please restart your computer."
