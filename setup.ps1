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

#$shell = New-Object -comObject WScript.Shell
#DoIfNew "Terminal.lnk" -At $westdir {
#    $shortcut = $shell.CreateShortcut($Path)
#    $shortcut.TargetPath = "$env:LocalAppData/Microsoft/WindowsApps/wt.exe"
#    $shortcut.Arguments = "-w _quake"
#    $shortcut.WorkingDirectory = $westdir
#    $shortcut.Hotkey = "CTRL+ALT+``"
#    $shortcut.Save()
#}
#
#DoIfNew "AdminTerminal.lnk" -At $westdir {
#    $shortcut = $shell.CreateShortcut($Path)
#    $shortcut.TargetPath = "$env:LocalAppData/Microsoft/WindowsApps/wt.exe"
#    $shortcut.Arguments = "-w _quake"
#    $shortcut.WorkingDirectory = $westdir
#    $shortcut.Hotkey = "CTRL+ALT+1"
#    $shortcut.Save()
#
#    Write-Host "Scripts can't easily set a Shortcut to Run as Administrator. So you'll have to do that yourself"
#    $selectPath = "$westdir\$Name".Replace('/', '\')
#    Start explorer.exe -ArgumentList "/select,$selectPath"
#    Write-Host "Once you've changed the shortcut properties, press 'Enter'"
#    Read-Host
#}

# Set Windows to Dark Mode
Set-ItemProperty -Path HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize -Name AppsUseLightTheme -Value 0 -Type Dword -Force; 
Set-ItemProperty -Path HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize -Name SystemUsesLightTheme -Value 0 -Type Dword -Force;
