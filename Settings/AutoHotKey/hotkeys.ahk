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
    d::Delete
    n::Home
    m::End
#If

CancelKey := false
LayerOn := false
$`;::
    LayerOn := true
    KeyWait, `;, T.15
    if (ErrorLevel) {
    }
    else {
        Send {`;}
    }
    KeyWait, `;
    LayerOn := false
    return

; CancelSpace := false
; LayerOn := false
; $Space::
;     LayerOn := false
;     KeyWait, Space, T.15
;     if (ErrorLevel) {
;         LayerOn := true
;     }
;     else {
;         if (CancelSpace == false) {
;             Send {Space}
;         }
;         CancelSpace:=false
;         LayerOn := false
;         return
;     }
;     KeyWait, Space
;     LayerOn := false
;     return

; Fix(Letter) {
;     global CancelSpace
;     Send {Space}%Letter%
;     CancelSpace := true
; }

; #If LayerOn == false && GetKeyState("Space", "P") 
;     a::Fix("a")
;     b::Fix("b")
;     c::Fix("c")
;     d::Fix("d")
;     e::Fix("e")
;     f::Fix("f")
;     g::Fix("g")
;     h::Fix("h")
;     i::Fix("i")
;     j::Fix("j")
;     k::Fix("k")
;     l::Fix("l")
;     m::Fix("m")
;     n::Fix("n")
;     o::Fix("o")
;     p::Fix("p")
;     q::Fix("q")
;     r::Fix("r")
;     s::Fix("s")
;     t::Fix("t")
;     u::Fix("u")
;     v::Fix("v")
;     w::Fix("w")
;     x::Fix("x")
;     y::Fix("y")
;     z::Fix("z")
;     =::Fix("=")
;     -::Fix("-")
; #If