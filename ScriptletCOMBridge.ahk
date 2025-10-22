; ==============================================================================
; ScriptletCOMBridge.ahk
; HTTP Bridge for HTML Launcher to execute AutoHotkey scriptlets
; Version: 1.0
; Author: Sandra (with Claude assistance)
; ==============================================================================

#Requires AutoHotkey v2.0+
#SingleInstance Force
#Warn All, Off
#Warn LocalSameAsGlobal, Off

SendMode "Input"
SetWorkingDir A_ScriptDir

; ==============================================================================
; INITIALIZATION
; ==============================================================================

; Setup tray menu
A_TrayMenu.Delete()  ; Clear standard menu
A_TrayMenu.Add("Show HTML Launcher", ShowLauncher)
A_TrayMenu.Add("Reload Bridge", ReloadBridge)
A_TrayMenu.Add("Exit Bridge", ExitBridge)
A_TrayMenu.Default := "Show HTML Launcher"
A_TrayMenu.Tip := "Scriptlet COM Bridge v1.0"

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
        Run('powershell.exe -WindowStyle Hidden -ExecutionPolicy Bypass -File "' A_Temp '\scriptlet_server.ps1"', , 'Hide')
        
        TrayTip('HTTP server started on port 8765', 'Scriptlet Bridge', '1')
        
    } catch as e {
        MsgBox('Failed to start HTTP server: ' A_LastError, 'Error', '0x10')
    }
}

CreatePowerShellServer() {
    ; Delete existing server script
    FileDelete(A_Temp '\scriptlet_server.ps1')
    
    ; Define the PowerShell script content using a continuation section
    psScript := ''
    psScript .= "`$listener = New-Object System.Net.HttpListener`n"
    psScript .= "`$listener.Prefixes.Add('http://localhost:8765/')`n"
    psScript .= "`$listener.Start()`n`n"
    psScript .= "while (`$listener.IsListening) {`n"
    psScript .= "    try {`n"
    psScript .= "        `$context = `$listener.GetContext()`n"
    psScript .= "        `$request = `$context.Request`n"
    psScript .= "        `$response = `$context.Response`n`n"
    psScript .= "        # Enable CORS`n"
    psScript .= "        `$response.Headers.Add('Access-Control-Allow-Origin', '*')`n"
    psScript .= "        `$response.Headers.Add('Access-Control-Allow-Methods', 'GET, POST, OPTIONS')`n"
    psScript .= "        `$response.Headers.Add('Access-Control-Allow-Headers', 'Content-Type')`n`n"
    psScript .= "        if (`$request.HttpMethod -eq 'OPTIONS') {`n"
    psScript .= "            `$response.StatusCode = 200`n"
    psScript .= "            `$response.Close()`n"
    psScript .= "            continue`n"
    psScript .= "        }`n`n"
    psScript .= "        `$url = `$request.Url.AbsolutePath`n"
    psScript .= "        `$result = 'Unknown command'`n`n"
    psScript .= "        if (`$url -match '/run/(.+)') {`n"
    psScript .= "            `$scriptName = `$matches[1]`n"
    psScript .= "            `$result = & '" . A_ScriptDir . "\RunScriptlet.bat' `$scriptName`n"
    psScript .= "        } elseif (`$url -match '/stop/(.+)') {`n"
    psScript .= "            `$scriptName = `$matches[1]`n"
    psScript .= "            `$result = & '" . A_ScriptDir . "\StopScriptlet.bat' `$scriptName`n"
    psScript .= "        } elseif (`$url -eq '/status') {`n"
    psScript .= "            `$result = 'Server running'`n"
        psScript .= "        } elseif (`$url -eq '/scriptlets') {`n"
    psScript .= "            `$scriptletsDir = '" . A_ScriptDir . "\scriptlets'`n"
    psScript .= "            `$scriptlets = @()`n"
    psScript .= "            if (Test-Path `$scriptletsDir) {`n"
    psScript .= "                `$files = Get-ChildItem `$scriptletsDir -Filter '*.ahk' -Recurse`n"
    psScript .= "                foreach (`$file in `$files) {`n"
    psScript .= "                    `$scriptlets += @{`n"
    psScript .= "                        id = `$file.BaseName`n"
    psScript .= "                        name = `$file.BaseName -replace '_', ' ' -replace '-', ' '`n"
    psScript .= "                        path = `$file.FullName`n"
    psScript .= "                        category = 'utilities'`n"
    psScript .= "                        enabled = `$true`n"
    psScript .= "                        running = `$false`n"
    psScript .= "                    }`n"
    psScript .= "                }`n"
    psScript .= "            }`n"
    psScript .= "            `$result = (`$scriptlets | ConvertTo-Json -Depth 3)`n"
    psScript .= "        }`n`n"
    psScript .= "        `$buffer = [System.Text.Encoding]::UTF8.GetBytes(`$result)`n"
    psScript .= "        `$response.ContentLength64 = `$buffer.Length`n"
    psScript .= "        `$response.OutputStream.Write(`$buffer, 0, `$buffer.Length)`n"
    psScript .= "        `$response.Close()`n"
    psScript .= "    } catch {`n"
    psScript .= "        Write-Host 'Error: `$(`$_)'`n"
    psScript .= "        if (`$response) { `$response.Close() }`n"
    psScript .= "    }`n"
    psScript .= "}`n`n"
    psScript .= "`$listener.Stop()`n"
    
    ; Write the PowerShell script to file
    FileAppend(psScript, A_Temp '\scriptlet_server.ps1')
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
    batPath := A_ScriptDir '\RunScriptlet.bat'
    scriptContent := ''
    scriptContent .= '@echo off`r`n'
    scriptContent .= 'set SCRIPT_NAME=%1`r`n'
    scriptContent .= 'set AHK_PATH="' . A_AhkPath . '"`r`n'
    scriptContent .= 'set SCRIPT_PATH="' . A_ScriptDir . '\scriptlets\%SCRIPT_NAME%"`r`n`r`n'
    scriptContent .= 'if exist %SCRIPT_PATH% (`r`n'
    scriptContent .= '    start "" %AHK_PATH% %SCRIPT_PATH%`r`n'
    scriptContent .= '    echo SUCCESS: Started %SCRIPT_NAME%`r`n'
    scriptContent .= ') else (`r`n'
    scriptContent .= '    echo ERROR: Script not found - %SCRIPT_NAME%`r`n'
    scriptContent .= ')`r`n'
    
    try {
        ; Ensure we have write permissions
        if (FileExist(batPath)) {
            FileDelete(batPath)
        }
        FileAppend(scriptContent, batPath)
        
        ; Verify the file was created
        if (FileExist(batPath)) {
            LogActivity("Successfully created RunScriptlet.bat")
        } else {
            throw Error("File was not created successfully")
        }
    } catch as e {
        LogActivity("Failed to create RunScriptlet.bat: " . e.Message)
        MsgBox('Failed to create RunScriptlet.bat: ' . e.Message . '`n`nPath: ' . batPath, 'Error', '0x10')
    }
}

