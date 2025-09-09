; ==============================================================================
; HTTP SERVER & MAIN BRIDGE CLASSES - Part 4 of v2 Bridge
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
            
            this.CreatePowerShellServer()
            
            cmdLine := 'powershell.exe -WindowStyle Hidden -ExecutionPolicy Bypass -File "' . this.serverScript . '"'
            this.logger.Debug("Starting server: " . cmdLine)
            
            this.serverProcess := Run(cmdLine, this.tempPath, "Hide")
            Sleep(2000)
            
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
                ProcessClose(this.serverProcess)
                this.logger.Info("HTTP server stopped (PID: " . this.serverProcess . ")")
            }
            
            this.CleanupTempFiles()
            return {success: true, message: "Server stopped"}
            
        } catch as err {
            errorMsg := "Failed to stop HTTP server: " . err.Message
            this.logger.Error(errorMsg)
            return {success: false, message: errorMsg}
        }
    }
    
    TestConnection() {
        try {
            testCmd := 'powershell -Command "try { $response = Invoke-WebRequest -Uri ''http://' . Config.SERVER_HOST . ':' . Config.SERVER_PORT . '/status'' -TimeoutSec 3; exit 0 } catch { exit 1 }"'
            result := RunWait(testCmd, , "Hide")
            return result = 0
        } catch {
            return false
        }
    }
    
    CreatePowerShellServer() {
        this.serverScript := this.tempPath . "\scriptlet_server.ps1"
        
        if (FileExist(this.serverScript)) {
            FileDelete(this.serverScript)
        }
        
        psScript := '
# Scriptlet Bridge PowerShell HTTP Server v2.0
$ErrorActionPreference = "Continue"
Write-Host "Starting Scriptlet Bridge Server v2.0 on port ' . Config.SERVER_PORT . '..."

try {
    $listener = New-Object System.Net.HttpListener
    $listener.Prefixes.Add("http://' . Config.SERVER_HOST . ':' . Config.SERVER_PORT . '/")
    $listener.Start()
    
    Write-Host "Server listening at http://' . Config.SERVER_HOST . ':' . Config.SERVER_PORT . '/"
    
    while ($listener.IsListening) {
        try {
            $context = $listener.GetContext()
            $request = $context.Request
            $response = $context.Response
            
            $response.Headers.Add("Access-Control-Allow-Origin", "*")
            $response.Headers.Add("Access-Control-Allow-Methods", "GET, POST, OPTIONS")
            $response.Headers.Add("Access-Control-Allow-Headers", "Content-Type")
            $response.ContentType = "application/json; charset=utf-8"
            
            if ($request.HttpMethod -eq "OPTIONS") {
                $response.StatusCode = 200
                $response.Close()
                continue
            }
            
            $url = $request.Url.AbsolutePath
            $method = $request.HttpMethod
            $result = @{success = $false; message = "Unknown endpoint"}
            
            Write-Host "$(Get-Date -Format ''HH:mm:ss'') $method $url"
            
            switch -Regex ($url) {
                "^/run/(.+)" {
                    $scriptName = $matches[1]
                    try {
                        $tempResult = "' . A_Temp . '\bridge_result_$(Get-Random).json"
                        $process = Start-Process -FilePath "' . A_AhkPath . '" -ArgumentList "' . A_ScriptFullPath . '", "run", $scriptName -Wait -WindowStyle Hidden -PassThru
                        
                        if (Test-Path $tempResult) {
                            $bridgeResult = Get-Content $tempResult -Raw | ConvertFrom-Json
                            Remove-Item $tempResult -Force
                            $result = $bridgeResult
                        } else {
                            $result = @{success = $false; message = "No response from bridge"}
                        }
                    } catch {
                        $result = @{success = $false; message = "Error: $($_.Exception.Message)"}
                    }
                }
                
                "^/stop/(.+)" {
                    $scriptName = $matches[1]
                    try {
                        $tempResult = "' . A_Temp . '\bridge_result_$(Get-Random).json"
                        $process = Start-Process -FilePath "' . A_AhkPath . '" -ArgumentList "' . A_ScriptFullPath . '", "stop", $scriptName -Wait -WindowStyle Hidden -PassThru
                        
                        if (Test-Path $tempResult) {
                            $bridgeResult = Get-Content $tempResult -Raw | ConvertFrom-Json
                            Remove-Item $tempResult -Force
                            $result = $bridgeResult
                        } else {
                            $result = @{success = $false; message = "No response from bridge"}
                        }
                    } catch {
                        $result = @{success = $false; message = "Error: $($_.Exception.Message)"}
                    }
                }
                
                "^/status$" {
                    $result = @{
                        success = $true
                        message = "Scriptlet Bridge v' . Config.VERSION . ' - Server running"
                        version = "' . Config.VERSION . '"
                        timestamp = (Get-Date -Format "yyyy-MM-dd HH:mm:ss")
                        server_info = @{
                            host = "' . Config.SERVER_HOST . '"
                            port = ' . Config.SERVER_PORT . '
                            ahk_version = "v2"
                        }
                    }
                }
                
                default {
                    $response.StatusCode = 404
                    $result = @{success = $false; message = "Endpoint not found: $url"}
                }
            }
            
            $jsonResponse = $result | ConvertTo-Json -Depth 10
            $buffer = [System.Text.Encoding]::UTF8.GetBytes($jsonResponse)
            $response.ContentLength64 = $buffer.Length
            $response.OutputStream.Write($buffer, 0, $buffer.Length)
            $response.Close()
            
        } catch {
            Write-Host "Request error: $($_.Exception.Message)"
            if ($response -and !$response.OutputStream.CanWrite) {
                try { $response.Close() } catch { }
            }
        }
    }
} catch {
    Write-Host "Server error: $($_.Exception.Message)"
} finally {
    if ($listener) {
        try { $listener.Stop() } catch { }
        Write-Host "Server stopped"
    }
}
'
        
        FileAppend(psScript, this.serverScript, "UTF-8")
        this.logger.Info("Created PowerShell server script: " . this.serverScript)
    }
    
    CleanupTempFiles() {
        try {
            if (FileExist(this.serverScript)) {
                FileDelete(this.serverScript)
                this.logger.Debug("Deleted server script: " . this.serverScript)
            }
        } catch as err {
            this.logger.Warn("Failed to cleanup temp files: " . err.Message)
        }
    }
}