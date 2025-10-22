$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add('http://localhost:8765/')
$listener.Start()

Write-Host "Server started on port 8765"

while ($listener.IsListening) {
    try {
        $context = $listener.GetContext()
        $request = $context.Request
        $response = $context.Response

        # Enable CORS
        $response.Headers.Add('Access-Control-Allow-Origin', '*')
        $response.Headers.Add('Access-Control-Allow-Methods', 'GET, POST, OPTIONS')
        $response.Headers.Add('Access-Control-Allow-Headers', 'Content-Type')

        if ($request.HttpMethod -eq 'OPTIONS') {
            $response.StatusCode = 200
            $response.Close()
            continue
        }

        $url = $request.Url.AbsolutePath
        $result = 'Unknown command'

        if ($url -eq '/status') {
            $result = 'Server running'
        } elseif ($url -eq '/scriptlets') {
            $scriptletsDir = "D:\Dev\repos\autohotkey-test\scriptlets"
            $scriptlets = @()
            if (Test-Path $scriptletsDir) {
                $files = Get-ChildItem $scriptletsDir -Filter '*.ahk' -Recurse
                foreach ($file in $files) {
                    $scriptlets += @{
                        id = $file.BaseName
                        name = $file.BaseName -replace '_', ' ' -replace '-', ' '
                        path = $file.FullName
                        category = 'utilities'
                        enabled = $true
                        running = $false
                    }
                }
            }
            $result = ($scriptlets | ConvertTo-Json -Depth 3)
        } elseif ($url -match '/run/(.+)') {
            $scriptName = $matches[1]
            try {
                $batchFile = "D:\Dev\repos\autohotkey-test\RunScriptlet.bat"
                if (Test-Path $batchFile) {
                    $result = & $batchFile $scriptName
                } else {
                    $result = "Error: RunScriptlet.bat not found"
                }
            } catch {
                $result = "Error running scriptlet: $($_.Exception.Message)"
            }
        } elseif ($url -match '/stop/(.+)') {
            $scriptName = $matches[1]
            try {
                $batchFile = "D:\Dev\repos\autohotkey-test\StopScriptlet.bat"
                if (Test-Path $batchFile) {
                    $result = & $batchFile $scriptName
                } else {
                    $result = "Error: StopScriptlet.bat not found"
                }
            } catch {
                $result = "Error stopping scriptlet: $($_.Exception.Message)"
            }
        }

        $buffer = [System.Text.Encoding]::UTF8.GetBytes($result)
        $response.ContentLength64 = $buffer.Length
        $response.OutputStream.Write($buffer, 0, $buffer.Length)
        $response.Close()
    } catch {
        Write-Host "Error: $($_.Exception.Message)"
        if ($response) { $response.Close() }
    }
}

$listener.Stop()
Write-Host "Server stopped."