CreateStopScript() {
    batPath := A_ScriptDir '\StopScriptlet.bat'
    scriptContent := ''
    scriptContent .= '@echo off`r`n'
    scriptContent .= 'set SCRIPT_NAME=%1`r`n'
    scriptContent .= 'set PROCESS_NAME=%SCRIPT_NAME:.ahk=.exe%`r`n`r`n'
    scriptContent .= 'taskkill /F /IM "%PROCESS_NAME%" 2>nul`r`n'
    scriptContent .= 'if %ERRORLEVEL% EQU 0 (`r`n'
    scriptContent .= '    echo SUCCESS: Stopped %SCRIPT_NAME%`r`n'
    scriptContent .= ') else (`r`n'
    scriptContent .= '    echo INFO: %SCRIPT_NAME% was not running`r`n'
    scriptContent .= ')`r`n'
    
    try {
        ; Ensure we have write permissions
        if (FileExist(batPath)) {
            FileDelete(batPath)
        }
        FileAppend(scriptContent, batPath)
        
        ; Verify the file was created
        if (FileExist(batPath)) {
            LogActivity("Successfully created StopScriptlet.bat")
        } else {
            throw Error("File was not created successfully")
        }
    } catch as e {
        LogActivity("Failed to create StopScriptlet.bat: " . e.Message)
        MsgBox('Failed to create StopScriptlet.bat: ' . e.Message . '`n`nPath: ' . batPath, 'Error', '0x10')
    }
}

; ==============================================================================
; UTILITY FUNCTIONS
; ==============================================================================

LogActivity(message) {
    timestamp := FormatTime(, 'yyyy-MM-dd HH:mm:ss')
    try {
        FileAppend('[' timestamp '] ' message '`n', A_ScriptDir '\bridge.log')
    } catch as e {
        ; If we can't log, show a message box
        MsgBox('Failed to write to log: ' e.Message, 'Error', '0x10')
    }
}

