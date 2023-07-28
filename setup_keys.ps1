# https://docs.google.com/spreadsheets/d/1GSj0gKDxyWAecB3SIyEZ2ssPETZkkxn67gdIwL1zFUs/edit#gid=0
# https://isenselabs.com/posts/keyboard-key-kills-and-remaps-for-windows-users

# Remaps from one key to another at the system level

$CapsLock = "3A,00"
$PageDown = "51,00"

$Remappings = @{
    $CapsLock = $PageDown;
}

$RemapRemappingsString = ""
$Remappings.Keys | Foreach-Object { $RemapRemappingsString += "$($Remappings[$_]),$_," }

$RemapHeaderString = "00," * 8
$RemapCountString = "{0:X2}," -f ($Remappings.Count + 1)
$RemapEmptySpotString = "00," * 3
$RemapTerminatorString = "00," * 4
$RemapTerminatorString = $RemapTerminatorString.SubString(0, $RemapTerminatorString.Length - 1)

$RemapString = $RemapHeaderString + $RemapCountString + $RemapEmptySpotString + $RemapRemappingsString + $RemapTerminatorString
$RemapBytes = $RemapString.Split(",") | % { "0x$_" }

$RegistryPath = "HKLM:/System/CurrentControlSet/Control/Keyboard Layout"
New-ItemProperty -Path $RegistryPath -Name "Scancode Map" -PropertyType Binary -Value ([byte[]]$RemapBytes) -Force
