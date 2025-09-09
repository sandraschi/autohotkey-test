; ==============================================================================
; HTTP SERVER CLASS - Fixed Part 4 of v2 Bridge
; ==============================================================================

class HTTPServer {
    __New(logger, scriptletManager) {
        this.logger := logger
        this.scriptletManager := scriptletManager
        this.serverScript := ""
        this.serverProcess := ""
        this.tempPath := Config.TEMP_PATH
    }
    
    Start() {
        try {
            if (!DirExist(this.tempPath)) {
                DirCreate(this.tempPath)
            }
            
            ; Use pre-created PowerShell script
            this.serverScript := A_ScriptDir . "\scriptlet_server.ps1"
            
            if (!FileExist(this.serverScript)) {
                throw Error("PowerShell server script not found: " . this.serverScript)
            }
            
            cmdLine := 'powershell.exe -WindowStyle Hidden -ExecutionPolicy Bypass -File "' . this.serverScript . '"'
            this.logger.Debug("Starting server: " . cmdLine)
            
            this.serverProcess := Run(cmdLine, A_ScriptDir, "Hide")
            Sleep(3000)  ; Give server more time to start
            
            if (this.TestConnection()) {
                this.logger.Info("HTTP server started successfully on port " . Config.SERVER_PORT . " (PID: " . this.serverProcess . ")")
                return {success: true, message: "Server started", pid: this.serverProcess}
            } else {
                throw Error("Server failed to respond after startup")
            }
            
        } catch as err {
            errorMsg := "Failed to start HTTP server: " . err.Message
            this.logger.Error(errorMsg)
            return {success: false, message: errorMsg}
        }
    }
    
    Stop() {
        try {
            if (this.serverProcess && ProcessExist(this.serverProcess)) {
                ; First try graceful close
                try {
                    ProcessClose(this.serverProcess)
                    Sleep(1000)
                } catch {
                    ; Force kill if graceful close fails
                    RunWait('taskkill /F /PID ' . this.serverProcess, , "Hide")
                }
                this.logger.Info("HTTP server stopped (PID: " . this.serverProcess . ")")
            }
            
            ; Also kill any remaining PowerShell processes running our server
            try {
                RunWait('taskkill /F /FI "WINDOWTITLE eq *scriptlet_server*" 2>nul', , "Hide")
            } catch {
                ; Ignore errors
            }
            
            return {success: true, message: "Server stopped"}
            
        } catch as err {
            errorMsg := "Failed to stop HTTP server: " . err.Message
            this.logger.Error(errorMsg)
            return {success: false, message: errorMsg}
        }
    }
    
    TestConnection() {
        try {
            ; Test HTTP connection with timeout
            testCmd := 'powershell -Command "try { Invoke-WebRequest -Uri ''http://' . Config.SERVER_HOST . ':' . Config.SERVER_PORT . '/status'' -TimeoutSec 5 -UseBasicParsing | Out-Null; exit 0 } catch { exit 1 }"'
            result := RunWait(testCmd, , "Hide")
            return result = 0
        } catch {
            return false
        }
    }
}

; ==============================================================================
; MAIN BRIDGE CLASS
; ==============================================================================

class ScriptletBridge {
    __New() {
        ; Initialize components
        this.logger := Logger()
        this.scriptletManager := ScriptletManager(this.logger)
        this.httpServer := HTTPServer(this.logger, this.scriptletManager)
        
        ; Make globally accessible for command line interface
        g_Logger := this.logger
        g_ScriptletManager := this.scriptletManager
        
        ; Setup tray menu
        this.SetupTrayMenu()
        
        ; Start server
        this.StartServer()
    }
    
    SetupTrayMenu() {
        ; Clear default menu
        A_TrayMenu.Delete()
        
        ; Add custom menu items
        A_TrayMenu.Add("🚀 Show HTML Launcher", (*) => this.ShowLauncher())
        A_TrayMenu.Add("📊 Server Status", (*) => this.ShowStatus())
        A_TrayMenu.Add("📝 Running Scripts", (*) => this.ShowRunningScripts())
        A_TrayMenu.Add()
        A_TrayMenu.Add("🔄 Reload Bridge", (*) => this.ReloadBridge())
        A_TrayMenu.Add("📋 View Logs", (*) => this.ViewLogs())
        A_TrayMenu.Add()
        A_TrayMenu.Add("❌ Exit Bridge", (*) => this.ExitBridge())
        
        A_TrayMenu.Default := "🚀 Show HTML Launcher"
        A_IconTip := "Scriptlet COM Bridge v" . Config.VERSION . " - Ready"
    }
    
