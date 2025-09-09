; ==============================================================================
; ScriptletCOMBridge.ahk
; HTTP Bridge for HTML Launcher to execute AutoHotkey scriptlets
; Version: 1.0
; Author: Sandra (with Claude assistance)
; ==============================================================================

#NoEnv
#SingleInstance Force
#Persistent
SendMode Input
SetWorkingDir %A_ScriptDir%

; ==============================================================================
; INITIALIZATION
; ==============================================================================

; Setup tray menu
Menu, Tray, NoStandard
Menu, Tray, Add, Show HTML Launcher, ShowLauncher
Menu, Tray, Add, Reload Bridge, ReloadBridge  
Menu, Tray, Add, Exit Bridge, ExitBridge
Menu, Tray, Default, Show HTML Launcher
Menu, Tray, Tip, Scriptlet COM Bridge v1.0

; Initialize server
StartHTTPServer()

; ==============================================================================
; HTTP SERVER FUNCTIONS
; ==============================================================================

StartHTTPServer() {
    try {
        ; Create helper batch files first
        CreateHelperScripts()
        
        ; Create PowerShell server script
        CreatePowerShellServer()
        
        ; Start PowerShell HTTP server
        Run, powershell.exe -WindowStyle Hidden -ExecutionPolicy Bypass -File "%A_Temp%\scriptlet_server.ps1", , Hide
        
        TrayTip, Scriptlet Bridge, HTTP server started on port 8765, , 1
        
    } catch e {
        MsgBox, 16, Error, Failed to start HTTP server: %A_LastError%
    }
}

