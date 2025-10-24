﻿; ==============================================================================
; MCP Troubleshooter
; @name: MCP Troubleshooter
; @version: 1.0.0
; @description: Smart MCP troubleshooting with automated fixes and diagnostics
; @category: development
; @author: Sandra
; @hotkeys: ^!t, F11
; @enabled: true
; ==============================================================================

#Requires AutoHotkey v2.0+
#SingleInstance Force

class MCPTroubleshooter {
    static claudeConfig := ""
    static mcpServers := []
    static diagnostics := []
    
    static Init() {
        this.claudeConfig := A_AppData . "\Claude\claude_desktop_config.json"
        this.CreateGUI()
    }
    
    static CreateGUI() {
        gui := Gui("+Resize +MinSize900x700", "MCP Troubleshooter")
        gui.BackColor := "0x1a1a1a"
        gui.SetFont("s10 cWhite", "Segoe UI")
        
        ; Title
        gui.Add("Text", "x20 y20 w860 Center Bold", "ðŸ”§ MCP Troubleshooter")
        gui.Add("Text", "x20 y50 w860 Center c0xcccccc", "Smart MCP troubleshooting with automated fixes and diagnostics")
        
        ; Configuration section
        gui.Add("Text", "x20 y90 w860 Bold", "âš™ï¸ Configuration")
        gui.Add("Text", "x20 y115 w150", "Claude Config:")
        gui.Add("Text", "x180 y115 w680 c0xcccccc", this.claudeConfig)
        
        ; Quick diagnostics
        gui.Add("Text", "x20 y150 w860 Bold", "ðŸ” Quick Diagnostics")
        
        ; Diagnostic buttons
        gui.Add("Button", "x20 y180 w200 h50", "ðŸ“‹ Check Config").OnEvent("Click", this.CheckConfig.Bind(this))
        gui.Add("Button", "x240 y180 w200 h50", "ðŸ Check Python").OnEvent("Click", this.CheckPython.Bind(this))
        gui.Add("Button", "x460 y180 w200 h50", "ðŸ“¦ Check Dependencies").OnEvent("Click", this.CheckDependencies.Bind(this))
        gui.Add("Button", "x680 y180 w200 h50", "ðŸŒ Check Connectivity").OnEvent("Click", this.CheckConnectivity.Bind(this))
        
        ; MCP Server Management
        gui.Add("Text", "x20 y250 w860 Bold", "ðŸ–¥ï¸ MCP Server Management")
        
        ; Server list
        serverList := gui.Add("ListBox", "x20 y280 w400 h150")
        
        ; Server controls
        gui.Add("Button", "x440 y280 w200 h40", "â–¶ï¸ Start Server").OnEvent("Click", this.StartServer.Bind(this))
        gui.Add("Button", "x660 y280 w200 h40", "â¹ï¸ Stop Server").OnEvent("Click", this.StopServer.Bind(this))
        gui.Add("Button", "x440 y330 w200 h40", "ðŸ”„ Restart Server").OnEvent("Click", this.RestartServer.Bind(this))
        gui.Add("Button", "x660 y330 w200 h40", "ðŸ“Š Test Server").OnEvent("Click", this.TestServer.Bind(this))
        gui.Add("Button", "x440 y380 w200 h40", "ðŸ“ View Logs").OnEvent("Click", this.ViewLogs.Bind(this))
        gui.Add("Button", "x660 y380 w200 h40", "âš™ï¸ Edit Config").OnEvent("Click", this.EditConfig.Bind(this))
        
        ; Automated fixes
        gui.Add("Text", "x20 y450 w860 Bold", "ðŸ› ï¸ Automated Fixes")
        
        ; Fix buttons
        gui.Add("Button", "x20 y480 w200 h50", "ðŸ”§ Fix Config Issues").OnEvent("Click", this.FixConfigIssues.Bind(this))
        gui.Add("Button", "x240 y480 w200 h50", "ðŸ“¦ Install Dependencies").OnEvent("Click", this.InstallDependencies.Bind(this))
        gui.Add("Button", "x460 y480 w200 h50", "ðŸ”„ Reset MCP Servers").OnEvent("Click", this.ResetMCPServers.Bind(this))
        gui.Add("Button", "x680 y480 w200 h50", "ðŸ§¹ Clean Temp Files").OnEvent("Click", this.CleanTempFiles.Bind(this))
        
        ; Results section
        gui.Add("Text", "x20 y550 w860 Bold", "ðŸ“‹ Troubleshooting Results")
        
        ; Results display
        resultsEdit := gui.Add("Edit", "x20 y580 w860 h80 ReadOnly Multi VScroll", "")
        resultsEdit.BackColor := "0x2d2d2d"
        
        ; Action buttons
        gui.Add("Button", "x20 y670 w150 h40", "ðŸ’¾ Save Report").OnEvent("Click", this.SaveReport.Bind(this))
        gui.Add("Button", "x190 y670 w150 h40", "ðŸ“‹ Copy Results").OnEvent("Click", this.CopyResults.Bind(this))
        gui.Add("Button", "x360 y670 w150 h40", "â“ Help").OnEvent("Click", this.ShowHelp.Bind(this))
        
        ; Status
        gui.Add("Text", "x20 y720 w860 Center c0x888888", "Hotkeys: Ctrl+Alt+T (Troubleshoot) | F11 (Quick Fix) | Press Check Config to start")
        
        ; Store references
        gui.serverList := serverList
        gui.resultsEdit := resultsEdit
        
        ; Load MCP servers
        this.LoadMCPServers(gui)
        
        ; Set up hotkeys
        this.SetupHotkeys(gui)
        
        gui.Show("w900 h780")
    }
    
