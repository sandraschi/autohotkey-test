; ==============================================================================
; LOGGING CLASS - Part 2 of v2 Bridge
; ==============================================================================

class Logger {
    __New(logPath := "") {
        this.logPath := logPath || Config.LOG_PATH
        this.currentLogFile := ""
        this.InitializeLogging()
    }
    
    InitializeLogging() {
        try {
            if (!DirExist(this.logPath)) {
                DirCreate(this.logPath)
            }
            
            timestamp := FormatTime(A_Now, "yyyy-MM-dd")
            this.currentLogFile := this.logPath . "bridge_" . timestamp . ".log"
            
            this.CleanOldLogs()
            this.Info("=== Scriptlet COM Bridge v" . Config.VERSION . " Started ===")
            this.Info("Log file: " . this.currentLogFile)
            this.Info("Scriptlet path: " . Config.SCRIPTLET_PATH)
            
        } catch as err {
            MsgBox("Failed to initialize logging: " . err.Message, "Error", 16)
        }
    }
    
    WriteLog(level, message) {
        try {
            timestamp := FormatTime(A_Now, "yyyy-MM-dd HH:mm:ss")
            logEntry := "[" . timestamp . "] [" . level . "] " . message . "`n"
            
            FileAppend(logEntry, this.currentLogFile, "UTF-8")
            
            if (A_IsCompiled = 0) {
                OutputDebug(logEntry)
            }
            
            this.CheckLogRotation()
            
        } catch as err {
            OutputDebug("Logging failed: " . err.Message)
        }
    }
    
    Info(message) => this.WriteLog("INFO", message)
    Warn(message) => this.WriteLog("WARN", message)
    Error(message) => this.WriteLog("ERROR", message)
    Debug(message) => this.WriteLog("DEBUG", message)
    
    CheckLogRotation() {
        try {
            if (FileExist(this.currentLogFile)) {
                fileSize := FileGetSize(this.currentLogFile)
                if (fileSize > Config.MAX_LOG_SIZE) {
                    rotatedFile := StrReplace(this.currentLogFile, ".log", "_" . A_TickCount . ".log")
                    FileMove(this.currentLogFile, rotatedFile)
                    this.Info("Log rotated to: " . rotatedFile)
                }
            }
        } catch as err {
            OutputDebug("Log rotation failed: " . err.Message)
        }
    }
    
    CleanOldLogs() {
        try {
            cutoffDate := DateAdd(A_Now, -Config.LOG_RETENTION_DAYS, "Days")
            
            Loop Files, this.logPath . "bridge_*.log" {
                try {
                    fileDate := FileGetTime(A_LoopFileFullPath, "M")
                    if (fileDate < cutoffDate) {
                        FileDelete(A_LoopFileFullPath)
                        this.Debug("Deleted old log file: " . A_LoopFileName)
                    }
                } catch {
                    continue
                }
            }
        } catch as err {
            this.Warn("Failed to clean old logs: " . err.Message)
        }
    }
}