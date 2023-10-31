#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
#SingleInstance Force
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
DetectHiddenWindows, On

#Include <dual/dual>
dual := new Dual
; #Include <dual/defaults>
 
; # Windows
; ! Alt
; ^ Ctrl
; + Shift

#If true ; Override defaults.ahk. There will be "duplicate hotkey" errors otherwise.

*h::dual.comboKey({F22: "Left"})
*j::dual.comboKey({F22: "Down"})
*k::dual.comboKey({F22: "Up"})
*l::dual.comboKey({F22: "Right"})

*0::dual.comboKey({F22: "Home"})
*u::dual.comboKey({F22: "PgUp"})
*i::dual.comboKey({F22: "PgDn"})
*4::dual.comboKey({F22: "End"})

*Space::
*Space UP::dual.combine("F22", A_ThisHotkey, {delay: 50, timeout: 300, doublePress: -1})

*BackSpace::dual.comboKey({F22: "Delete"})
*b::dual.comboKey({F22: "Space"})
*e::dual.comboKey({F22: "Escape"})

#+`:: 
Run *RunAs wt.exe
return

#If

; Only launch a new quake terminal if Terminal executable doesn't exist
#IfWinNotExist ahk_exe WindowsTerminal.exe
#`::
Run wt.exe -w _quake
return
#If