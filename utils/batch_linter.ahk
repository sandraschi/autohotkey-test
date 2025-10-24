; ==============================================================================
; Batch Scriptlet Linter and Debugger
; @name: Batch Scriptlet Linter
; @version: 1.0.0
; @description: Comprehensive batch analysis and debugging for all scriptlets
; @category: development
; @author: Sandra
; @hotkeys: ^!b
; @enabled: true
; ==============================================================================

#Requires AutoHotkey v2.0+
#SingleInstance Force
#Warn

class BatchLinter {
    static scriptletsDir := A_ScriptDir "\..\scriptlets"
    static results := []
    static totalFiles := 0
    static processedFiles := 0
    static errors := 0
    static warnings := 0
    static suggestions := 0
    
    static Init() {
        this.CreateGUI()
        this.ScanScriptlets()
    }
    
    static CreateGUI() {
        gui := Gui("+Resize +MinSize1000x700", "Batch Scriptlet Linter")
        gui.BackColor := "0x1a1a1a"
        gui.SetFont("s10 cWhite", "Segoe UI")
        
        ; Title
        gui.Add("Text", "x20 y20 w960 Center Bold", "🔧 Batch Scriptlet Linter & Debugger")
        gui.Add("Text", "x20 y50 w960 Center c0xcccccc", "Comprehensive analysis and debugging for all AutoHotkey scriptlets")
        
        ; Progress section
        gui.Add("Text", "x20 y90 w960 Bold", "📊 Analysis Progress")
        
        progressText := gui.Add("Text", "x20 y120 w960", "Ready to scan scriptlets...")
        progressBar := gui.Add("Progress", "x20 y150 w960 h20")
        
        ; Statistics
        gui.Add("Text", "x20 y190 w960 Bold", "📈 Statistics")
        
        statsText := gui.Add("Text", "x20 y220 w960 h60 c0xcccccc", "Files: 0 | Errors: 0 | Warnings: 0 | Suggestions: 0")
        
        ; Control buttons
        gui.Add("Button", "x20 y300 w150 h40", "🔍 Scan All").OnEvent("Click", this.ScanAll.Bind(this))
        gui.Add("Button", "x190 y300 w150 h40", "🔧 Fix Common Issues").OnEvent("Click", this.FixCommonIssues.Bind(this))
        gui.Add("Button", "x360 y300 w150 h40", "📋 Generate Report").OnEvent("Click", this.GenerateReport.Bind(this))
        gui.Add("Button", "x530 y300 w150 h40", "🧹 Clean Up").OnEvent("Click", this.CleanUp.Bind(this))
        
        ; Results display
        gui.Add("Text", "x20 y360 w960 Bold", "📋 Analysis Results")
        
        resultsList := gui.Add("ListBox", "x20 y390 w960 h200")
        resultsList.SetFont("s9 cWhite", "Consolas")
        resultsList.BackColor := "0x2d2d2d"
        
        ; Details panel
        gui.Add("Text", "x20 y610 w960 Bold", "📖 File Details")
        
        detailsText := gui.Add("Edit", "x20 y640 w960 h40 ReadOnly Multi VScroll")
        detailsText.BackColor := "0x2d2d2d"
        detailsText.SetFont("s9 cWhite", "Consolas")
        
        ; Store references
        gui.progressText := progressText
        gui.progressBar := progressBar
        gui.statsText := statsText
        gui.resultsList := resultsList
        gui.detailsText := detailsText
        
        ; Event handlers
        resultsList.OnEvent("Click", this.ShowFileDetails.Bind(this))
        
        gui.Show("w1000 h700")
    }
    
    static ScanScriptlets() {
        ; Get all .ahk files in scriptlets directory
        files := []
        Loop Files, this.scriptletsDir "\*.ahk", "R" {
            files.Push(A_LoopFilePath)
        }
        
        this.totalFiles := files.Length
        this.processedFiles := 0
        this.errors := 0
        this.warnings := 0
        this.suggestions := 0
        this.results := []
        
        ; Update progress
        this.UpdateProgress("Scanning " . this.totalFiles . " scriptlets...")
        
        ; Process each file
        for filePath in files {
            this.ProcessFile(filePath)
            this.processedFiles++
            this.UpdateProgress("Processing " . this.processedFiles . "/" . this.totalFiles . " files...")
        }
        
        this.UpdateProgress("Analysis complete!")
        this.UpdateResults()
    }
    
