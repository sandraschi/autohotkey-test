; ==============================================================================
; SCRIPTLET MANAGER CLASS - Part 3 of v2 Bridge
; ==============================================================================

class ScriptletManager {
    __New(logger) {
        this.logger := logger
        this.runningScripts := Map()
        this.scriptletPath := Config.SCRIPTLET_PATH
        
        if (!DirExist(this.scriptletPath)) {
            try {
                DirCreate(this.scriptletPath)
                this.logger.Info("Created scriptlets directory: " . this.scriptletPath)
            } catch as err {
                this.logger.Error("Failed to create scriptlets directory: " . err.Message)
            }
        }
    }
    
    ValidateScriptName(scriptName) {
        if (RegExMatch(scriptName, "[<>:\"|?*\\/]") || scriptName = "" || scriptName = "." || scriptName = "..") {
            return false
        }
        
        if (!RegExMatch(scriptName, "\.ahk$")) {
            return false
        }
        
        return true
    }
    
    GetScriptPath(scriptName) {
        if (!this.ValidateScriptName(scriptName)) {
            throw Error("Invalid script name: " . scriptName)
        }
        return this.scriptletPath . scriptName
    }
    
    RunScript(scriptName, parameters := "") {
        this.logger.Info("Attempting to run script: " . scriptName)
        
        try {
            scriptPath := this.GetScriptPath(scriptName)
            
            if (!FileExist(scriptPath)) {
                errorMsg := "Script not found: " . scriptName
                this.logger.Error(errorMsg)
                return {success: false, message: errorMsg}
            }
            
            if (this.runningScripts.Has(scriptName)) {
                pid := this.runningScripts[scriptName]
                if (ProcessExist(pid)) {
                    warnMsg := "Script already running: " . scriptName . " (PID: " . pid . ")"
                    this.logger.Warn(warnMsg)
                    return {success: true, message: warnMsg, already_running: true}
                } else {
                    this.runningScripts.Delete(scriptName)
                }
            }
            
            ahkPath := this.GetAutoHotkeyPath()
            cmdLine := '"' . ahkPath . '" "' . scriptPath . '"'
            
            if (parameters != "") {
                cmdLine .= " " . parameters
            }
            
            this.logger.Debug("Executing: " . cmdLine)
            
            pid := Run(cmdLine, this.scriptletPath, "Hide")
            this.runningScripts[scriptName] := pid
            
            successMsg := "Successfully started: " . scriptName . " (PID: " . pid . ")"
            this.logger.Info(successMsg)
            
            return {
                success: true, 
                message: successMsg, 
                pid: pid,
                script_name: scriptName
            }
            
        } catch as err {
            errorMsg := "Failed to run " . scriptName . ": " . err.Message
            this.logger.Error(errorMsg)
            return {success: false, message: errorMsg, error: err.Message}
        }
    }
    
    StopScript(scriptName) {
        this.logger.Info("Attempting to stop script: " . scriptName)
        
        try {
            if (!this.ValidateScriptName(scriptName)) {
                throw Error("Invalid script name")
            }
            
            stopped := false
            pid := 0
            
            if (this.runningScripts.Has(scriptName)) {
                pid := this.runningScripts[scriptName]
                
                if (ProcessExist(pid)) {
                    try {
                        ProcessClose(pid)
                        stopped := true
                        this.logger.Info("Gracefully stopped script: " . scriptName . " (PID: " . pid . ")")
                    } catch {
                        try {
                            RunWait('taskkill /F /PID ' . pid, , "Hide")
                            stopped := true
                            this.logger.Warn("Force terminated script: " . scriptName . " (PID: " . pid . ")")
                        } catch as err {
                            this.logger.Error("Failed to terminate PID " . pid . ": " . err.Message)
                        }
                    }
                }
                
                this.runningScripts.Delete(scriptName)
            }
            
            processName := StrReplace(scriptName, ".ahk", ".exe")
            try {
                result := RunWait('taskkill /F /IM "' . processName . '" 2>nul', , "Hide")
                if (result = 0) {
                    stopped := true
                    this.logger.Info("Stopped script by process name: " . processName)
                }
            } catch {
                ; Ignore taskkill errors
            }
            
            if (stopped) {
                return {success: true, message: "Successfully stopped: " . scriptName}
            } else {
                return {success: true, message: "Script was not running: " . scriptName, was_running: false}
            }
            
        } catch as err {
            errorMsg := "Failed to stop " . scriptName . ": " . err.Message
            this.logger.Error(errorMsg)
            return {success: false, message: errorMsg, error: err.Message}
        }
    }
    
    ListRunningScripts() {
        try {
            running := []
            staleEntries := []
            
            for scriptName, pid in this.runningScripts {
                if (ProcessExist(pid)) {
                    running.Push({
                        name: scriptName,
                        pid: pid
                    })
                } else {
                    staleEntries.Push(scriptName)
                }
            }
            
            for _, scriptName in staleEntries {
                this.runningScripts.Delete(scriptName)
                this.logger.Debug("Cleaned stale entry: " . scriptName)
            }
            
            this.logger.Debug("Found " . running.Length . " running scripts")
            return {success: true, running_scripts: running}
            
        } catch as err {
            errorMsg := "Failed to list running scripts: " . err.Message
            this.logger.Error(errorMsg)
            return {success: false, message: errorMsg}
        }
    }
    
    GetAutoHotkeyPath() {
        paths := [
            "C:\Program Files\AutoHotkey\v2\AutoHotkey.exe",
            "C:\Program Files (x86)\AutoHotkey\v2\AutoHotkey.exe", 
            "C:\Program Files\AutoHotkey\AutoHotkey.exe",
            A_AhkPath
        ]
        
        for _, path in paths {
            if (FileExist(path)) {
                this.logger.Debug("Found AutoHotkey at: " . path)
                return path
            }
        }
        
        this.logger.Warn("Using current AutoHotkey executable: " . A_AhkPath)
        return A_AhkPath
    }
}