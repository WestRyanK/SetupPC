﻿#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
#SingleInstance Force
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.


#^`::
Run wt.exe -w _quake
return

#+`:: 
Run *RunAs wt.exe
return

; Vimmy Movement Everywhere!
!j::
Send {Down}
return

!k::
Send {Up}
return

!h::
Send {Left}
return

!l::
Send {Right}
return