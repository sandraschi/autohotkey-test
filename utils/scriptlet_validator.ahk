; ==============================================================================
; Scriptlet Validation and Testing Tool
; @name: Scriptlet Validator
; @version: 1.0.0
; @description: Comprehensive validation and testing for AutoHotkey scriptlets
; @category: development
; @author: Sandra
; @hotkeys: ^!v
; @enabled: true
; ==============================================================================

#Requires AutoHotkey v2.0+
#SingleInstance Force
#Warn

class ScriptletValidator {
    static scriptletsDir := A_ScriptDir "\..\scriptlets"
    static validationResults := []
    static totalFiles := 0
    static validFiles := 0
    static invalidFiles := 0
    
    static Init() {
        this.CreateGUI()
        this.RunValidation()
    }
    
    static CreateGUI() {
        gui := Gui("+Resize +MinSize900x700", "Scriptlet Validator")
        gui.BackColor := "0x1a1a1a"
        gui.SetFont("s10 cWhite", "Segoe UI")
        
        ; Title
        gui.Add("Text", "x20 y20 w860 Center Bold", "🔍 Scriptlet Validator & Tester")
        gui.Add("Text", "x20 y50 w860 Center c0xcccccc", "Comprehensive validation and testing for AutoHotkey scriptlets")
        
        ; Validation controls
        gui.Add("Text", "x20 y90 w860 Bold", "🎯 Validation Controls")
        
        gui.Add("Button", "x20 y120 w150 h40", "🔍 Validate All").OnEvent("Click", this.ValidateAll.Bind(this))
        gui.Add("Button", "x190 y120 w150 h40", "🧪 Test Selected").OnEvent("Click", this.TestSelected.Bind(this))
        gui.Add("Button", "x360 y120 w150 h40", "📊 Generate Report").OnEvent("Click", this.GenerateReport.Bind(this))
        gui.Add("Button", "x530 y120 w150 h40", "🔄 Refresh").OnEvent("Click", this.RunValidation.Bind(this))
        
        ; Statistics
        gui.Add("Text", "x20 y180 w860 Bold", "📈 Validation Statistics")
        
        statsText := gui.Add("Text", "x20 y210 w860 h60 c0xcccccc", "Files: 0 | Valid: 0 | Invalid: 0 | Issues: 0")
        
        ; Results list
        gui.Add("Text", "x20 y290 w860 Bold", "📋 Validation Results")
        
        resultsList := gui.Add("ListBox", "x20 y320 w860 h200")
        resultsList.SetFont("s9 cWhite", "Consolas")
        resultsList.BackColor := "0x2d2d2d"
        
        ; Details panel
        gui.Add("Text", "x20 y540 w860 Bold", "📖 File Details")
        
        detailsText := gui.Add("Edit", "x20 y570 w860 h80 ReadOnly Multi VScroll")
        detailsText.BackColor := "0x2d2d2d"
        detailsText.SetFont("s9 cWhite", "Consolas")
        
        ; Store references
        gui.statsText := statsText
        gui.resultsList := resultsList
        gui.detailsText := detailsText
        
        ; Event handlers
        resultsList.OnEvent("Click", this.ShowFileDetails.Bind(this))
        
        gui.Show("w900 h700")
    }
    
    static RunValidation() {
        ; Get all .ahk files
        files := []
        Loop Files, this.scriptletsDir "\*.ahk", "R" {
            files.Push(A_LoopFilePath)
        }
        
        this.totalFiles := files.Length
        this.validFiles := 0
        this.invalidFiles := 0
        this.validationResults := []
        
        ; Validate each file
        for filePath in files {
            this.ValidateFile(filePath)
        }
        
        this.UpdateResults()
    }
    
    static ValidateFile(filePath) {
        try {
            ; Read file content
            if (!FileExist(filePath)) {
                this.AddResult(filePath, "Error", "File not found", [])
                this.invalidFiles++
                return
            }
            
            fileContent := FileRead(filePath)
            if (!fileContent) {
                this.AddResult(filePath, "Error", "Failed to read file", [])
                this.invalidFiles++
                return
            }
            
            ; Perform validation checks
            issues := this.PerformValidationChecks(filePath, fileContent)
            
            ; Determine status
            hasErrors := false
            hasWarnings := false
            
            for issue in issues {
                if (issue.severity = "Error") {
                    hasErrors := true
                } else if (issue.severity = "Warning") {
                    hasWarnings := true
                }
            }
            
            status := "Valid"
            if (hasErrors) {
                status := "Invalid"
                this.invalidFiles++
            } else {
                this.validFiles++
            }
            
            ; Store result
            this.validationResults.Push({
                file: filePath,
                status: status,
                issues: issues,
                hasErrors: hasErrors,
                hasWarnings: hasWarnings
            })
            
        } catch as e {
            this.AddResult(filePath, "Error", "Validation failed: " . e.Message, [])
            this.invalidFiles++
        }
    }
    
