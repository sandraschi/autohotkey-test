# Batch Scriptlet Debugger and Fixer
# PowerShell script to analyze and fix common AutoHotkey v2 issues

param(
    [string]$ScriptletsPath = ".\scriptlets",
    [switch]$Fix,
    [switch]$Report,
    [switch]$Verbose
)

Write-Host "🔧 AutoHotkey Scriptlet Batch Debugger" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan

# Get all .ahk files
$AhkFiles = Get-ChildItem -Path $ScriptletsPath -Filter "*.ahk" -Recurse

Write-Host "Found $($AhkFiles.Count) AutoHotkey files to analyze" -ForegroundColor Yellow

$TotalIssues = 0
$FixedFiles = 0
$ErrorFiles = 0
$ReportData = @()

foreach ($File in $AhkFiles) {
    Write-Host "`nAnalyzing: $($File.Name)" -ForegroundColor Green
    
    try {
        $Content = Get-Content -Path $File.FullName -Raw -Encoding UTF8
        $OriginalContent = $Content
        $Issues = @()
        
        # Check for FormatTime syntax issues
        if ($Content -match "FormatTime\s+\w+,\s*,") {
            $Issues += "Incorrect FormatTime syntax - use FormatTime(var, , format)"
            if ($Fix) {
                $Content = $Content -replace "FormatTime\s+(\w+),\s*,", "FormatTime(`$1, ,"
            }
        }
        
        # Check for FileRead syntax issues
        if ($Content -match "FileRead\s+\w+,\s*\w+") {
            $Issues += "Incorrect FileRead syntax - use FileRead(content, file)"
            if ($Fix) {
                $Content = $Content -replace "FileRead\s+(\w+),\s*(\w+)", "FileRead(`$1, `$2)"
            }
        }
        
        # Check for MsgBox syntax issues
        if ($Content -match "MsgBox\s+\w+") {
            $Issues += "Incorrect MsgBox syntax - use MsgBox(text, title, options)"
            if ($Fix) {
                $Content = $Content -replace "MsgBox\s+(\w+)", "MsgBox(`$1)"
            }
        }
        
        # Check for hotkey syntax issues
        if ($Content -match "\w+::") {
            $Issues += "Incorrect hotkey syntax - use Hotkey(key, callback)"
        }
        
        # Check for v1 string functions
        if ($Content -match "StringReplace\s*\(") {
            $Issues += "Found StringReplace - use StrReplace() instead"
            if ($Fix) {
                $Content = $Content -replace "StringReplace\s*\(", "StrReplace("
            }
        }
        
        if ($Content -match "StringSplit\s*\(") {
            $Issues += "Found StringSplit - use StrSplit() instead"
            if ($Fix) {
                $Content = $Content -replace "StringSplit\s*\(", "StrSplit("
            }
        }
        
        if ($Content -match "StringLen\s*\(") {
            $Issues += "Found StringLen - use StrLen() instead"
            if ($Fix) {
                $Content = $Content -replace "StringLen\s*\(", "StrLen("
            }
        }
        
        # Check for v1 GUI commands
        if ($Content -match "Gui,") {
            $Issues += "Found Gui, command - use Gui() constructor instead"
        }
        
        if ($Content -match "GuiAdd,") {
            $Issues += "Found GuiAdd, command - use gui.Add() method instead"
        }
        
        if ($Content -match "GuiShow,") {
            $Issues += "Found GuiShow, command - use gui.Show() method instead"
        }
        
        if ($Content -match "GuiClose,") {
            $Issues += "Found GuiClose, command - use gui.Close() method instead"
        }
        
        if ($Content -match "GuiControl,") {
            $Issues += "Found GuiControl, command - use gui control methods instead"
        }
        
        # Additional checks
        if ($Content -notmatch "#Requires AutoHotkey v2\.0") {
            $Issues += "Missing #Requires AutoHotkey v2.0 directive"
        }
        
        if ($Content -notmatch "class\s+\w+") {
            $Issues += "No class definition found"
        }
        
        if ($Content -notmatch "static\s+Init\s*\(") {
            $Issues += "Missing Init() method"
        }
        
        $TotalIssues += $Issues.Count
        
        if ($Issues.Count -gt 0) {
            Write-Host "  Issues found: $($Issues.Count)" -ForegroundColor Red
            if ($Verbose) {
                foreach ($Issue in $Issues) {
                    Write-Host "    - $Issue" -ForegroundColor Red
                }
            }
            
            if ($Fix -and $Content -ne $OriginalContent) {
                Set-Content -Path $File.FullName -Value $Content -Encoding UTF8
                Write-Host "  ✅ Fixed issues in $($File.Name)" -ForegroundColor Green
                $FixedFiles++
            }
        } else {
            Write-Host "  ✅ No issues found" -ForegroundColor Green
        }
        
        # Store report data
        $ReportData += [PSCustomObject]@{
            File = $File.Name
            Path = $File.FullName
            Issues = $Issues.Count
            IssueDetails = $Issues -join "; "
            Status = if ($Issues.Count -eq 0) { "Clean" } else { "Has Issues" }
        }
        
    } catch {
        Write-Host "  ❌ Error processing file: $($_.Exception.Message)" -ForegroundColor Red
        $ErrorFiles++
    }
}

# Generate summary
Write-Host "`n📊 Analysis Summary" -ForegroundColor Cyan
Write-Host "===================" -ForegroundColor Cyan
Write-Host "Total files analyzed: $($AhkFiles.Count)" -ForegroundColor White
Write-Host "Total issues found: $TotalIssues" -ForegroundColor White
Write-Host "Files with issues: $($ReportData | Where-Object { $_.Issues -gt 0 } | Measure-Object).Count" -ForegroundColor White
Write-Host "Files fixed: $FixedFiles" -ForegroundColor White
Write-Host "Files with errors: $ErrorFiles" -ForegroundColor White

# Generate report if requested
if ($Report) {
    $ReportFile = ".\scriptlet_analysis_report_$(Get-Date -Format 'yyyyMMdd_HHmmss').csv"
    $ReportData | Export-Csv -Path $ReportFile -NoTypeInformation
    Write-Host "`n📋 Report saved to: $ReportFile" -ForegroundColor Green
    
    # Also create a text summary
    $SummaryFile = ".\scriptlet_analysis_summary_$(Get-Date -Format 'yyyyMMdd_HHmmss').txt"
    $Summary = @"
AutoHotkey Scriptlet Analysis Summary
Generated: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')

SUMMARY:
- Total files analyzed: $($AhkFiles.Count)
- Total issues found: $TotalIssues
- Files with issues: $(($ReportData | Where-Object { $_.Issues -gt 0 }).Count)
- Files fixed: $FixedFiles
- Files with errors: $ErrorFiles

DETAILED RESULTS:
"@
    
    foreach ($Item in $ReportData) {
        $Summary += "`nFile: $($Item.File)`n"
        $Summary += "Path: $($Item.Path)`n"
        $Summary += "Issues: $($Item.Issues)`n"
        if ($Item.Issues -gt 0) {
            $Summary += "Details: $($Item.IssueDetails)`n"
        }
        $Summary += "Status: $($Item.Status)`n"
    }
    
    Set-Content -Path $SummaryFile -Value $Summary -Encoding UTF8
    Write-Host "📋 Summary saved to: $SummaryFile" -ForegroundColor Green
}

Write-Host "`n✅ Analysis complete!" -ForegroundColor Green