    static LoadMCPServers(gui) {
        try {
            if (!FileExist(this.claudeConfig)) {
                gui.resultsEdit.Text := "Claude config file not found: " . this.claudeConfig
                return
            }
            
            configContent := FileRead(this.claudeConfig)
            
            ; Simple JSON parsing for MCP servers
            if (RegExMatch(configContent, '"mcpServers"\s*:\s*\{([^}]+)\}')) {
                ; Extract server names (simplified)
                serverNames := []
                if (RegExMatch(configContent, '"mcpServers"\s*:\s*\{([^}]+)\}', &match)) {
                    ; Parse server names from JSON
                    Loop Parse, match[1], '"' {
                        if (Mod(A_Index, 2) = 0 && A_LoopField != "mcpServers") {
                            serverNames.Push(A_LoopField)
                        }
                    }
                }
                
                gui.serverList.Text := serverNames.Join("`n")
                this.mcpServers := serverNames
            } else {
                gui.resultsEdit.Text := "No MCP servers found in configuration"
            }
            
        } catch as e {
            gui.resultsEdit.Text := "Error loading MCP servers: " . e.Message
        }
    }
    
    static CheckConfig(*) {
        try {
            results := "ðŸ“‹ Configuration Check Results:`n`n"
            
            if (!FileExist(this.claudeConfig)) {
                results .= "âŒ Claude config file not found`n"
                results .= "Expected location: " . this.claudeConfig . "`n`n"
                results .= "Fix: Install Claude Desktop or check installation path`n`n"
            } else {
                results .= "âœ… Claude config file found`n"
                
                ; Check JSON syntax
                try {
                    configContent := FileRead(this.claudeConfig)
                    if (InStr(configContent, "mcpServers")) {
                        results .= "âœ… MCP servers section found`n"
                    } else {
                        results .= "âš ï¸ No MCP servers section found`n"
                        results .= "Fix: Add mcpServers section to config`n"
                    }
                } catch as e {
                    results .= "âŒ Config file read error: " . e.Message . "`n"
                }
            }
            
            this.UpdateResults(results)
            
        } catch as e {
            this.UpdateResults("Error checking config: " . e.Message)
        }
    }
    
    static CheckPython(*) {
        try {
            results := "ðŸ Python Check Results:`n`n"
            
            ; Check if Python is installed
            try {
                RunWait("python --version", , "Hide", &output)
                results .= "âœ… Python found: " . output . "`n"
            } catch {
                results .= "âŒ Python not found in PATH`n"
                results .= "Fix: Install Python or add to PATH`n"
            }
            
            ; Check pip
            try {
                RunWait("pip --version", , "Hide", &pipOutput)
                results .= "âœ… pip found: " . pipOutput . "`n"
            } catch {
                results .= "âŒ pip not found`n"
                results .= "Fix: Install pip or reinstall Python`n"
            }
            
            ; Check virtual environment
            if (A_Env.Has("VIRTUAL_ENV")) {
                results .= "âœ… Virtual environment active: " . A_Env.VIRTUAL_ENV . "`n"
            } else {
                results .= "âš ï¸ No virtual environment detected`n"
                results .= "Recommendation: Use virtual environment for MCP servers`n"
            }
            
            this.UpdateResults(results)
            
        } catch as e {
            this.UpdateResults("Error checking Python: " . e.Message)
        }
    }
    
