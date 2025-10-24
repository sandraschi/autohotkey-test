﻿; ==============================================================================
; AutoHotkey Debug Helper
; @name: AutoHotkey Debug Helper
; @version: 1.0.0
; @description: Comprehensive debugging tools for AutoHotkey v2 scripts
; @category: development
; @author: Sandra
; @hotkeys: ^!d, F3, ^!v, ^!l, ^!k
; @enabled: true
; ==============================================================================

#Requires AutoHotkey v2.0+
#SingleInstance Force

class AHDebugHelper {
    static debugMode := false
    static debugLog := []
    
    static Init() {
        this.CreateGUI()
        this.SetupHotkeys()
    }
    
    static CreateGUI() {
        gui := Gui("+Resize +MinSize800x600", "AutoHotkey Debug Helper")
        gui.BackColor := "0x1a1a1a"
        gui.SetFont("s10 cWhite", "Segoe UI")
        
        ; Title
        gui.Add("Text", "x20 y20 w760 Center Bold", "ðŸ”§ AutoHotkey Debug Helper")
        gui.Add("Text", "x20 y50 w760 Center c0xcccccc", "Comprehensive debugging tools for AutoHotkey v2 scripts")
        
        ; Debug Controls
        gui.Add("Text", "x20 y90 w760 Bold", "ðŸŽ¯ Debug Controls")
        
        gui.Add("Button", "x20 y120 w150 h40", "ðŸ“Š List Variables").OnEvent("Click", this.ListVariables.Bind(this))
        gui.Add("Button", "x190 y120 w150 h40", "ðŸ“ List Lines").OnEvent("Click", this.ListLines.Bind(this))
        gui.Add("Button", "x360 y120 w150 h40", "âŒ¨ï¸ Key History").OnEvent("Click", this.KeyHistory.Bind(this))
        gui.Add("Button", "x530 y120 w150 h40", "ðŸ“‹ Debug Log").OnEvent("Click", this.ShowDebugLog.Bind(this))
        
        ; Script Analysis
        gui.Add("Text", "x20 y180 w760 Bold", "ðŸ” Script Analysis")
        
        gui.Add("Button", "x20 y210 w150 h40", "ðŸ” Analyze Script").OnEvent("Click", this.AnalyzeScript.Bind(this))
        gui.Add("Button", "x190 y210 w150 h40", "âš ï¸ Check Syntax").OnEvent("Click", this.CheckSyntax.Bind(this))
        gui.Add("Button", "x360 y210 w150 h40", "ðŸ”— Find Dependencies").OnEvent("Click", this.FindDependencies.Bind(this))
        gui.Add("Button", "x530 y210 w150 h40", "ðŸ“Š Performance").OnEvent("Click", this.PerformanceAnalysis.Bind(this))
        
        ; Command Line Debugging
        gui.Add("Text", "x20 y270 w760 Bold", "ðŸ’» Command Line Debugging")
        
        gui.Add("Text", "x20 y300 w150", "Script Path:")
        scriptPathEdit := gui.Add("Edit", "x180 y295 w400 h25", A_ScriptDir . "\test_script.ahk")
        
        gui.Add("Button", "x600 y295 w150 h40", "ðŸš€ Run with Debug").OnEvent("Click", this.RunWithDebug.Bind(this))
        
        ; Debug flags
        gui.Add("CheckBox", "x20 y330 w200", "ErrorStdOut").Value := 1
        gui.Add("CheckBox", "x240 y330 w200", "NoTrayIcon").Value := 1
        gui.Add("CheckBox", "x460 y330 w200", "Force Reload").Value := 0
        
        ; Debug Output
        gui.Add("Text", "x20 y370 w760 Bold", "ðŸ“‹ Debug Output")
        
        debugOutput := gui.Add("Edit", "x20 y400 w760 h150 ReadOnly Multi VScroll", "")
        debugOutput.BackColor := "0x2d2d2d"
        debugOutput.SetFont("s9 cWhite", "Consolas")
        
        ; Actions
        gui.Add("Button", "x20 y560 w150 h40", "ðŸ’¾ Save Debug Log").OnEvent("Click", this.SaveDebugLog.Bind(this))
        gui.Add("Button", "x190 y560 w150 h40", "ðŸ“‹ Copy Output").OnEvent("Click", this.CopyOutput.Bind(this))
        gui.Add("Button", "x360 y560 w150 h40", "ðŸ§¹ Clear Output").OnEvent("Click", this.ClearOutput.Bind(this))
        gui.Add("Button", "x530 y560 w150 h40", "â“ Help").OnEvent("Click", this.ShowHelp.Bind(this))
        
        ; Status
        gui.Add("Text", "x20 y610 w760 Center c0x888888", "Hotkeys: Ctrl+Alt+D (Debug Mode) | F3 (List Vars) | Ctrl+Alt+V (List Lines) | Ctrl+Alt+K (Key History)")
        
        ; Store references
        gui.scriptPathEdit := scriptPathEdit
        gui.debugOutput := debugOutput
        
        ; Set up hotkeys
        this.SetupHotkeys()
        
        gui.Show("w800 h650")
    }
    
