; ==============================================================================
; COMMAND LINE INTERFACE & MAIN INITIALIZATION - Part 5 (Final)
; ==============================================================================

; Command line interface for PowerShell callbacks
HandleCommandLine() {
    if (A_Args.Length > 0) {
        command := A_Args[1]
        tempResultFile := A_Temp . "\bridge_result_" . A_TickCount . ".json"
        
        ; Ensure we have the global managers
        if (!g_Logger) {
            g_Logger := Logger()
        }
        if (!g_ScriptletManager) {
            g_ScriptletManager := ScriptletManager(g_Logger)
        }
        
        result := {}
        
        switch command {
            case "run":
                if (A_Args.Length > 1) {
                    result := g_ScriptletManager.RunScript(A_Args[2])
                } else {
                    result := {success: false, message: "No script name provided"}
                }
            
            case "stop":
                if (A_Args.Length > 1) {
                    result := g_ScriptletManager.StopScript(A_Args[2])
                } else {
                    result := {success: false, message: "No script name provided"}
                }
            
            case "list":
                result := g_ScriptletManager.ListRunningScripts()
                
            case "info":
                if (A_Args.Length > 1) {
                    result := g_ScriptletManager.GetScriptInfo(A_Args[2])
                } else {
                    result := {success: false, message: "No script name provided"}
                }
                
            default:
                result := {success: false, message: "Unknown command: " . command}
        }
        
        ; Write result to temp file for PowerShell to read
        try {
            FileAppend(JSON.stringify(result), tempResultFile, "UTF-8")
            g_Logger.Debug("Command result written to: " . tempResultFile)
        } catch as err {
            g_Logger.Error("Failed to write result file: " . err.Message)
        }
        
        ExitApp(result.success ? 0 : 1)
    }
    
    return false
}

; Enhanced script info method for ScriptletManager
class ScriptletManagerEnhanced extends ScriptletManager {
    GetScriptInfo(scriptName) {
        try {
            scriptPath := this.GetScriptPath(scriptName)
            
            if (!FileExist(scriptPath)) {
                return {success: false, message: "Script not found: " . scriptName}
            }
            
            ; Get file info
            fileSize := FileGetSize(scriptPath)
            fileTime := FileGetTime(scriptPath, "M")
            
            ; Read script for description
            description := "AutoHotkey v2 Script"
            try {
                content := FileRead(scriptPath, "UTF-8")
                lines := StrSplit(content, "`n", "`r")
                
                for i, line in lines {
                    if (i > 15) break
                    
                    line := Trim(line)
                    if (RegExMatch(line, "^;\s*(.+)", &match)) {
                        cleanDesc := Trim(match[1])
                        if (cleanDesc != "" && !RegExMatch(cleanDesc, "^=+$|^-+$") && !InStr(cleanDesc, "AutoHotkey")) {
                            description := cleanDesc
                            break
                        }
                    } else if (line != "" && !RegExMatch(line, "^[;#]")) {
                        break
                    }
                }
            } catch {
                ; Ignore read errors for description
            }
            
            ; Check if running
            isRunning := false
            pid := 0
            if (this.runningScripts.Has(scriptName)) {
                pid := this.runningScripts[scriptName]
                isRunning := ProcessExist(pid) != 0
                if (!isRunning) {
                    ; Clean up stale entry
                    this.runningScripts.Delete(scriptName)
                    pid := 0
                }
            }
            
            return {
                success: true,
                name: scriptName,
                description: description,
                file_size: fileSize,
                file_size_kb: Round(fileSize / 1024, 1),
                modified: FormatTime(fileTime, "yyyy-MM-dd HH:mm:ss"),
                is_running: isRunning,
                pid: isRunning ? pid : 0,
                path: scriptPath
            }
            
        } catch as err {
            errorMsg := "Failed to get script info for " . scriptName . ": " . err.Message
            this.logger.Error(errorMsg)
            return {success: false, message: errorMsg}
        }
    }
}

; ==============================================================================
; MAIN APPLICATION STARTUP
; ==============================================================================

Main() {
    try {
        ; Handle command line calls first
        if (A_Args.Length > 0) {
            return HandleCommandLine()
        }
        
        ; Normal GUI mode startup
        TrayTip("Starting Bridge", "Initializing Scriptlet COM Bridge v" . Config.VERSION . "...", 0, 1)
        
        ; Create main bridge instance
        g_Bridge := ScriptletBridge()
        
        ; Set up exit handler
        OnExit((*) => {
            if (g_Bridge) {
                g_Bridge.Cleanup()
            }
        })
        
        ; Success message
        g_Logger.Info("Scriptlet COM Bridge v" . Config.VERSION . " startup complete")
        
        return true
        
    } catch as err {
        ; Critical startup error handling
        errorMsg := "CRITICAL: Bridge startup failed - " . err.Message
        
        ; Try to log the error
        try {
            emergencyLog := A_ScriptDir . "\emergency_" . A_TickCount . ".log"
            FileAppend("[" . A_Now . "] " . errorMsg . "`n", emergencyLog, "UTF-8")
        } catch {
            ; If even emergency logging fails, just continue to MsgBox
        }
        
        ; Show user the error
        MsgBox("❌ " . errorMsg . "`n`nCheck emergency log in script directory.", "Critical Bridge Error", 16)
        ExitApp(1)
    }
}

; ==============================================================================
; SCRIPT EXECUTION
; ==============================================================================

; Start the application
if (!Main()) {
    ExitApp(1)
}

; Keep script persistent for GUI mode
if (A_Args.Length = 0) {
    ; Show success notification
    SetTimer(() => {
        if (g_Bridge && g_Bridge.httpServer.TestConnection()) {
            A_IconTip := "Scriptlet COM Bridge v" . Config.VERSION . " - Online ✅"
        } else {
            A_IconTip := "Scriptlet COM Bridge v" . Config.VERSION . " - Offline ❌"
        }
    }, 30000)  ; Update status every 30 seconds
}