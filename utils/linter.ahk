; AutoHotkey v2 Scriptlet Linter
; Usage: linter.ahk [path_to_scriptlet]

#Requires AutoHotkey v2.0
#Warn

; Set up logging
logFile := A_ScriptDir "\linter.log"
FileDelete(logFile)

; Check if a file was provided
if (A_Args.Length = 0) {
    MsgBox "Please provide a scriptlet file to lint.", "Scriptlet Linter", "Icon!"
    ExitApp 1
}

fileToCheck := A_Args[1]
if (!FileExist(fileToCheck)) {
    MsgBox "File not found: " fileToCheck, "Scriptlet Linter", "Icon!"
    ExitApp 1
}

; Read the file content
FileRead fileContent, % fileToCheck
if (!fileContent) {
    LogError("Failed to read file: " fileToCheck)
    ExitApp 1
}

; Initialize results
issues := []
hasErrors := false
hasWarnings := false

; Check 1: Required base class inclusion
if (!InStr(fileContent, "#Include <_base>")) {
    AddIssue("Missing required #Include <_base>", "Error", 1)
    hasErrors := true
}

; Check 2: Class definition
if (!RegExMatch(fileContent, "class\s+(\w+)\s+extends\s+Scriptlet", &match)) {
    AddIssue("Scriptlet must define a class that extends Scriptlet", "Error")
    hasErrors := true
}

; Check 3: Required static properties
requiredProps := ["name", "description", "category"]
for prop in requiredProps {
    if (!RegExMatch(fileContent, "static\s+" prop "\s*:=\s*")) {
        AddIssue("Missing required static property: " prop, "Error")
        hasErrors := true
    }
}

; Check 4: Run method
if (!RegExMatch(fileContent, "static\s+Run\s*\([^)]*\)")) {
    AddIssue("Missing required Run() method", "Error")
    hasErrors := true
}

; Check 5: Init() call
if (!RegExMatch(fileContent, "\n;?\s*\w+\.Init\(\)")) {
    AddIssue("Missing Init() call at the end of the file", "Warning")
    hasWarnings := true
}

; Check 6: Error handling
if (!InStr(fileContent, "try") && !InStr(fileContent, "catch")) {
    AddIssue("Consider adding error handling with try/catch blocks", "Warning")
    hasWarnings := true
}

; Check 7: Status updates
if (!InStr(fileContent, "ShowStatus")) {
    AddIssue("Consider using ShowStatus() to provide user feedback", "Suggestion")
}

; Generate report
report := "Lint Report for: " fileToCheck "`n"
report .= "Generated: " A_Now "`n"
report .= "`nIssues found:`n"

if (issues.Length = 0) {
    report .= "  No issues found! 🎉"
} else {
    for issue in issues {
        severity := "[" issue.severity "]"
        report .= Format("{1:-10} Line {2:-4} - {3}`n", 
                        severity, 
                        issue.line ? issue.line : "N/A", 
                        issue.message)
    }
}

; Save report to file
reportFile := A_ScriptDir "\lint_report.txt"
FileDelete(reportFile)
FileAppend(report, reportFile, "UTF-8")

; Show summary
if (hasErrors) {
    result := "❌ Lint failed with errors"
} else if (hasWarnings) {
    result := "⚠️  Lint completed with warnings"
} else {
    result := "✅ Lint passed successfully"
}

MsgBox result ": " issues.Length " issues found.`n`nSee " reportFile " for details.", 
    "Scriptlet Linter", 
    hasErrors ? "Icon!" : "Iconi"

ExitApp hasErrors ? 1 : 0

; Helper functions
AddIssue(message, severity, line := "") {
    issues.Push({message: message, severity: severity, line: line})
    Log(severity ": " message " (Line: " (line ? line : "N/A") ")")
}

Log(message) {
    static logMutex := 0
    while (DllCall("User32\InSendMessage")) {
        if (logMutex)
            return
        logMutex := 1
        Sleep 10
    }
    
    FormatTime timestamp,, "yyyy-MM-dd HH:mm:ss"
    logMessage := "[" timestamp "] " message "`n"
    FileAppend(logMessage, logFile, "UTF-8")
    logMutex := 0
}

LogError(message) {
    Log("ERROR: " message)
}