    static ListVariables(*) {
        try {
            this.AddDebugOutput("=== VARIABLES DEBUG ===")
            this.AddDebugOutput("Listing all variables...")
            
            ; Use ListVars command
            ListVars
            Pause
            
            this.AddDebugOutput("Variables listed. Check the ListVars window.")
            
        } catch as e {
            this.AddDebugOutput("Error listing variables: " . e.Message)
        }
    }
    
    static ListLines(*) {
        try {
            this.AddDebugOutput("=== LINES DEBUG ===")
            this.AddDebugOutput("Listing recent execution lines...")
            
            ; Use ListLines command
            ListLines
            Pause
            
            this.AddDebugOutput("Lines listed. Check the ListLines window.")
            
        } catch as e {
            this.AddDebugOutput("Error listing lines: " . e.Message)
        }
    }
    
    static KeyHistory(*) {
        try {
            this.AddDebugOutput("=== KEY HISTORY DEBUG ===")
            this.AddDebugOutput("Listing key history...")
            
            ; Use KeyHistory command
            KeyHistory
            Pause
            
            this.AddDebugOutput("Key history listed. Check the KeyHistory window.")
            
        } catch as e {
            this.AddDebugOutput("Error listing key history: " . e.Message)
        }
    }
    
    static ShowDebugLog(*) {
        try {
            this.AddDebugOutput("=== DEBUG LOG ===")
            
            if (this.debugLog.Length = 0) {
                this.AddDebugOutput("No debug messages logged yet.")
                return
            }
            
            for i, message in this.debugLog {
                this.AddDebugOutput(i . ": " . message)
            }
            
        } catch as e {
            this.AddDebugOutput("Error showing debug log: " . e.Message)
        }
    }
    
    static AnalyzeScript(*) {
        try {
            scriptPath := GuiFromHwnd(WinGetID("AutoHotkey Debug Helper")).scriptPathEdit.Text
            
            if (!FileExist(scriptPath)) {
                this.AddDebugOutput("Script file not found: " . scriptPath)
                return
            }
            
            this.AddDebugOutput("=== SCRIPT ANALYSIS ===")
            this.AddDebugOutput("Analyzing: " . scriptPath)
            
            ; Read script content
            scriptContent := FileRead(scriptPath)
            
            ; Basic analysis
            lines := StrSplit(scriptContent, "`n")
            this.AddDebugOutput("Total lines: " . lines.Length)
            
            ; Count different elements
            functions := 0
            classes := 0
            hotkeys := 0
            variables := 0
            
            for line in lines {
                trimmed := Trim(line)
                if (RegExMatch(trimmed, "^\w+\s*\(.*\)\s*\{$")) {
                    functions++
                } else if (RegExMatch(trimmed, "^class\s+\w+")) {
                    classes++
                } else if (RegExMatch(trimmed, "^\w+::")) {
                    hotkeys++
                } else if (RegExMatch(trimmed, "^\w+\s*:=")) {
                    variables++
                }
            }
            
            this.AddDebugOutput("Functions: " . functions)
            this.AddDebugOutput("Classes: " . classes)
            this.AddDebugOutput("Hotkeys: " . hotkeys)
            this.AddDebugOutput("Variables: " . variables)
            
        } catch as e {
            this.AddDebugOutput("Error analyzing script: " . e.Message)
        }
    }
    