    static PerformValidationChecks(filePath, content) {
        issues := []
        lines := StrSplit(content, "`n")
        
        ; Check 1: AutoHotkey v2 requirement
        if (!InStr(content, "#Requires AutoHotkey v2")) {
            this.AddIssue(issues, "Missing #Requires AutoHotkey v2.0 directive", "Error", 1)
        }
        
        ; Check 2: FormatTime syntax
        for i, line in lines {
            if (RegExMatch(line, "FormatTime\s+\w+,\s*,")) {
                this.AddIssue(issues, "Incorrect FormatTime syntax - use FormatTime(var, , format)", "Error", i)
            }
        }
        
        ; Check 3: FileRead syntax
        for i, line in lines {
            if (RegExMatch(line, "FileRead\s+\w+,\s*\w+")) {
                this.AddIssue(issues, "Incorrect FileRead syntax - use FileRead(content, file)", "Error", i)
            }
        }
        
        ; Check 4: MsgBox syntax
        for i, line in lines {
            if (RegExMatch(line, "MsgBox\s+\w+")) {
                this.AddIssue(issues, "Incorrect MsgBox syntax - use MsgBox(text, title, options)", "Error", i)
            }
        }
        
        ; Check 5: Hotkey syntax
        for i, line in lines {
            if (RegExMatch(line, "^\w+::")) {
                this.AddIssue(issues, "Incorrect hotkey syntax - use Hotkey(key, callback)", "Error", i)
            }
        }
        
        ; Check 6: v1 string functions
        for i, line in lines {
            if (RegExMatch(line, "StringReplace\s*\(")) {
                this.AddIssue(issues, "Found StringReplace - use StrReplace() instead", "Error", i)
            }
            if (RegExMatch(line, "StringSplit\s*\(")) {
                this.AddIssue(issues, "Found StringSplit - use StrSplit() instead", "Error", i)
            }
            if (RegExMatch(line, "StringLen\s*\(")) {
                this.AddIssue(issues, "Found StringLen - use StrLen() instead", "Error", i)
            }
        }
        
        ; Check 7: v1 GUI commands
        for i, line in lines {
            if (RegExMatch(line, "Gui,\s*")) {
                this.AddIssue(issues, "Found Gui, command - use Gui() constructor instead", "Error", i)
            }
            if (RegExMatch(line, "GuiAdd,\s*")) {
                this.AddIssue(issues, "Found GuiAdd, command - use gui.Add() method instead", "Error", i)
            }
            if (RegExMatch(line, "GuiShow,\s*")) {
                this.AddIssue(issues, "Found GuiShow, command - use gui.Show() method instead", "Error", i)
            }
            if (RegExMatch(line, "GuiClose,\s*")) {
                this.AddIssue(issues, "Found GuiClose, command - use gui.Close() method instead", "Error", i)
            }
        }
        
        ; Check 8: Class structure
        if (!RegExMatch(content, "class\s+\w+")) {
            this.AddIssue(issues, "No class definition found", "Warning")
        }
        
        ; Check 9: Init method
        if (!RegExMatch(content, "static\s+Init\s*\(")) {
            this.AddIssue(issues, "Missing Init() method", "Warning")
        }
        
        ; Check 10: Error handling
        if (!InStr(content, "try") && !InStr(content, "catch")) {
            this.AddIssue(issues, "Consider adding error handling with try/catch blocks", "Suggestion")
        }
        
        return issues
    }
    
    static AddIssue(issues, message, severity, line := "") {
        issues.Push({
            message: message,
            severity: severity,
            line: line
        })
    }
    
    static AddResult(filePath, status, message, issues) {
        SplitPath(filePath, &fileName)
        this.validationResults.Push({
            file: fileName,
            status: status,
            issues: [{message: message, severity: "Error", line: ""}],
            hasErrors: status = "Error",
            hasWarnings: false
        })
    }
    
