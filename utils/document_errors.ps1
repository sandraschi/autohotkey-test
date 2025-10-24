# Comprehensive AutoHotkey Scriptlet Error Documentation
# PowerShell script to analyze and document all errors found in scriptlets

Write-Host "🔍 AutoHotkey Scriptlet Error Documentation System" -ForegroundColor Cyan
Write-Host "=================================================" -ForegroundColor Cyan

$ScriptletsPath = ".\scriptlets"
$ErrorLogFile = ".\docs\scriptlet_errors_documentation.md"

# Create documentation file
$Documentation = @"
# AutoHotkey Scriptlet Error Documentation

**Generated:** $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')  
**Total Files Analyzed:** 0  
**Total Errors Found:** 0  

## Error Categories

### 1. Syntax Errors (Critical)
These errors prevent the script from running correctly.

### 2. AutoHotkey v1/v2 Migration Issues
These errors occur when v1 syntax is used in v2 files.

### 3. Best Practice Violations
These are warnings about code quality and maintainability.

## Detailed Error Report

"@

Set-Content -Path $ErrorLogFile -Value $Documentation -Encoding UTF8

# Get all .ahk files
$AhkFiles = Get-ChildItem -Path $ScriptletsPath -Filter "*.ahk" -Recurse
$TotalFiles = $AhkFiles.Count
$TotalErrors = 0
$TotalWarnings = 0
$TotalSuggestions = 0

Write-Host "Found $TotalFiles AutoHotkey files to analyze" -ForegroundColor Yellow

$ErrorDetails = @()
$FileResults = @()