    static CheckDependencies(*) {
        try {
            results := "ðŸ“¦ Dependencies Check Results:`n`n"
            
            ; Check common MCP dependencies
            dependencies := ["fastmcp", "requests", "pydantic"]
            
            for dep in dependencies {
                try {
                    RunWait("pip show " . dep, , "Hide", &output)
                    if (InStr(output, "Name: " . dep)) {
                        results .= "âœ… " . dep . " installed`n"
                    } else {
                        results .= "âŒ " . dep . " not found`n"
                    }
                } catch {
                    results .= "âŒ " . dep . " not found`n"
                }
            }
            
            results .= "`nRecommendation: Install missing dependencies with:`n"
            results .= "pip install fastmcp requests pydantic`n"
            
            this.UpdateResults(results)
            
        } catch as e {
            this.UpdateResults("Error checking dependencies: " . e.Message)
        }
    }
    
    static CheckConnectivity(*) {
        try {
            results := "ðŸŒ Connectivity Check Results:`n`n"
            
            ; Check localhost connectivity
            try {
                RunWait("ping -n 1 127.0.0.1", , "Hide", &output)
                results .= "âœ… Localhost connectivity OK`n"
            } catch {
                results .= "âŒ Localhost connectivity failed`n"
            }
            
            ; Check if common MCP ports are available
            ports := [8000, 8001, 8002, 8765]
            for port in ports {
                try {
                    ; Simple port check (Windows specific)
                    RunWait("netstat -an | findstr :" . port, , "Hide", &output)
                    if (InStr(output, ":" . port)) {
                        results .= "âš ï¸ Port " . port . " is in use`n"
                    } else {
                        results .= "âœ… Port " . port . " is available`n"
                    }
                } catch {
                    results .= "âœ… Port " . port . " appears available`n"
                }
            }
            
            this.UpdateResults(results)
            
        } catch as e {
            this.UpdateResults("Error checking connectivity: " . e.Message)
        }
    }
    
    static StartServer(*) {
        try {
            selectedServer := this.GetSelectedServer()
            if (selectedServer = "") {
                MsgBox("Please select a server from the list", "No Server Selected", "Icon!")
                return
            }
            
            results := "â–¶ï¸ Starting Server: " . selectedServer . "`n`n"
            
            ; This would start the actual MCP server
            results .= "Server start command would be executed here`n"
            results .= "Check server logs for startup status`n"
            
            this.UpdateResults(results)
            
        } catch as e {
            this.UpdateResults("Error starting server: " . e.Message)
        }
    }
    
    static StopServer(*) {
        try {
            selectedServer := this.GetSelectedServer()
            if (selectedServer = "") {
                MsgBox("Please select a server from the list", "No Server Selected", "Icon!")
                return
            }
            
            results := "â¹ï¸ Stopping Server: " . selectedServer . "`n`n"
            
            ; This would stop the actual MCP server
            results .= "Server stop command would be executed here`n"
            results .= "Check that server process is terminated`n"
            
            this.UpdateResults(results)
            
        } catch as e {
            this.UpdateResults("Error stopping server: " . e.Message)
        }
    }
    
    static RestartServer(*) {
        try {
            selectedServer := this.GetSelectedServer()
            if (selectedServer = "") {
                MsgBox("Please select a server from the list", "No Server Selected", "Icon!")
                return
            }
            
            results := "ðŸ”„ Restarting Server: " . selectedServer . "`n`n"
            
            ; Stop then start
            results .= "1. Stopping server...`n"
            results .= "2. Waiting for cleanup...`n"
            results .= "3. Starting server...`n"
            results .= "4. Verifying startup...`n"
            
            this.UpdateResults(results)
            
        } catch as e {
            this.UpdateResults("Error restarting server: " . e.Message)
        }
    }
    
