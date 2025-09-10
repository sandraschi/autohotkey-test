#Requires AutoHotkey v2.0+
; Enhanced AutoHotkey v2 Scripts for Claude Desktop MCP Development
; Version 2.0 - Extended and Improved
; Compatible with AutoHotkey v2.0+

; =============================================================================
; CONFIGURATION & GLOBALS
; =============================================================================

; Global configuration
REPOS_DIR := "D:\Dev\repos"
CLAUDE_CONFIG := "C:\Users\sandr\AppData\Roaming\Claude\claude_desktop_config.json"
CLAUDE_LOGS := "C:\Users\sandr\AppData\Roaming\Claude\logs\"
CLAUDE_EXE := "C:\Users\sandr\AppData\Local\AnthropicClaude\app-0.12.129\claude.exe"
PYTHON_EXE := "C:\Users\sandr\AppData\Local\Programs\Python\Python313\python.exe"
TEMP_DIR := "C:\temp\"

; Status tracking
global LastOperation := ""
global OperationTime := ""

; =============================================================================
; UTILITY FUNCTIONS
; =============================================================================

; Operation logging function
LogOperation(operation) {
    global LastOperation, OperationTime
    LastOperation := operation
    OperationTime := A_Now
    
    ; Optional: Write to log file
    try {
        FileAppend A_Now . " - " . operation . "`n", TEMP_DIR . "ahk_operations.log"
    }
    catch {
        ; Ignore logging errors
    }
}

; Helper function to send message to Claude (if active)
SendClaudeMessage(message) {
    try {
        WinActivate "Claude"
        Sleep 500
        SendText message
        Send "{Enter}"
    }
    catch {
        ; Ignore if Claude not active
    }
}

; Status display function
ShowStatus() {
    global LastOperation, OperationTime
    
    status := "Last Operation: " . LastOperation
    if (OperationTime != "")
        status .= "`nTime: " . OperationTime
    
    TrayTip "MCP Development Status", status, 3
}