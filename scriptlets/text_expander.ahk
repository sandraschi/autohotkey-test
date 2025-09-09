#NoEnv
#SingleInstance Force
SendMode Input
SetWorkingDir %A_ScriptDir%

; Date and Time Shortcuts
::/now::
    FormatTime, CurrentDateTime,, yyyy-MM-dd HH:mm:ss
    SendInput %CurrentDateTime%
return

::/date::
    FormatTime, CurrentDate,, yyyy-MM-dd
    SendInput %CurrentDate%
return

::/time::
    FormatTime, CurrentTime,, HH:mm
    SendInput %CurrentTime%
return

; Common Responses
::;hi::
    SendInput Hello! How can I assist you today?
return

::;ty::
    SendInput Thank you!
return

::;br::
    SendInput Best regards,`n[Your Name]
return

; Email Templates
::;email::
    SendInput Dear ,`n`n`nBest regards,`n[Your Name]
    SendInput {Up 2}{End}{Left 2}
return