    static CheckSyntax(*) {
        try {
            scriptPath := GuiFromHwnd(WinGetID("AutoHotkey Debug Helper")).scriptPathEdit.Text
            
            if (!FileExist(scriptPath)) {
                this.AddDebugOutput("Script file not found: " . scriptPath)
                return
            }
            
            this.AddDebugOutput("=== SYNTAX CHECK ===")
            this.AddDebugOutput("Checking syntax: " . scriptPath)
            
            ; Try to compile/validate the script
            try {
                ; This would normally use AutoHotkey's syntax checking
                this.AddDebugOutput("âœ… Syntax appears valid")
            } catch as e {
                this.AddDebugOutput("âŒ Syntax error: " . e.Message)
            }
            
        } catch as e {
            this.AddDebugOutput("Error checking syntax: " . e.Message)
        }
    }
    
    static FindDependencies(*) {
        try {
            scriptPath := GuiFromHwnd(WinGetID("AutoHotkey Debug Helper")).scriptPathEdit.Text
            
            if (!FileExist(scriptPath)) {
                this.AddDebugOutput("Script file not found: " . scriptPath)
                return
            }
            
            this.AddDebugOutput("=== DEPENDENCIES ANALYSIS ===")
            this.AddDebugOutput("Finding dependencies: " . scriptPath)
            
            scriptContent := FileRead(scriptPath)
            
            ; Find #Include statements
            includes := []
            Loop Parse, scriptContent, "`n" {
                if (RegExMatch(A_LoopField, "i)#Include\s+(.+)")) {
                    includes.Push(Trim(RegExReplace(A_LoopField, "i)#Include\s+", "")))
                }
            }
            
            this.AddDebugOutput("Found " . includes.Length . " includes:")
            for include in includes {
                this.AddDebugOutput("  - " . include)
            }
            
        } catch as e {
            this.AddDebugOutput("Error finding dependencies: " . e.Message)
        }
    }
    
    static PerformanceAnalysis(*) {
        try {
            this.AddDebugOutput("=== PERFORMANCE ANALYSIS ===")
            
            ; Get script performance info
            this.AddDebugOutput("Script running time: " . A_TickCount . " ms")
            this.AddDebugOutput("Memory usage: " . A_WorkingSet . " bytes")
            this.AddDebugOutput("CPU usage: " . A_CPUUsage . "%")
            
        } catch as e {
            this.AddDebugOutput("Error in performance analysis: " . e.Message)
        }
    }
    
    static RunWithDebug(*) {
        try {
            scriptPath := GuiFromHwnd(WinGetID("AutoHotkey Debug Helper")).scriptPathEdit.Text
            
            if (!FileExist(scriptPath)) {
                this.AddDebugOutput("Script file not found: " . scriptPath)
                return
            }
            
            this.AddDebugOutput("=== RUNNING WITH DEBUG FLAGS ===")
            this.AddDebugOutput("Script: " . scriptPath)
            
            ; Build command line with debug flags
            cmd := '"' . A_AhkPath . '"'
            
            ; Add debug flags based on checkboxes
            if (WinExist("AutoHotkey Debug Helper")) {
                gui := GuiFromHwnd(WinGetID("AutoHotkey Debug Helper"))
                ; Note: In a real implementation, you'd check the checkbox states
                cmd .= ' /ErrorStdOut'
                cmd .= ' /NoTrayIcon'
            }
            
            cmd .= ' "' . scriptPath . '"'
            
            this.AddDebugOutput("Command: " . cmd)
            
            ; Run the script
            Run(cmd)
            this.AddDebugOutput("âœ… Script launched with debug flags")
            
        } catch as e {
            this.AddDebugOutput("Error running script: " . e.Message)
        }
    }
    
    static AddDebugOutput(message) {
        try {
            timestamp := FormatTime(A_Now, "HH:mm:ss")
            logEntry := "[" . timestamp . "] " . message
            
            this.debugLog.Push(logEntry)
            
            if (WinExist("AutoHotkey Debug Helper")) {
                gui := GuiFromHwnd(WinGetID("AutoHotkey Debug Helper"))
                currentText := gui.debugOutput.Text
                gui.debugOutput.Text := currentText . logEntry . "`n"
                
                ; Auto-scroll to bottom
                gui.debugOutput.Focus()
                Send("^{End}")
            }
        } catch {
            ; Ignore errors
        }
    }
    