    StartServer() {
        this.logger.Info("Starting Scriptlet Bridge v" . Config.VERSION . "...")
        
        result := this.httpServer.Start()
        if (result.success) {
            g_IsRunning := true
            TrayTip("Bridge Started ✅", "HTTP server running on port " . Config.SERVER_PORT . "`nClick tray icon to open launcher", 0, 1)
            A_IconTip := "Scriptlet COM Bridge v" . Config.VERSION . " - Online"
        } else {
            MsgBox("❌ Failed to start bridge:`n" . result.message, "Scriptlet Bridge Error", 16)
            this.logger.Error("Failed to start bridge: " . result.message)
            ExitApp(1)
        }
    }
    
    ShowLauncher() {
        launcherPath := A_ScriptDir . "\launcher.html"
        if (FileExist(launcherPath)) {
            try {
                Run(launcherPath)
                this.logger.Info("Opened HTML launcher")
            } catch as err {
                this.logger.Error("Failed to open launcher: " . err.Message)
                MsgBox("❌ Failed to open launcher: " . err.Message, "Error", 16)
            }
        } else {
            this.logger.Error("Launcher not found: " . launcherPath)
            MsgBox("❌ Launcher file not found:`n" . launcherPath, "Error", 16)
        }
    }
    
    ShowStatus() {
        ; Test server connection
        isOnline := this.httpServer.TestConnection()
        
        ; Get running scripts
        runningResult := this.scriptletManager.ListRunningScripts()
        runningCount := runningResult.success ? runningResult.running_scripts.Length : 0
        
        status := "=== Scriptlet Bridge Status ===`n"
        status .= "Version: " . Config.VERSION . "`n"
        status .= "Server: " . (isOnline ? "🟢 Online" : "🔴 Offline") . "`n"
        status .= "Port: " . Config.SERVER_PORT . "`n"
        status .= "Running Scripts: " . runningCount . "`n"
        status .= "Scriptlets Path: " . Config.SCRIPTLET_PATH . "`n"
        status .= "Log File: " . this.logger.currentLogFile . "`n"
        status .= "`nℹ️ Click OK to copy status to clipboard"
        
        result := MsgBox(status, "Bridge Status", 1)
        if (result = "OK") {
            A_Clipboard := status
        }
    }
    
    ShowRunningScripts() {
        result := this.scriptletManager.ListRunningScripts()
        
        if (result.success) {
            if (result.running_scripts.Length = 0) {
                MsgBox("No scripts currently running", "Running Scripts", 0)
                return
            }
            
            scriptList := "=== Running Scripts ===`n"
            for script in result.running_scripts {
                scriptList .= "• " . script.name . " (PID: " . script.pid . ")`n"
            }
            
            MsgBox(scriptList, "Running Scripts", 0)
        } else {
            MsgBox("❌ Failed to get running scripts:`n" . result.message, "Error", 16)
        }
    }
    
    ViewLogs() {
        if (FileExist(this.logger.currentLogFile)) {
            try {
                Run('notepad.exe "' . this.logger.currentLogFile . '"')
                this.logger.Info("Opened log file in notepad")
            } catch {
                try {
                    Run('explorer.exe "' . this.logger.logPath . '"')
                    this.logger.Info("Opened log directory in explorer")
                } catch as err {
                    MsgBox("❌ Failed to open logs: " . err.Message, "Error", 16)
                }
            }
        } else {
            MsgBox("❌ Log file not found", "Error", 16)
        }
    }
    
    ReloadBridge() {
        result := MsgBox("🔄 Reload Scriptlet Bridge?`n`nThis will restart the HTTP server.", "Confirm Reload", 4)
        if (result = "Yes") {
            this.logger.Info("Bridge reload requested by user")
            this.httpServer.Stop()
            Reload()
        }
    }
    
    ExitBridge() {
        result := MsgBox("❌ Exit Scriptlet Bridge?`n`nThis will stop all HTTP services.", "Confirm Exit", 4)
        if (result = "Yes") {
            this.logger.Info("Bridge shutdown requested by user")
            this.Cleanup()
            ExitApp(0)
        }
    }
    
    Cleanup() {
        try {
            this.httpServer.Stop()
            this.logger.Info("=== Scriptlet COM Bridge Shutdown Complete ===")
            TrayTip("Bridge Stopped", "Scriptlet Bridge has been shut down", 0, 1)
        } catch as err {
            this.logger.Error("Cleanup error: " . err.Message)
        }
    }
}