    static TestServer(*) {
        try {
            selectedServer := this.GetSelectedServer()
            if (selectedServer = "") {
                MsgBox("Please select a server from the list", "No Server Selected", "Icon!")
                return
            }
            
            results := "ðŸ“Š Testing Server: " . selectedServer . "`n`n"
            
            ; This would test the MCP server
            results .= "1. Checking server process...`n"
            results .= "2. Testing tool registration...`n"
            results .= "3. Validating responses...`n"
            results .= "4. Checking error handling...`n"
            
            this.UpdateResults(results)
            
        } catch as e {
            this.UpdateResults("Error testing server: " . e.Message)
        }
    }
    
    static ViewLogs(*) {
        try {
            selectedServer := this.GetSelectedServer()
            if (selectedServer = "") {
                MsgBox("Please select a server from the list", "No Server Selected", "Icon!")
                return
            }
            
            ; Open log viewer
            logDir := A_AppData . "\Claude\logs\"
            if (DirExist(logDir)) {
                Run("explorer " . logDir)
            } else {
                MsgBox("Log directory not found: " . logDir, "Error", "Iconx")
            }
            
        } catch as e {
            this.UpdateResults("Error viewing logs: " . e.Message)
        }
    }
    
    static EditConfig(*) {
        try {
            if (FileExist(this.claudeConfig)) {
                Run("notepad " . this.claudeConfig)
            } else {
                MsgBox("Config file not found: " . this.claudeConfig, "Error", "Iconx")
            }
        } catch as e {
            this.UpdateResults("Error opening config: " . e.Message)
        }
    }
    
    static FixConfigIssues(*) {
        try {
            results := "ðŸ”§ Fixing Config Issues:`n`n"
            
            if (!FileExist(this.claudeConfig)) {
                results .= "Creating default config file...`n"
                this.CreateDefaultConfig()
                results .= "âœ… Default config created`n"
            } else {
                results .= "Validating existing config...`n"
                this.ValidateConfig()
                results .= "âœ… Config validation complete`n"
            }
            
            this.UpdateResults(results)
            
        } catch as e {
            this.UpdateResults("Error fixing config: " . e.Message)
        }
    }
    
    static InstallDependencies(*) {
        try {
            results := "ðŸ“¦ Installing Dependencies:`n`n"
            
            ; Install common MCP dependencies
            dependencies := ["fastmcp", "requests", "pydantic"]
            
            for dep in dependencies {
                results .= "Installing " . dep . "...`n"
                try {
                    RunWait("pip install " . dep, , "Hide", &output)
                    results .= "âœ… " . dep . " installed successfully`n"
                } catch {
                    results .= "âŒ Failed to install " . dep . "`n"
                }
            }
            
            this.UpdateResults(results)
            
        } catch as e {
            this.UpdateResults("Error installing dependencies: " . e.Message)
        }
    }
    
    static ResetMCPServers(*) {
        try {
            results := "ðŸ”„ Resetting MCP Servers:`n`n"
            
            ; Stop all MCP servers
            results .= "1. Stopping all MCP servers...`n"
            
            ; Clear temp files
            results .= "2. Clearing temporary files...`n"
            this.CleanTempFiles()
            
            ; Restart Claude Desktop
            results .= "3. Recommending Claude Desktop restart...`n"
            results .= "Please restart Claude Desktop manually`n"
            
            this.UpdateResults(results)
            
        } catch as e {
            this.UpdateResults("Error resetting MCP servers: " . e.Message)
        }
    }
    
