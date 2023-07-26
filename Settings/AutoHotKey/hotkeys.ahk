#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.


#^`::
Run wt.exe -w _quake
return

#+`:: 
Run *RunAs wt.exe
return

;#IfWinActive ahk_exe WindowsTerminal.exe
CapsLock::
Send, {Right}
return