CreatePowerShellServer() {
    ; Delete existing server script
    FileDelete, %A_Temp%\scriptlet_server.ps1
    
    ; Write PowerShell server script line by line to avoid escaping issues
    FileAppend, $listener = New-Object System.Net.HttpListener`n, %A_Temp%\scriptlet_server.ps1
    FileAppend, $listener.Prefixes.Add('http://localhost:8765/')`n, %A_Temp%\scriptlet_server.ps1
    FileAppend, $listener.Start()`n, %A_Temp%\scriptlet_server.ps1
    FileAppend, `n, %A_Temp%\scriptlet_server.ps1
    FileAppend, while ($listener.IsListening) {`n, %A_Temp%\scriptlet_server.ps1
    FileAppend, `    try {`n, %A_Temp%\scriptlet_server.ps1
    FileAppend, `        $context = $listener.GetContext()`n, %A_Temp%\scriptlet_server.ps1
    FileAppend, `        $request = $context.Request`n, %A_Temp%\scriptlet_server.ps1
    FileAppend, `        $response = $context.Response`n, %A_Temp%\scriptlet_server.ps1
    FileAppend, `        `n, %A_Temp%\scriptlet_server.ps1
    FileAppend, `        # Enable CORS`n, %A_Temp%\scriptlet_server.ps1
    FileAppend, `        $response.Headers.Add('Access-Control-Allow-Origin', '*')`n, %A_Temp%\scriptlet_server.ps1
    FileAppend, `        $response.Headers.Add('Access-Control-Allow-Methods', 'GET, POST, OPTIONS')`n, %A_Temp%\scriptlet_server.ps1
    FileAppend, `        $response.Headers.Add('Access-Control-Allow-Headers', 'Content-Type')`n, %A_Temp%\scriptlet_server.ps1
    FileAppend, `        `n, %A_Temp%\scriptlet_server.ps1
    FileAppend, `        if ($request.HttpMethod -eq 'OPTIONS') {`n, %A_Temp%\scriptlet_server.ps1
    FileAppend, `            $response.StatusCode = 200`n, %A_Temp%\scriptlet_server.ps1
    FileAppend, `            $response.Close()`n, %A_Temp%\scriptlet_server.ps1
    FileAppend, `            continue`n, %A_Temp%\scriptlet_server.ps1
    FileAppend, `        }`n, %A_Temp%\scriptlet_server.ps1
    FileAppend, `        `n, %A_Temp%\scriptlet_server.ps1
    FileAppend, `        $url = $request.Url.AbsolutePath`n, %A_Temp%\scriptlet_server.ps1
    FileAppend, `        $result = 'Unknown command'`n, %A_Temp%\scriptlet_server.ps1
    FileAppend, `        `n, %A_Temp%\scriptlet_server.ps1
    FileAppend, `        if ($url -match '/run/(.+)') {`n, %A_Temp%\scriptlet_server.ps1
    FileAppend, `            $scriptName = $matches[1]`n, %A_Temp%\scriptlet_server.ps1
    FileAppend, `            $result = & 'C:\Users\sandr\OneDrive\SW\Autohotkey\RunScriptlet.bat' $scriptName`n, %A_Temp%\scriptlet_server.ps1
    FileAppend, `        } elseif ($url -match '/stop/(.+)') {`n, %A_Temp%\scriptlet_server.ps1
    FileAppend, `            $scriptName = $matches[1]`n, %A_Temp%\scriptlet_server.ps1
    FileAppend, `            $result = & 'C:\Users\sandr\OneDrive\SW\Autohotkey\StopScriptlet.bat' $scriptName`n, %A_Temp%\scriptlet_server.ps1
    FileAppend, `        } elseif ($url -eq '/status') {`n, %A_Temp%\scriptlet_server.ps1
    FileAppend, `            $result = 'Server running'`n, %A_Temp%\scriptlet_server.ps1
    FileAppend, `        }`n, %A_Temp%\scriptlet_server.ps1
    FileAppend, `        `n, %A_Temp%\scriptlet_server.ps1
    FileAppend, `        $buffer = [System.Text.Encoding]::UTF8.GetBytes($result)`n, %A_Temp%\scriptlet_server.ps1
    FileAppend, `        $response.ContentLength64 = $buffer.Length`n, %A_Temp%\scriptlet_server.ps1
    FileAppend, `        $response.OutputStream.Write($buffer, 0, $buffer.Length)`n, %A_Temp%\scriptlet_server.ps1
    FileAppend, `        $response.Close()`n, %A_Temp%\scriptlet_server.ps1
    FileAppend, `        `n, %A_Temp%\scriptlet_server.ps1
    FileAppend, `    } catch {`n, %A_Temp%\scriptlet_server.ps1
    FileAppend, `        Write-Host "Error: $_"`n, %A_Temp%\scriptlet_server.ps1
    FileAppend, `        if ($response) { $response.Close() }`n, %A_Temp%\scriptlet_server.ps1
    FileAppend, `    }`n, %A_Temp%\scriptlet_server.ps1
    FileAppend, }`n, %A_Temp%\scriptlet_server.ps1
    FileAppend, `n, %A_Temp%\scriptlet_server.ps1
    FileAppend, $listener.Stop()`n, %A_Temp%\scriptlet_server.ps1
}

; ==============================================================================
; HELPER SCRIPT CREATION
; ==============================================================================

CreateHelperScripts() {
    ; Create RunScriptlet.bat
    CreateRunScript()
    
    ; Create StopScriptlet.bat  
    CreateStopScript()
}

CreateRunScript() {
    FileDelete, %A_ScriptDir%\RunScriptlet.bat
    FileAppend, @echo off`n, %A_ScriptDir%\RunScriptlet.bat
    FileAppend, set SCRIPT_NAME=`%1`n, %A_ScriptDir%\RunScriptlet.bat
    FileAppend, set AHK_PATH="C:\Program Files\AutoHotkey\AutoHotkey.exe"`n, %A_ScriptDir%\RunScriptlet.bat
    FileAppend, set SCRIPT_PATH="C:\Users\sandr\OneDrive\SW\Autohotkey\scriptlets\`%SCRIPT_NAME`%"`n, %A_ScriptDir%\RunScriptlet.bat
    FileAppend, `n, %A_ScriptDir%\RunScriptlet.bat
    FileAppend, if exist `%SCRIPT_PATH`% (`n, %A_ScriptDir%\RunScriptlet.bat
    FileAppend, `    start "" `%AHK_PATH`% `%SCRIPT_PATH`%`n, %A_ScriptDir%\RunScriptlet.bat
    FileAppend, `    echo SUCCESS: Started `%SCRIPT_NAME`%`n, %A_ScriptDir%\RunScriptlet.bat
    FileAppend, ) else (`n, %A_ScriptDir%\RunScriptlet.bat
    FileAppend, `    echo ERROR: Script not found - `%SCRIPT_NAME`%`n, %A_ScriptDir%\RunScriptlet.bat
    FileAppend, )`n, %A_ScriptDir%\RunScriptlet.bat
}

CreateStopScript() {
    FileDelete, %A_ScriptDir%\StopScriptlet.bat
    FileAppend, @echo off`n, %A_ScriptDir%\StopScriptlet.bat
    FileAppend, set SCRIPT_NAME=`%1`n, %A_ScriptDir%\StopScriptlet.bat
    FileAppend, set PROCESS_NAME=`%SCRIPT_NAME:.ahk=.exe`%`n, %A_ScriptDir%\StopScriptlet.bat
    FileAppend, `n, %A_ScriptDir%\StopScriptlet.bat
    FileAppend, taskkill /F /IM "`%PROCESS_NAME`%" 2>nul`n, %A_ScriptDir%\StopScriptlet.bat
    FileAppend, if `%ERRORLEVEL`% EQU 0 (`n, %A_ScriptDir%\StopScriptlet.bat
    FileAppend, `    echo SUCCESS: Stopped `%SCRIPT_NAME`%`n, %A_ScriptDir%\StopScriptlet.bat
    FileAppend, ) else (`n, %A_ScriptDir%\StopScriptlet.bat
    FileAppend, `    echo INFO: `%SCRIPT_NAME`% was not running`n, %A_ScriptDir%\StopScriptlet.bat
    FileAppend, )`n, %A_ScriptDir%\StopScriptlet.bat
}

; ==============================================================================
; UTILITY FUNCTIONS
; ==============================================================================

LogActivity(message) {
    FormatTime, timestamp,, yyyy-MM-dd HH:mm:ss
    FileAppend, [%timestamp%] %message%`n, %A_ScriptDir%\bridge.log
}

CheckScriptRunning(scriptName) {
    processName := StrReplace(scriptName, ".ahk", ".exe")
    Process, Exist, %processName%
    return ErrorLevel > 0
}

; ==============================================================================
; EVENT HANDLERS
; ==============================================================================

ShowLauncher:
    launcherPath := A_ScriptDir . "\launcher.html"
    if (FileExist(launcherPath)) {
        Run, "%launcherPath%"
    } else {
        MsgBox, 16, Error, Launcher file not found: %launcherPath%
    }
return

ReloadBridge:
    LogActivity("Bridge reloaded by user")
    Reload
return

ExitBridge:
    LogActivity("Bridge shutdown by user")
    
    ; Clean up temporary files
    FileDelete, %A_Temp%\scriptlet_server.ps1
    FileDelete, %A_ScriptDir%\RunScriptlet.bat
    FileDelete, %A_ScriptDir%\StopScriptlet.bat
    
    ; Stop PowerShell server processes
    RunWait, taskkill /F /IM "powershell.exe" /FI "WINDOWTITLE eq *scriptlet_server*", , Hide
    
    ExitApp
return

; ==============================================================================
; SCRIPTLET MANAGEMENT CLASS
; ==============================================================================

class ScriptletManager {
    
    static scriptletPath := A_ScriptDir . "\scriptlets\"
    
    RunScript(scriptName, parameters := "") {
        fullPath := this.scriptletPath . scriptName
        
        if (!FileExist(fullPath)) {
            LogActivity("ERROR: Script not found - " . scriptName)
            return "ERROR: Script not found - " . scriptName
        }
        
        try {
            if (parameters != "") {
                Run, "%A_AhkPath%" "%fullPath%" %parameters%, %A_ScriptDir%
            } else {
                Run, "%A_AhkPath%" "%fullPath%", %A_ScriptDir%
            }
            
            LogActivity("SUCCESS: Started " . scriptName)
            return "SUCCESS: Started " . scriptName
            
        } catch e {
            errorMsg := "ERROR: Failed to start " . scriptName . " - " . A_LastError
            LogActivity(errorMsg)
            return errorMsg
        }
    }
    
    StopScript(scriptName) {
        processName := StrReplace(scriptName, ".ahk", ".exe")
        
        Process, Close, %processName%
        if (ErrorLevel) {
            LogActivity("SUCCESS: Stopped " . scriptName)
            return "SUCCESS: Stopped " . scriptName
        } else {
            LogActivity("INFO: " . scriptName . " was not running")
            return "INFO: " . scriptName . " was not running"
        }
    }
    
    ListRunningScripts() {
        running := ""
        Loop, Files, % this.scriptletPath . "*.ahk"
        {
            scriptName := A_LoopFileName
            if (CheckScriptRunning(scriptName)) {
                running .= scriptName . "|"
            }
        }
        return running
    }
    
    GetScriptInfo(scriptName) {
        fullPath := this.scriptletPath . scriptName
        
        if (!FileExist(fullPath)) {
            return "ERROR: Script not found"
        }
        
        ; Read script for description
        FileRead, content, %fullPath%
        description := "AutoHotkey Script"
        
        ; Extract description from comments
        if (RegExMatch(content, "i)^\s*;\s*(.+)", match)) {
            description := match1
        }
        
        ; Check if running
        isRunning := CheckScriptRunning(scriptName) ? "true" : "false"
        
        return scriptName . "|" . description . "|" . isRunning
    }
}

; ==============================================================================
; STARTUP MESSAGE
; ==============================================================================

LogActivity("Scriptlet COM Bridge v1.0 started")
TrayTip, Scriptlet Bridge, Bridge started successfully!`nClick tray icon to open launcher., , 1
