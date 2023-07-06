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



#Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
#choco install vim -y
#choco install git -y
#choco install powershell-core -y
#choco install microsoft-windows-terminal -y
choco install autohotkey -y

$repodir = DoIfNew repos -At $env:HomeDrive {
    mkdir $Path
}

$westdir = DoIfNew westryank -At "$env:HomeDrive/Users" {
    New-Item -ItemType junction -Name $Name -Path $At -Target $env:UserProfile
}

DoIfNew repos -At $westdir {
    New-Item -ItemType junction -Name $Name -Path $At -Target $repodir
}

# Download settings files from git repo and copy to home directory
$setupdir = "$env:HomeDrive/repos/setup"
$setuphomedir = "$setupdir/homedir"
git clone --depth 1 https://github.com/WestRyanK/SetupPC $setupdir
Get-ChildItem $setuphomedir |
Foreach-Object {
    $null = DoIfNew -Name $_.Name -At $westdir {
        mv $_ $westdir
    }
}

# Set Windows to Dark Mode
Set-ItemProperty -Path HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize -Name AppsUseLightTheme -Value 0 -Type Dword -Force; 
Set-ItemProperty -Path HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize -Name SystemUsesLightTheme -Value 0 -Type Dword -Force;

rm -recurse -force $setupdir
