# https://docs.google.com/spreadsheets/d/1GSj0gKDxyWAecB3SIyEZ2ssPETZkkxn67gdIwL1zFUs/edit#gid=0
# https://isenselabs.com/posts/keyboard-key-kills-and-remaps-for-windows-users
# https://download.microsoft.com/download/1/6/1/161ba512-40e2-4cc9-843a-923143f3456c/translate.pdf

# Remaps from one key to another at the system level

$CapsLock = "3A,00"
$PageDown = "51,E0"
$F24      = "76,00"

$Remappings = @{
    $CapsLock = $F24;
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
$null = New-ItemProperty -Path $RegistryPath -Name "Scancode Map" -PropertyType Binary -Value ([byte[]]$RemapBytes) -Force