    static UpdateResults() {
        if (WinExist("Scriptlet Validator")) {
            gui := GuiFromHwnd(WinGetID("Scriptlet Validator"))
            
            ; Update statistics
            totalIssues := 0
            for result in this.validationResults {
                totalIssues += result.issues.Length
            }
            
            stats := "Files: " . this.totalFiles . " | Valid: " . this.validFiles . " | Invalid: " . this.invalidFiles . " | Issues: " . totalIssues
            gui.statsText.Text := stats
            
            ; Update results list
            gui.resultsList.Text := ""
            for result in this.validationResults {
                SplitPath(result.file, &fileName)
                
                status := ""
                if (result.hasErrors) {
                    status := "❌ "
                } else if (result.hasWarnings) {
                    status := "⚠️ "
                } else {
                    status := "✅ "
                }
                
                gui.resultsList.Add([status . fileName . " (" . result.issues.Length . " issues)"])
            }
        }
    }
    
    static ShowFileDetails(*) {
        if (WinExist("Scriptlet Validator")) {
            gui := GuiFromHwnd(WinGetID("Scriptlet Validator"))
            selectedIndex := gui.resultsList.Value
            
            if (selectedIndex > 0 && selectedIndex <= this.validationResults.Length) {
                result := this.validationResults[selectedIndex]
                
                details := "File: " . result.file . "`n"
                details .= "Status: " . result.status . "`n"
                details .= "Issues: " . result.issues.Length . "`n`n"
                
                for issue in result.issues {
                    details .= "[" . issue.severity . "] "
                    if (issue.line) {
                        details .= "Line " . issue.line . ": "
                    }
                    details .= issue.message . "`n"
                }
                
                gui.detailsText.Text := details
            }
        }
    }
    
    static ValidateAll(*) {
        this.RunValidation()
    }
    
    static TestSelected(*) {
        if (WinExist("Scriptlet Validator")) {
            gui := GuiFromHwnd(WinGetID("Scriptlet Validator"))
            selectedIndex := gui.resultsList.Value
            
            if (selectedIndex > 0 && selectedIndex <= this.validationResults.Length) {
                result := this.validationResults[selectedIndex]
                
                ; Find the full path
                fullPath := ""
                Loop Files, this.scriptletsDir "\*.ahk", "R" {
                    SplitPath(A_LoopFilePath, &fileName)
                    if (fileName = result.file) {
                        fullPath := A_LoopFilePath
                        break
                    }
                }
                
                if (fullPath) {
                    try {
                        Run('"' . A_AhkPath . '" "' . fullPath . '"')
                        TrayTip("Test Started", "Running " . result.file . " for testing", 2)
                    } catch as e {
                        MsgBox("Failed to run script: " . e.Message, "Error", "Iconx")
                    }
                }
            }
        }
    }
    
    static GenerateReport(*) {
        try {
            reportFile := A_ScriptDir "\validation_report.txt"
            FileDelete(reportFile)
            
            report := "Scriptlet Validation Report`n"
            report .= "Generated: " . FormatTime(A_Now, "yyyy-MM-dd HH:mm:ss") . "`n`n"
            report .= "Summary:`n"
            report .= "- Total Files: " . this.totalFiles . "`n"
            report .= "- Valid Files: " . this.validFiles . "`n"
            report .= "- Invalid Files: " . this.invalidFiles . "`n`n"
            
            report .= "Detailed Results:`n"
            report .= "================`n`n"
            
            for result in this.validationResults {
                SplitPath(result.file, &fileName)
                report .= "File: " . fileName . "`n"
                report .= "Status: " . result.status . "`n"
                report .= "Issues: " . result.issues.Length . "`n"
                
                for issue in result.issues {
                    report .= "  [" . issue.severity . "] "
                    if (issue.line) {
                        report .= "Line " . issue.line . ": "
                    }
                    report .= issue.message . "`n"
                }
                report .= "`n"
            }
            
            FileAppend(report, reportFile, "UTF-8")
            MsgBox("Report generated: " . reportFile, "Report Complete", "Iconi")
            
        } catch as e {
            MsgBox("Error generating report: " . e.Message, "Error", "Iconx")
        }
    }
    
    static SetupHotkeys() {
        ^!v::this.Init()
        
        Escape::{
            if (WinExist("Scriptlet Validator")) {
                WinClose("Scriptlet Validator")
            }
        }
    }
}

; Initialize
ScriptletValidator.Init()