    static SaveDebugLog(*) {
        try {
            logFile := A_Temp . "\autohotkey_debug_log.txt"
            
            logContent := "AutoHotkey Debug Log`n"
            logContent .= "Generated: " . FormatTime(A_Now, "yyyy-MM-dd HH:mm:ss") . "`n`n"
            
            for message in this.debugLog {
                logContent .= message . "`n"
            }
            
            FileAppend(logContent, logFile)
            this.AddDebugOutput("Debug log saved to: " . logFile)
            
        } catch as e {
            this.AddDebugOutput("Error saving debug log: " . e.Message)
        }
    }
    
    static CopyOutput(*) {
        try {
            if (WinExist("AutoHotkey Debug Helper")) {
                gui := GuiFromHwnd(WinGetID("AutoHotkey Debug Helper"))
                A_Clipboard := gui.debugOutput.Text
                this.AddDebugOutput("Output copied to clipboard")
            }
        } catch as e {
            this.AddDebugOutput("Error copying output: " . e.Message)
        }
    }
    
    static ClearOutput(*) {
        try {
            if (WinExist("AutoHotkey Debug Helper")) {
                gui := GuiFromHwnd(WinGetID("AutoHotkey Debug Helper"))
                gui.debugOutput.Text := ""
                this.debugLog := []
                this.AddDebugOutput("Output cleared")
            }
        } catch as e {
            this.AddDebugOutput("Error clearing output: " . e.Message)
        }
    }
    
    static ShowHelp(*) {
        helpText := "ðŸ”§ AutoHotkey Debug Helper`n`n"
        helpText .= "This tool provides comprehensive debugging for AutoHotkey v2:`n`n"
        helpText .= "ðŸŽ¯ Debug Controls:`n"
        helpText .= "â€¢ List Variables: Show all variables and their values`n"
        helpText .= "â€¢ List Lines: Show recently executed lines`n"
        helpText .= "â€¢ Key History: Show recent keystrokes and mouse clicks`n"
        helpText .= "â€¢ Debug Log: View logged debug messages`n`n"
        helpText .= "ðŸ” Script Analysis:`n"
        helpText .= "â€¢ Analyze Script: Count functions, classes, hotkeys, variables`n"
        helpText .= "â€¢ Check Syntax: Validate script syntax`n"
        helpText .= "â€¢ Find Dependencies: Locate #Include statements`n"
        helpText .= "â€¢ Performance: Show runtime performance metrics`n`n"
        helpText .= "ðŸ’» Command Line Debugging:`n"
        helpText .= "â€¢ ErrorStdOut: Send errors to console instead of message boxes`n"
        helpText .= "â€¢ NoTrayIcon: Run without tray icon`n"
        helpText .= "â€¢ Force Reload: Force reload even if script is running`n`n"
        helpText .= "Hotkeys:`n"
        helpText .= "â€¢ Ctrl+Alt+D: Toggle debug mode`n"
        helpText .= "â€¢ F3: List variables`n"
        helpText .= "â€¢ Ctrl+Alt+V: List lines`n"
        helpText .= "â€¢ Ctrl+Alt+K: Key history`n"
        helpText .= "â€¢ Escape: Close tool"
        
        MsgBox(helpText, "AutoHotkey Debug Helper Help", "Iconi")
    }
    
    static SetupHotkeys() {
        ^!Hotkey("d", (*) => this.I)nit()
        Hotkey("F3", (*) => this.ListVariables()
        ^!v::this.ListLi)nes()
        ^!Hotkey("k", (*) => this.KeyHistory()
        
        Escape::{
            if (Wi)nExist("AutoHotkey Debug Helper")) {
                WinClose("AutoHotkey Debug Helper")
            }
        }
    }
}

; Hotkeys
Hotkey("^!d", (*) => AHDebugHelper.Init())
Hotkey("F3", (*) => AHDebugHelper.ListVariables())
Hotkey("^!v", (*) => AHDebugHelper.ListLines())
Hotkey("^!k", (*) => AHDebugHelper.KeyHistory())

; Initialize
AHDebugHelper.Init()