foreach ($File in $AhkFiles) {
    Write-Host "`nAnalyzing: $($File.Name)" -ForegroundColor Green
    
    try {
        $Content = Get-Content -Path $File.FullName -Raw -Encoding UTF8
        $Lines = $Content -split "`n"
        $Issues = @()
        
        # Check 1: AutoHotkey v2 requirement
        if ($Content -notmatch "#Requires AutoHotkey v2") {
            $Issues += @{
                Type = "Error"
                Category = "Missing Directive"
                Message = "Missing #Requires AutoHotkey v2.0 directive"
                Line = 1
                Severity = "Critical"
            }
        }
        
        # Check 2: FormatTime syntax
        for ($i = 0; $i -lt $Lines.Length; $i++) {
            $lineNum = $i + 1
            $line = $Lines[$i]
            
            if ($line -match "FormatTime\s+\w+,\s*,") {
                $Issues += @{
                    Type = "Error"
                    Category = "Syntax Error"
                    Message = "Incorrect FormatTime syntax - use FormatTime(var, , format)"
                    Line = $lineNum
                    Severity = "Critical"
                    Example = $line.Trim()
                }
            }
            
            # Check 3: FileRead syntax
            if ($line -match "FileRead\s+\w+,\s*\w+") {
                $Issues += @{
                    Type = "Error"
                    Category = "Syntax Error"
                    Message = "Incorrect FileRead syntax - use FileRead(content, file)"
                    Line = $lineNum
                    Severity = "Critical"
                    Example = $line.Trim()
                }
            }
            
            # Check 4: MsgBox syntax
            if ($line -match "MsgBox\s+\w+") {
                $Issues += @{
                    Type = "Error"
                    Category = "Syntax Error"
                    Message = "Incorrect MsgBox syntax - use MsgBox(text, title, options)"
                    Line = $lineNum
                    Severity = "Critical"
                    Example = $line.Trim()
                }
            }
            
            # Check 5: Hotkey syntax
            if ($line -match "^\w+::") {
                $Issues += @{
                    Type = "Error"
                    Category = "Syntax Error"
                    Message = "Incorrect hotkey syntax - use Hotkey(key, callback)"
                    Line = $lineNum
                    Severity = "Critical"
                    Example = $line.Trim()
                }
            }
            
            # Check 6: String functions
            if ($line -match "StringReplace\s*\(") {
                $Issues += @{
                    Type = "Error"
                    Category = "v1/v2 Migration"
                    Message = "Found StringReplace - use StrReplace() instead"
                    Line = $lineNum
                    Severity = "Critical"
                    Example = $line.Trim()
                }
            }
            
            if ($line -match "StringSplit\s*\(") {
                $Issues += @{
                    Type = "Error"
                    Category = "v1/v2 Migration"
                    Message = "Found StringSplit - use StrSplit() instead"
                    Line = $lineNum
                    Severity = "Critical"
                    Example = $line.Trim()
                }
            }
            
            if ($line -match "StringLen\s*\(") {
                $Issues += @{
                    Type = "Error"
                    Category = "v1/v2 Migration"
                    Message = "Found StringLen - use StrLen() instead"
                    Line = $lineNum
                    Severity = "Critical"
                    Example = $line.Trim()
                }
            }
            
            # Check 7: GUI commands
            if ($line -match "Gui,\s*") {
                $Issues += @{
                    Type = "Error"
                    Category = "v1/v2 Migration"
                    Message = "Found Gui, command - use Gui() constructor instead"
                    Line = $lineNum
                    Severity = "Critical"
                    Example = $line.Trim()
                }
            }
            
            if ($line -match "GuiAdd,\s*") {
                $Issues += @{
                    Type = "Error"
                    Category = "v1/v2 Migration"
                    Message = "Found GuiAdd, command - use gui.Add() method instead"
                    Line = $lineNum
                    Severity = "Critical"
                    Example = $line.Trim()
                }
            }
            
            if ($line -match "GuiShow,\s*") {
                $Issues += @{
                    Type = "Error"
                    Category = "v1/v2 Migration"
                    Message = "Found GuiShow, command - use gui.Show() method instead"
                    Line = $lineNum
                    Severity = "Critical"
                    Example = $line.Trim()
                }
            }
            
            if ($line -match "GuiClose,\s*") {
                $Issues += @{
                    Type = "Error"
                    Category = "v1/v2 Migration"
                    Message = "Found GuiClose, command - use gui.Close() method instead"
                    Line = $lineNum
                    Severity = "Critical"
                    Example = $line.Trim()
                }
            }
            
            if ($line -match "GuiControl,\s*") {
                $Issues += @{
                    Type = "Error"
                    Category = "v1/v2 Migration"
                    Message = "Found GuiControl, command - use gui control methods instead"
                    Line = $lineNum
                    Severity = "Critical"
                    Example = $line.Trim()
                }
            }
            
            # Check 8: Global variables
            if ($line -match "global\s+\w+") {
                $Issues += @{
                    Type = "Warning"
                    Category = "Best Practice"
                    Message = "Found global variable declaration - consider using static or local variables"
                    Line = $lineNum
                    Severity = "Medium"
                    Example = $line.Trim()
                }
            }
            
            # Check 9: Loop syntax
            if ($line -match "Loop\s*,\s*") {
                $Issues += @{
                    Type = "Error"
                    Category = "Syntax Error"
                    Message = "Found Loop, syntax - use Loop or For loop instead"
                    Line = $lineNum
                    Severity = "Critical"
                    Example = $line.Trim()
                }
            }
            
            # Check 10: SetWorkingDir syntax
            if ($line -match "SetWorkingDir\s+\w+") {
                $Issues += @{
                    Type = "Error"
                    Category = "Syntax Error"
                    Message = "Incorrect SetWorkingDir syntax - use SetWorkingDir(path)"
                    Line = $lineNum
                    Severity = "Critical"
                    Example = $line.Trim()
                }
            }
        }
        
        # Count issues by type
        $ErrorCount = ($Issues | Where-Object { $_.Type -eq "Error" }).Count
        $WarningCount = ($Issues | Where-Object { $_.Type -eq "Warning" }).Count
        $SuggestionCount = ($Issues | Where-Object { $_.Type -eq "Suggestion" }).Count
        
        $TotalErrors += $ErrorCount
        $TotalWarnings += $WarningCount
        $TotalSuggestions += $SuggestionCount
        
        if ($Issues.Count -gt 0) {
            Write-Host "  Issues found: $($Issues.Count) (Errors: $ErrorCount, Warnings: $WarningCount)" -ForegroundColor Red
            
            # Add to documentation
            $FileSection = @"

## $($File.Name)

**Path:** $($File.FullName)  
**Issues:** $($Issues.Count) (Errors: $ErrorCount, Warnings: $WarningCount)  

### Issues Found:

"@
            
            foreach ($Issue in $Issues) {
                $FileSection += @"
- **[$($Issue.Severity)] Line $($Issue.Line):** $($Issue.Message)
  - **Category:** $($Issue.Category)
  - **Example:** ``$($Issue.Example)``

"@
            }
            
            Add-Content -Path $ErrorLogFile -Value $FileSection -Encoding UTF8
        } else {
            Write-Host "  ✅ No issues found" -ForegroundColor Green
        }
        
        # Store results
        $FileResults += @{
            File = $File.Name
            Path = $File.FullName
            Issues = $Issues.Count
            Errors = $ErrorCount
            Warnings = $WarningCount
            Suggestions = $SuggestionCount
            Status = if ($ErrorCount -gt 0) { "Has Errors" } elseif ($WarningCount -gt 0) { "Has Warnings" } else { "Clean" }
        }
        
    } catch {
        Write-Host "  ❌ Error processing file: $($_.Exception.Message)" -ForegroundColor Red
        $TotalErrors++
    }
}

