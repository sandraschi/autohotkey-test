#NoEnv
#SingleInstance Force
#IfWinActive ahk_exe code.exe  ; VS Code specific shortcuts

; Format Document
^!l::Send ^k^f

; Comment/Uncomment Line
^/::Send ^k^c
^+/::Send ^k^u

; Duplicate Line
^d::Send ^d

; Move Line Up/Down
!Up::Send !{Up}
!Down::Send !{Down}

; Find in Files
^+f::Send ^+f

; Toggle Terminal
^`::Send ^`

; Toggle Sidebar
^b::Send ^b

#IfWinActive

; For other IDEs, add similar blocks with #IfWinActive for each IDE's process name