CheckScriptRunning(scriptName) {
    processName := StrReplace(scriptName, ".ahk", ".exe")
    return ProcessExist(processName) > 0
}

; ==============================================================================
; EVENT HANDLERS
; ==============================================================================

ShowLauncher(*) {
    launcherPath := A_ScriptDir '\launcher.html'
    if (FileExist(launcherPath)) {
        try {
            Run(launcherPath)
        } catch as e {
            MsgBox('Failed to open launcher: ' e.Message, 'Error', '0x10')
        }
    } else {
        MsgBox('Launcher file not found: ' launcherPath, 'Error', '0x10')
    }
}

ReloadBridge(*) {
    LogActivity("Bridge reloaded by user")
    Reload()
}

ExitBridge(*) {
    LogActivity("Bridge shutdown by user")
    
    ; Clean up temporary files
    try {
        FileDelete(A_Temp '\scriptlet_server.ps1')
        FileDelete(A_ScriptDir '\RunScriptlet.bat')
        FileDelete(A_ScriptDir '\StopScriptlet.bat')
    } catch as e {
        MsgBox('Failed to clean up temporary files: ' e.Message, 'Warning', '0x30')
    }
    
    ; Stop PowerShell server processes
    try {
        RunWait('taskkill /F /IM "powershell.exe" /FI "WINDOWTITLE eq *scriptlet_server*"', , 'Hide')
    } catch as e {
        ; Continue shutdown even if we can't kill the process
    }
    
    ExitApp()
}

; ==============================================================================
; SCRIPTLET MANAGEMENT CLASS
; ==============================================================================

class ScriptletManager {
    static scriptletPath := A_ScriptDir '\scriptlets\'
    
    RunScript(scriptName, parameters := '') {
        fullPath := this.scriptletPath . scriptName
        
        if (!FileExist(fullPath)) {
            errorMsg := 'ERROR: Script not found - ' . scriptName
            LogActivity(errorMsg)
            return errorMsg
        }
        
        try {
            if (parameters != '') {
                Run('"' A_AhkPath '" "' fullPath '" ' parameters, A_ScriptDir)
            } else {
                Run('"' A_AhkPath '" "' fullPath '"', A_ScriptDir)
            }
            
            successMsg := 'SUCCESS: Started ' . scriptName
            LogActivity(successMsg)
            return successMsg
            
        } catch as e {
            errorMsg := 'ERROR: Failed to start ' . scriptName . ' - ' . e.Message
            LogActivity(errorMsg)
            return errorMsg
        }
    }
    
    StopScript(scriptName) {
        processName := StrReplace(scriptName, '.ahk', '.exe')
        
        try {
            if (ProcessExist(processName)) {
                ProcessClose(processName)
                successMsg := 'SUCCESS: Stopped ' . scriptName
                LogActivity(successMsg)
                return successMsg
            } else {
                infoMsg := 'INFO: ' . scriptName . ' was not running'
                LogActivity(infoMsg)
                return infoMsg
            }
        } catch as e {
            errorMsg := 'ERROR: Failed to stop ' . scriptName . ' - ' . e.Message
            LogActivity(errorMsg)
            return errorMsg
        }
    }
    
    ListRunningScripts() {
        running := ''
        loop files this.scriptletPath '*.ahk' {
            if (CheckScriptRunning(A_LoopFileName)) {
                running .= A_LoopFileName '|'
            }
        }
        return running
    }
    
    GetScriptInfo(scriptName) {
        fullPath := this.scriptletPath . scriptName
        
        if (!FileExist(fullPath)) {
            return 'ERROR: Script not found'
        }
        
        ; Read script for description
        try {
            content := FileRead(fullPath)
            description := 'AutoHotkey Script'
            
            ; Extract description from comments
            if (RegExMatch(content, 'i)^\s*;\s*(.+)', &match)) {
                description := match[1]
            }
            
            ; Check if running
            isRunning := CheckScriptRunning(scriptName) ? 'true' : 'false'
            
            return scriptName '|' description '|' isRunning
            
        } catch as e {
            errorMsg := 'ERROR: Failed to read script - ' . e.Message
            LogActivity(errorMsg)
            return errorMsg
        }
    }
}

; ==============================================================================
; STARTUP MESSAGE
; ==============================================================================

LogActivity("Scriptlet COM Bridge v1.0 started")
TrayTip("Bridge started successfully!`nClick tray icon to open launcher.", "Scriptlet Bridge", '1')
