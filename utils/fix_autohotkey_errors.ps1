# AutoHotkey Error Fixer
# Systematically fixes common AutoHotkey v2 compatibility issues

Write-Host "=== AutoHotkey Error Fixer ===" -ForegroundColor Cyan

$scriptlets = Get-ChildItem -Path ".\scriptlets" -Filter "*.ahk"
$fixedCount = 0
$totalFiles = $scriptlets.Count

foreach ($file in $scriptlets) {
    Write-Host "`nFixing: $($file.Name)" -ForegroundColor Yellow
    
    $content = Get-Content $file.FullName -Raw
    $originalContent = $content
    $changes = 0
    
    # Fix 1: Add #Requires AutoHotkey v2.0 if missing
    if ($content -notmatch "#Requires AutoHotkey v2") {
        $content = "#Requires AutoHotkey v2.0`n" + $content
        $changes++
        Write-Host "  + Added #Requires AutoHotkey v2.0 directive" -ForegroundColor Green
    }
    
    # Fix 2: Fix hotkey syntax (:: to Hotkey())
    $hotkeyPattern = '(\w+::)([^`n]+)'
    if ($content -match $hotkeyPattern) {
        $content = $content -replace '(\w+)::([^`n]+)', 'Hotkey("$1", (*) => $2)'
        $changes++
        Write-Host "  + Fixed hotkey syntax" -ForegroundColor Green
    }
    
    # Fix 3: Fix MsgBox syntax
    if ($content -match 'MsgBox\s+([^,]+),([^,]+),([^`n]+)') {
        $content = $content -replace 'MsgBox\s+([^,]+),([^,]+),([^`n]+)', 'MsgBox($1, $2, $3)'
        $changes++
        Write-Host "  + Fixed MsgBox syntax" -ForegroundColor Green
    }
    
    # Fix 4: Fix FormatTime syntax
    if ($content -match 'FormatTime\s+(\w+),,\s*"([^"]+)"') {
        $content = $content -replace 'FormatTime\s+(\w+),,\s*"([^"]+)"', '$1 := FormatTime(A_Now, "$2")'
        $changes++
        Write-Host "  + Fixed FormatTime syntax" -ForegroundColor Green
    }
    
    # Fix 5: Fix FileRead syntax
    if ($content -match 'FileRead\s*\(\s*(\w+)\s*,\s*([^)]+)\s*\)') {
        $content = $content -replace 'FileRead\s*\(\s*(\w+)\s*,\s*([^)]+)\s*\)', '$1 := FileRead($2)'
        $changes++
        Write-Host "  + Fixed FileRead syntax" -ForegroundColor Green
    }
    
    # Fix 6: Fix FileDelete syntax
    if ($content -match 'FileDelete\s*\(\s*([^)]+)\s*\)') {
        $content = $content -replace 'FileDelete\s*\(\s*([^)]+)\s*\)', 'try FileDelete($1)'
        $changes++
        Write-Host "  + Fixed FileDelete syntax" -ForegroundColor Green
    }
    
    # Save changes if any were made
    if ($changes -gt 0) {
        Set-Content -Path $file.FullName -Value $content -Encoding UTF8
        Write-Host "  + Saved $changes changes to $($file.Name)" -ForegroundColor Cyan
        $fixedCount++
    } else {
        Write-Host "  - No changes needed" -ForegroundColor Gray
    }
}

Write-Host "`n=== FIXING COMPLETE ===" -ForegroundColor Green
Write-Host "Files processed: $totalFiles" -ForegroundColor White
Write-Host "Files modified: $fixedCount" -ForegroundColor Yellow
Write-Host "Ready for verification!" -ForegroundColor Cyan
