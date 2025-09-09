# Scriptlet Bridge PowerShell HTTP Server v2.0
$ErrorActionPreference = "Continue"
$ProgressPreference = "SilentlyContinue"

# Configuration
$PORT = 8765
$HOST = "localhost"

Write-Host "Starting Scriptlet Bridge Server v2.0 on port $PORT..."

try {
    $listener = New-Object System.Net.HttpListener
    $listener.Prefixes.Add("http://${HOST}:${PORT}/")
    $listener.Start()
    
    Write-Host "Server listening at http://${HOST}:${PORT}/"
    
    while ($listener.IsListening) {
        try {
            $context = $listener.GetContext()
            $request = $context.Request
            $response = $context.Response
            
            # CORS headers
            $response.Headers.Add("Access-Control-Allow-Origin", "*")
            $response.Headers.Add("Access-Control-Allow-Methods", "GET, POST, OPTIONS")
            $response.Headers.Add("Access-Control-Allow-Headers", "Content-Type")
            $response.ContentType = "application/json; charset=utf-8"
            
            # Handle OPTIONS preflight
            if ($request.HttpMethod -eq "OPTIONS") {
                $response.StatusCode = 200
                $response.Close()
                continue
            }
            
            $url = $request.Url.AbsolutePath
            $method = $request.HttpMethod
            $result = @{success = $false; message = "Unknown endpoint"}
            
            Write-Host "$(Get-Date -Format 'HH:mm:ss') $method $url"
            
            # Route handling
            switch -Regex ($url) {
                "^/run/(.+)" {
                    $scriptName = $matches[1]
                    $result = Invoke-BridgeCommand "run" $scriptName
                }
                
                "^/stop/(.+)" {
                    $scriptName = $matches[1]
                    $result = Invoke-BridgeCommand "stop" $scriptName
                }
                
                "^/list$" {
                    $result = Invoke-BridgeCommand "list"
                }
                
                "^/status$" {
                    $result = @{
                        success = $true
                        message = "Scriptlet Bridge v2.0 - Server running"
                        version = "2.0"
                        timestamp = (Get-Date -Format "yyyy-MM-dd HH:mm:ss")
                        server_info = @{
                            host = $HOST
                            port = $PORT
                            ahk_version = "v2"
                        }
                    }
                }
                
                default {
                    $response.StatusCode = 404
                    $result = @{success = $false; message = "Endpoint not found: $url"}
                }
            }
            
            # Send JSON response
            $jsonResponse = $result | ConvertTo-Json -Depth 10
            $buffer = [System.Text.Encoding]::UTF8.GetBytes($jsonResponse)
            $response.ContentLength64 = $buffer.Length
            $response.OutputStream.Write($buffer, 0, $buffer.Length)
            $response.Close()
            
        } catch {
            Write-Host "Request error: $($_.Exception.Message)"
            if ($response -and -not $response.OutputStream.CanWrite) {
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

# Function to call AutoHotkey bridge
function Invoke-BridgeCommand {
    param($command, $scriptName = "")
    
    try {
        $tempResult = "$env:TEMP\bridge_result_$(Get-Random).json"
        $ahkPath = Get-AutoHotkeyPath
        $bridgeScript = Split-Path $MyInvocation.ScriptName -Parent | Join-Path -ChildPath "ScriptletCOMBridge_v2.ahk"
        
        $arguments = @($bridgeScript, $command)
        if ($scriptName) { $arguments += $scriptName }
        
        $process = Start-Process -FilePath $ahkPath -ArgumentList $arguments -Wait -WindowStyle Hidden -PassThru
        
        if (Test-Path $tempResult) {
            $bridgeResult = Get-Content $tempResult -Raw | ConvertFrom-Json
            Remove-Item $tempResult -Force -ErrorAction SilentlyContinue
            return $bridgeResult
        } else {
            return @{success = $false; message = "No response from AutoHotkey bridge"}
        }
        
    } catch {
        return @{success = $false; message = "Bridge error: $($_.Exception.Message)"}
    }
}

# Function to find AutoHotkey executable
function Get-AutoHotkeyPath {
    $paths = @(
        "C:\Program Files\AutoHotkey\v2\AutoHotkey.exe",
        "C:\Program Files (x86)\AutoHotkey\v2\AutoHotkey.exe",
        "C:\Program Files\AutoHotkey\AutoHotkey.exe"
    )
    
    foreach ($path in $paths) {
        if (Test-Path $path) {
            return $path
        }
    }
    
    # Try to find in PATH
    try {
        $pathResult = Get-Command "AutoHotkey.exe" -ErrorAction SilentlyContinue
        if ($pathResult) {
            return $pathResult.Source
        }
    } catch { }
    
    # Fallback
    return "AutoHotkey.exe"
}