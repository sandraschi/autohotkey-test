#NoEnv
#SingleInstance Force
SendMode Input
SetWorkingDir %A_ScriptDir%

; Lock Workstation
#L::DllCall("LockWorkStation")

; Quick Shutdown/Restart/Logoff
^!+s::Shutdown, 1  ; Shutdown (Power off)
^!+r::Shutdown, 2  ; Reboot
^!+l::Shutdown, 0  ; Logoff
^!+h::Shutdown, 5  ; Hibernate
^!+x::Shutdown, 4  ; Suspend

; Toggle Hidden Files
^!h::  ; Ctrl+Alt+H
    RegRead, HiddenFiles_Status, HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced, Hidden
    if HiddenFiles_Status = 2
        RegWrite, REG_DWORD, HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced, Hidden, 1
    else
        RegWrite, REG_DWORD, HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced, Hidden, 2
    Send, {F5}
return

; Empty Recycle Bin
^!+e::  ; Ctrl+Alt+Shift+E
    FileRecycleEmpty, C:\
    MsgBox, Recycle Bin has been emptied.
return