    static ProcessFile(filePath) {
        try {
            ; Read file content
            if (!FileExist(filePath)) {
                this.AddResult(filePath, "Error", "File not found")
                this.errors++
                return
            }
            
            fileContent := FileRead(filePath)
            if (!fileContent) {
                this.AddResult(filePath, "Error", "Failed to read file")
                this.errors++
                return
            }
            
            ; Analyze file
            issues := this.AnalyzeFile(filePath, fileContent)
            
            ; Count issues
            for issue in issues {
                switch issue.severity {
                    case "Error":
                        this.errors++
                    case "Warning":
                        this.warnings++
                    case "Suggestion":
                        this.suggestions++
                }
            }
            
            ; Store results
            this.results.Push({
                file: filePath,
                issues: issues,
                hasErrors: issues.Length > 0 && issues.Has("Error"),
                hasWarnings: issues.Length > 0 && issues.Has("Warning")
            })
            
        } catch as e {
            this.AddResult(filePath, "Error", "Analysis failed: " . e.Message)
            this.errors++
        }
    }
    
    static AnalyzeFile(filePath, content) {
        issues := []
        lines := StrSplit(content, "`n")
        
        ; Check 1: Required directives
        if (!InStr(content, "#Requires AutoHotkey v2.0")) {
            this.AddIssue(issues, "Missing #Requires AutoHotkey v2.0 directive", "Error", 1)
        }
        
        ; Check 2: Class definition pattern
        if (!RegExMatch(content, "class\s+(\w+)")) {
            this.AddIssue(issues, "No class definition found", "Warning")
        }
        
        ; Check 3: Static properties
        requiredProps := ["name", "description", "category"]
        for prop in requiredProps {
            if (!RegExMatch(content, "static\s+" prop "\s*:=\s*")) {
                this.AddIssue(issues, "Missing static property: " . prop, "Warning")
            }
        }
        
        ; Check 4: Init method
        if (!RegExMatch(content, "static\s+Init\s*\([^)]*\)")) {
            this.AddIssue(issues, "Missing Init() method", "Error")
        }
        
        ; Check 5: Syntax issues
        this.CheckSyntaxIssues(issues, lines)
        
        ; Check 6: Common AutoHotkey v2 issues
        this.CheckV2Issues(issues, content)
        
        ; Check 7: Error handling
        if (!InStr(content, "try") && !InStr(content, "catch")) {
            this.AddIssue(issues, "Consider adding error handling with try/catch blocks", "Suggestion")
        }
        
        return issues
    }
    
