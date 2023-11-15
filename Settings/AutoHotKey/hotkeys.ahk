#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
#SingleInstance Force
; #Warn  ; Enable warnings to assist with detecting common errors.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
DetectHiddenWindows, On
 
; # Windows
; ! Alt
; ^ Ctrl
; + Shift
; ` Escapes special characters like semicolon (or can just represent the ` key itself. confusing...)


#+`:: 
    Run *RunAs wt.exe
    return

; Only launch a new quake terminal if Terminal executable doesn't exist
#IfWinNotExist ahk_exe WindowsTerminal.exe
    #`::
        Run wt.exe -w _quake
        return
#If

#If LayerOn
    h::Left
    j::Down
    k::Up
    l::Right
    x::Delete
    X::Backspace
    n::Home
    m::End
#If

CancelKey := false
LayerOn := false
$`;::
    LayerOn := true
    KeyWait, `;, T.15
    if (ErrorLevel == 0) {
        Send {`;}
    }
    KeyWait, `;
    LayerOn := false
    return