# Update summary in documentation
$Summary = @"
# AutoHotkey Scriptlet Error Documentation

**Generated:** $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')  
**Total Files Analyzed:** $TotalFiles  
**Total Errors Found:** $TotalErrors  
**Total Warnings Found:** $TotalWarnings  
**Total Suggestions:** $TotalSuggestions  

## Summary Statistics

- **Files with Errors:** $(($FileResults | Where-Object { $_.Errors -gt 0 }).Count)
- **Files with Warnings:** $(($FileResults | Where-Object { $_.Warnings -gt 0 }).Count)
- **Clean Files:** $(($FileResults | Where-Object { $_.Status -eq "Clean" }).Count)

## Error Categories

### 1. Syntax Errors (Critical)
These errors prevent the script from running correctly.

### 2. AutoHotkey v1/v2 Migration Issues
These errors occur when v1 syntax is used in v2 files.

### 3. Best Practice Violations
These are warnings about code quality and maintainability.

## Detailed Error Report

"@

Set-Content -Path $ErrorLogFile -Value $Summary -Encoding UTF8

# Add file results to documentation
$FileResults | Sort-Object -Property Errors -Descending | ForEach-Object {
    $FileSection = @"

## $($_.File)

**Path:** $($_.Path)  
**Status:** $($_.Status)  
**Issues:** $($_.Issues) (Errors: $($_.Errors), Warnings: $($_.Warnings), Suggestions: $($_.Suggestions))  

"@
    Add-Content -Path $ErrorLogFile -Value $FileSection -Encoding UTF8
}

# Generate summary
Write-Host "`n📊 Analysis Complete!" -ForegroundColor Cyan
Write-Host "===================" -ForegroundColor Cyan
Write-Host "Total files analyzed: $TotalFiles" -ForegroundColor White
Write-Host "Total errors found: $TotalErrors" -ForegroundColor Red
Write-Host "Total warnings found: $TotalWarnings" -ForegroundColor Yellow
Write-Host "Total suggestions: $TotalSuggestions" -ForegroundColor Green
Write-Host "`n📋 Documentation saved to: $ErrorLogFile" -ForegroundColor Green

Write-Host "`n✅ Error documentation complete!" -ForegroundColor Green
