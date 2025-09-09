#NoEnv
#SingleInstance Force
SendMode Input
SetWorkingDir %A_ScriptDir%

; Launch Applications with Win+[Key]
#n::Run notepad.exe  ; Win+N
#c::Run calc.exe     ; Win+C
#w::Run winword.exe  ; Win+W (Word)
#e::Run explorer.exe ; Win+E (File Explorer)
#f::Run firefox.exe  ; Win+F (Firefox)

; Quick Folders
^!d::  ; Ctrl+Alt+D for Downloads
    Run, %A_UserProfile%\Downloads
return

^!d::  ; Ctrl+Alt+D for Documents
    Run, %A_UserProfile%\Documents
return

; Quick Settings
^!i::  ; Ctrl+Alt+I for Internet Options
    Run, inetcpl.cpl
return
