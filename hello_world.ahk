; AutoHotkey v2 Script
; Simple Hello World example
; Created: 2025-09-08

#Requires AutoHotkey v2.0
#SingleInstance Force
#Warn

; Set the title of the script
A_Clipboard := ""  ; Empty the clipboard
SetWorkingDir A_ScriptDir  ; Ensures a consistent starting directory

; Create a simple GUI window with a message
MyGui := Gui(, "Hello World Example")
MyGui.Add("Text", "w300", "Hello, World! This is an AutoHotkey v2 script.")
MyGui.Add("Button", "Default", "OK").OnEvent("Click", (*) => ExitApp())
MyGui.Show("w320 h120")

; A simple hotkey that shows a message box when Win+H is pressed
#h:: {
    MsgBox "Hello, World!`nThis is a message from your AutoHotkey script.", "Greetings"
}

; Display a tooltip when the script starts
ToolTip "AutoHotkey Script is Running!`nPress Win+H to test", 100, 100
SetTimer () => ToolTip(), -3000  ; Remove the tooltip after 3 seconds

; Function to handle script exit
OnExit(ExitReason, ExitCode) {
    if (ExitReason = "Exit") {
        MsgBox "Goodbye! Thanks for using this script.", "Farewell"
    }
    return 0  ; Call the default exit routine
}