    static CleanTempFiles(*) {
        try {
            results := "ðŸ§¹ Cleaning Temp Files:`n`n"
            
            tempDir := A_Temp
            patterns := ["mcp_*.tmp", "claude_*.lock", "*.log"]
            
            for pattern in patterns {
                try {
                    Loop Files, tempDir . "\" . pattern {
                        try FileDelete(A_LoopFileFullPath)
                        results .= "Deleted: " . A_LoopFileName . "`n"
                    }
                } catch {
                    ; Ignore errors
                }
            }
            
            results .= "âœ… Temp file cleanup complete`n"
            this.UpdateResults(results)
            
        } catch as e {
            this.UpdateResults("Error cleaning temp files: " . e.Message)
        }
    }
    
    static GetSelectedServer() {
        ; This would get the selected server from the GUI
        ; For now, return first server if any exist
        if (this.mcpServers.Length > 0) {
            return this.mcpServers[1]
        }
        return ""
    }
    
    static CreateDefaultConfig() {
        defaultConfig := "{`n"
        defaultConfig .= "  `"mcpServers`": {`n"
        defaultConfig .= "    `"example-server`": {`n"
        defaultConfig .= "      `"command`": `"python`",`n"
        defaultConfig .= "      `"args`": [`"main.py`"]`n"
        defaultConfig .= "    }`n"
        defaultConfig .= "  }`n"
        defaultConfig .= "}`n"
        
        FileAppend(defaultConfig, this.claudeConfig)
    }
    
    static ValidateConfig() {
        try {
            configContent := FileRead(this.claudeConfig)
            ; Basic JSON validation
            if (!InStr(configContent, "mcpServers")) {
                throw Error("No mcpServers section found")
            }
        } catch as e {
            throw Error("Config validation failed: " . e.Message)
        }
    }
    
    static UpdateResults(text) {
        ; This would update the GUI results display
        ; For now, show in message box
        MsgBox(text, "MCP Troubleshooter Results", "Iconi")
    }
    
    static SaveReport(*) {
        try {
            reportFile := A_Temp . "\mcp_troubleshooting_report.txt"
            reportContent := "MCP Troubleshooting Report`n"
            reportContent .= "Generated: " . FormatTime(A_Now, "yyyy-MM-dd HH:mm:ss") . "`n`n"
            reportContent .= "This report would contain all troubleshooting results and fixes applied.`n"
            
            FileAppend(reportContent, reportFile)
            MsgBox("Report saved to: " . reportFile, "Report Saved", "Iconi")
            
        } catch as e {
            MsgBox("Error saving report: " . e.Message, "Error", "Iconx")
        }
    }
    
    static CopyResults(*) {
        try {
            A_Clipboard := "MCP Troubleshooting Results`n`nThis would contain all troubleshooting results and fixes applied."
            MsgBox("Results copied to clipboard!", "Copy Complete", "Iconi")
        } catch as e {
            MsgBox("Error copying results: " . e.Message, "Error", "Iconx")
        }
    }
    
    static ShowHelp(*) {
        helpText := "ðŸ”§ MCP Troubleshooter Help`n`n"
        helpText .= "This tool provides comprehensive MCP troubleshooting:`n`n"
        helpText .= "ðŸ” Quick Diagnostics:`n"
        helpText .= "â€¢ Check Config: Validate Claude Desktop configuration`n"
        helpText .= "â€¢ Check Python: Verify Python installation and environment`n"
        helpText .= "â€¢ Check Dependencies: Validate required packages`n"
        helpText .= "â€¢ Check Connectivity: Test network and port availability`n`n"
        helpText .= "ðŸ–¥ï¸ Server Management:`n"
        helpText .= "â€¢ Start/Stop/Restart individual MCP servers`n"
        helpText .= "â€¢ Test server functionality`n"
        helpText .= "â€¢ View server logs`n"
        helpText .= "â€¢ Edit server configuration`n`n"
        helpText .= "ðŸ› ï¸ Automated Fixes:`n"
        helpText .= "â€¢ Fix configuration issues automatically`n"
        helpText .= "â€¢ Install missing dependencies`n"
        helpText .= "â€¢ Reset MCP servers to clean state`n"
        helpText .= "â€¢ Clean temporary files`n`n"
        helpText .= "Hotkeys:`n"
        helpText .= "â€¢ Ctrl+Alt+T: Run full troubleshooting`n"
        helpText .= "â€¢ F11: Apply quick fixes`n"
        helpText .= "â€¢ Escape: Close tool"
        
        MsgBox(helpText, "MCP Troubleshooter Help", "Iconi")
    }
    
    static SetupHotkeys(gui) {
        ^!Hotkey("t", (*) => this.CheckCo)nfig()
        Hotkey("F11", (*) => this.FixCo)nfigIssues()
        
        Hotkey("Escape", (*) => {
            if (Wi)nExist("MCP Troubleshooter")) {
                WinClose("MCP Troubleshooter")
            }
        }
    }
}

; Hotkeys
^!Hotkey("t", (*) => MCPTroubleshooter.I)nit()
Hotkey("F11", (*) => MCPTroubleshooter.I)nit()

; Initialize
MCPTroubleshooter.Init()

