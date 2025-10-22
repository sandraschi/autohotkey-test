; ==============================================================================
; AutoHotkey Debug Helper
; @name: AutoHotkey Debug Helper
; @version: 1.0.0
; @description: Helps debug AutoHotkey scriptlets by capturing and displaying errors
; @category: utilities
; @author: Sandra
; @hotkeys: ^!d, F4
; @enabled: true
; ==============================================================================

#Requires AutoHotkey v2.0+
#SingleInstance Force

class AutoHotkeyDebugger {
    static debugLog := []
    static logFile := A_ScriptDir . "\debug_log.txt"
    
    static LogError(scriptName, errorMsg, lineNumber := "") {
        timestamp := A_Now
        logEntry := "[" . timestamp . "] ERROR in " . scriptName
        if (lineNumber != "") {
            logEntry .= " at line " . lineNumber
        }
        logEntry .= ": " . errorMsg
        
        this.debugLog.Push(logEntry)
        this.WriteToFile(logEntry)
        
        ; Show error in GUI
        this.ShowErrorDialog(scriptName, errorMsg, lineNumber)
    }
    
    static LogInfo(message) {
        timestamp := A_Now
        logEntry := "[" . timestamp . "] INFO: " . message
        
        this.debugLog.Push(logEntry)
        this.WriteToFile(logEntry)
    }
    
    static WriteToFile(logEntry) {
        try {
            FileAppend(logEntry . "`n", this.logFile)
        } catch {
            ; If we can't write to file, at least show the error
            MsgBox("Debug log write failed: " . logEntry, "Debug Error", "Icon!")
        }
    }
    
    static ShowErrorDialog(scriptName, errorMsg, lineNumber := "") {
        errorText := "🚨 AUTOHOTKEY ERROR 🚨`n`n"
        errorText .= "Script: " . scriptName . "`n"
        if (lineNumber != "") {
            errorText .= "Line: " . lineNumber . "`n"
        }
        errorText .= "Error: " . errorMsg . "`n`n"
        errorText .= "This error has been logged to: " . this.logFile . "`n`n"
        errorText .= "Press OK to continue."
        
        MsgBox(errorText, "AutoHotkey Debug Error", "Icon!")
    }
    
    static ShowDebugLog() {
        if (this.debugLog.Length = 0) {
            MsgBox("No debug entries found.", "Debug Log", "Iconi")
            return
        }
        
        logText := "🔍 AUTOHOTKEY DEBUG LOG 🔍`n`n"
        logText .= "Total entries: " . this.debugLog.Length . "`n`n"
        
        ; Show last 10 entries
        startIndex := Max(1, this.debugLog.Length - 9)
        Loop (this.debugLog.Length - startIndex + 1) {
            index := startIndex + A_Index - 1
            logText .= this.debugLog[index] . "`n"
        }
        
        logText .= "`nFull log saved to: " . this.logFile
        
        MsgBox(logText, "Debug Log", "Iconi")
    }
    
    static ClearLog() {
        this.debugLog := []
        try {
            FileDelete(this.logFile)
            MsgBox("Debug log cleared.", "Debug Log", "Iconi")
        } catch {
            MsgBox("Failed to clear debug log.", "Debug Error", "Icon!")
        }
    }
    
    static TestScript(scriptPath) {
        this.LogInfo("Testing script: " . scriptPath)
        
        try {
            ; Try to run the script and capture any errors
            RunWait('"' . A_AhkPath . '" "' . scriptPath . '"', , "Hide")
            this.LogInfo("Script completed successfully: " . scriptPath)
        } catch as e {
            this.LogError(scriptPath, e.Message, e.Line)
        }
    }
    
    static ShowSyntaxChecker() {
        syntaxText := "🔧 AUTOHOTKEY V2 SYNTAX CHECKER 🔧`n`n"
        syntaxText .= "Common v2 syntax issues to check:`n`n"
        syntaxText .= "1. String concatenation:`n"
        syntaxText .= "   WRONG: `"text`" variable`n"
        syntaxText .= "   RIGHT: `"text`" . variable`n`n"
        syntaxText .= "2. Function calls:`n"
        syntaxText .= "   WRONG: FileRead var, file`n"
        syntaxText .= "   RIGHT: FileRead(var, file)`n`n"
        syntaxText .= "3. Global variables:`n"
        syntaxText .= "   WRONG: global var1, var2`n"
        syntaxText .= "   RIGHT: var1 := `"`"`n"
        syntaxText .= "          var2 := `"`"`n`n"
        syntaxText .= "4. Exception handling:`n"
        syntaxText .= "   WRONG: catch Error as e`n"
        syntaxText .= "   RIGHT: catch as e`n`n"
        syntaxText .= "5. Reserved words:`n"
        syntaxText .= "   Avoid: continue, break as variables`n`n"
        syntaxText .= "Press OK to continue."
        
        MsgBox(syntaxText, "Syntax Checker", "Iconi")
    }
}

; Hotkeys
^!d::AutoHotkeyDebugger.ShowDebugLog()
F4::AutoHotkeyDebugger.ShowDebugLog()
^!c::AutoHotkeyDebugger.ClearLog()
^!s::AutoHotkeyDebugger.ShowSyntaxChecker()

; Initialize
AutoHotkeyDebugger.LogInfo("Debug helper started")