    static CheckSyntaxIssues(issues, lines) {
        for i, line in lines {
            lineNum := i
            trimmed := Trim(line)
            
            ; Check for common syntax errors
            if (RegExMatch(trimmed, "FormatTime\s+\w+,\s*,")) {
                this.AddIssue(issues, "Incorrect FormatTime syntax - use FormatTime(var, , format)", "Error", lineNum)
            }
            
            if (RegExMatch(trimmed, "FileRead\s+\w+,\s*\w+")) {
                this.AddIssue(issues, "Incorrect FileRead syntax - use FileRead(content, file)", "Error", lineNum)
            }
            
            if (RegExMatch(trimmed, "MsgBox\s+\w+")) {
                this.AddIssue(issues, "Incorrect MsgBox syntax - use MsgBox(text, title, options)", "Error", lineNum)
            }
            
            if (RegExMatch(trimmed, "Hotkey\s+\w+::")) {
                this.AddIssue(issues, "Incorrect hotkey syntax - use Hotkey(key, callback)", "Error", lineNum)
            }
            
            ; Check for missing semicolons in some contexts
            if (RegExMatch(trimmed, "^\w+\s*:=\s*[^;]+$") && !InStr(trimmed, "`"") && !InStr(trimmed, "'")) {
                this.AddIssue(issues, "Consider adding semicolon at end of statement", "Suggestion", lineNum)
            }
        }
    }
    
    static CheckV2Issues(issues, content) {
        ; Check for v1 syntax that needs updating
        v1Patterns := [
            {pattern: "Gui,", message: "Use Gui() constructor instead of Gui, command", severity: "Error"},
            {pattern: "GuiAdd,", message: "Use gui.Add() method instead of GuiAdd command", severity: "Error"},
            {pattern: "GuiShow,", message: "Use gui.Show() method instead of GuiShow command", severity: "Error"},
            {pattern: "GuiClose,", message: "Use gui.Close() method instead of GuiClose command", severity: "Error"},
            {pattern: "GuiControl,", message: "Use gui control methods instead of GuiControl command", severity: "Error"},
            {pattern: "StringReplace,", message: "Use StrReplace() function instead of StringReplace command", severity: "Error"},
            {pattern: "StringSplit,", message: "Use StrSplit() function instead of StringSplit command", severity: "Error"},
            {pattern: "StringLen,", message: "Use StrLen() function instead of StringLen command", severity: "Error"},
            {pattern: "InStr(", message: "Check InStr() syntax - parameters may need adjustment", severity: "Warning"},
            {pattern: "RegExMatch(", message: "Check RegExMatch() syntax - parameters may need adjustment", severity: "Warning"}
        ]
        
        for pattern in v1Patterns {
            if (InStr(content, pattern.pattern)) {
                this.AddIssue(issues, pattern.message, pattern.severity)
            }
        }
    }
    
    static AddIssue(issues, message, severity, line := "") {
        issues.Push({
            message: message,
            severity: severity,
            line: line
        })
    }
    
    static AddResult(filePath, severity, message) {
        ; Extract filename from path
        SplitPath(filePath, &fileName)
        this.results.Push({
            file: fileName,
            issues: [{message: message, severity: severity, line: ""}],
            hasErrors: severity = "Error",
            hasWarnings: severity = "Warning"
        })
    }
    
    static UpdateProgress(message) {
        if (WinExist("Batch Scriptlet Linter")) {
            gui := GuiFromHwnd(WinGetID("Batch Scriptlet Linter"))
            gui.progressText.Text := message
            
            if (this.totalFiles > 0) {
                progress := (this.processedFiles / this.totalFiles) * 100
                gui.progressBar.Value := progress
            }
        }
    }
    
    static UpdateResults() {
        if (WinExist("Batch Scriptlet Linter")) {
            gui := GuiFromHwnd(WinGetID("Batch Scriptlet Linter"))
            
            ; Update statistics
            stats := "Files: " . this.processedFiles . " | Errors: " . this.errors . " | Warnings: " . this.warnings . " | Suggestions: " . this.suggestions
            gui.statsText.Text := stats
            
            ; Update results list
            gui.resultsList.Text := ""
            for result in this.results {
                fileName := ""
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
        if (WinExist("Batch Scriptlet Linter")) {
            gui := GuiFromHwnd(WinGetID("Batch Scriptlet Linter"))
            selectedIndex := gui.resultsList.Value
            
            if (selectedIndex > 0 && selectedIndex <= this.results.Length) {
                result := this.results[selectedIndex]
                
                details := "File: " . result.file . "`n`n"
                details .= "Issues found: " . result.issues.Length . "`n`n"
                
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
    
    static ScanAll(*) {
        this.ScanScriptlets()
    }
    
    static FixCommonIssues(*) {
        ; This would implement automatic fixes for common issues
        MsgBox("Auto-fix functionality would be implemented here", "Fix Common Issues", "Iconi")
    }
    
    static GenerateReport(*) {
        try {
            reportFile := A_ScriptDir "\batch_lint_report.txt"
            FileDelete(reportFile)
            
            report := "Batch Scriptlet Lint Report`n"
            report .= "Generated: " . FormatTime(A_Now, "yyyy-MM-dd HH:mm:ss") . "`n`n"
            report .= "Summary:`n"
            report .= "- Total Files: " . this.processedFiles . "`n"
            report .= "- Errors: " . this.errors . "`n"
            report .= "- Warnings: " . this.warnings . "`n"
            report .= "- Suggestions: " . this.suggestions . "`n`n"
            
            report .= "Detailed Results:`n"
            report .= "================`n`n"
            
            for result in this.results {
                SplitPath(result.file, &fileName)
                report .= "File: " . fileName . "`n"
                report .= "Path: " . result.file . "`n"
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
    
    static CleanUp(*) {
        ; Clean up temporary files and reset
        this.results := []
        this.totalFiles := 0
        this.processedFiles := 0
        this.errors := 0
        this.warnings := 0
        this.suggestions := 0
        
        if (WinExist("Batch Scriptlet Linter")) {
            gui := GuiFromHwnd(WinGetID("Batch Scriptlet Linter"))
            gui.progressText.Text := "Ready to scan scriptlets..."
            gui.progressBar.Value := 0
            gui.statsText.Text := "Files: 0 | Errors: 0 | Warnings: 0 | Suggestions: 0"
            gui.resultsList.Text := ""
            gui.detailsText.Text := ""
        }
        
        MsgBox("Cleanup complete!", "Cleanup", "Iconi")
    }
    
    static SetupHotkeys() {
        ^!b::this.Init()
        
        Escape::{
            if (WinExist("Batch Scriptlet Linter")) {
                WinClose("Batch Scriptlet Linter")
            }
        }
    }
}

; Initialize
BatchLinter.Init()
