#Requires AutoHotkey v2.0+
; =============================================================================
; Unit Tests for AutoHotkey Core Functions
; Version: 1.0
; Author: Sandra (with Claude assistance)
; Purpose: Comprehensive unit tests for core AutoHotkey functions
; =============================================================================

#Include "utils/TestFramework.ahk"
#Include "utils/ConfigManager.ahk"

; =============================================================================
; TEST SUITES
; =============================================================================

; Test ConfigManager functionality
TestSuite("ConfigManager", ConfigManagerTests)

; Test utility functions
TestSuite("Utility Functions", UtilityFunctionTests)

; Test file operations
TestSuite("File Operations", FileOperationTests)

; Test string operations
TestSuite("String Operations", StringOperationTests)

; Run all tests
TestFramework.RunAllTests()

; Export results
results := TestFramework.ExportResults("html")
FileAppend(results, A_ScriptDir . "\test_results.html")

; =============================================================================
; CONFIGMANAGER TESTS
; =============================================================================

ConfigManagerTests() {
    Test("ConfigManager Initialization", TestConfigManagerInit)
    Test("Environment Detection", TestEnvironmentDetection)
    Test("Configuration Loading", TestConfigLoading)
    Test("Configuration Validation", TestConfigValidation)
    Test("Configuration Access Methods", TestConfigAccess)
    Test("Configuration Migration", TestConfigMigration)
}

TestConfigManagerInit() {
    ; Test ConfigManager initialization
    ConfigManager.Init()
    
    AssertTrue(ConfigManager.config.Length > 0, "Config should be initialized")
    AssertTrue(ConfigManager.configFile != "", "Config file path should be set")
    AssertTrue(ConfigManager.defaultConfig.Length > 0, "Default config should be loaded")
    AssertTrue(ConfigManager.environment.Length > 0, "Environment should be detected")
}

TestEnvironmentDetection() {
    ; Test environment detection
    ConfigManager.DetectEnvironment()
    
    AssertTrue(ConfigManager.environment.Has("repos_dir"), "Should detect repos directory")
    AssertTrue(DirExist(ConfigManager.environment["repos_dir"]), "Repos directory should exist")
    AssertTrue(ConfigManager.environment.Has("temp_writable"), "Should check temp directory permissions")
    AssertTrue(ConfigManager.environment.Has("script_dir_writable"), "Should check script directory permissions")
}

TestConfigLoading() {
    ; Test configuration loading
    ConfigManager.LoadConfig()
    
    AssertTrue(ConfigManager.config.Length > 0, "Config should be loaded")
    AssertTrue(ConfigManager.config.Has("paths"), "Should have paths section")
    AssertTrue(ConfigManager.config.Has("hotkeys"), "Should have hotkeys section")
    AssertTrue(ConfigManager.config.Has("ui"), "Should have UI section")
    AssertTrue(ConfigManager.config.Has("logging"), "Should have logging section")
}

TestConfigValidation() {
    ; Test configuration validation
    local errors := []
    ConfigManager.ValidatePaths(errors)
    
    ; Should not have critical errors for basic validation
    AssertTrue(errors.Length < 5, "Should not have many validation errors")
    
    ; Test specific validations
    local paths := ConfigManager.config["paths"]
    AssertTrue(DirExist(paths["temp_dir"]), "Temp directory should exist")
    AssertTrue(DirExist(paths["repos_dir"]), "Repos directory should exist")
}

TestConfigAccess() {
    ; Test configuration access methods
    local reposDir := ConfigManager.GetPath("repos_dir")
    AssertTrue(reposDir != "", "Should be able to get repos directory")
    
    local showHelp := ConfigManager.GetHotkey("show_help")
    AssertTrue(showHelp != "", "Should be able to get hotkey")
    
    local theme := ConfigManager.GetUISetting("theme")
    AssertTrue(theme != "", "Should be able to get UI setting")
    
    local logLevel := ConfigManager.GetLoggingSetting("log_level")
    AssertTrue(logLevel != "", "Should be able to get logging setting")
}

TestConfigMigration() {
    ; Test configuration migration from INI
    local iniFile := A_ScriptDir . "\config.ini"
    
    if (FileExist(iniFile)) {
        local success := ConfigManager.MigrateFromINI()
        AssertTrue(success, "Should successfully migrate from INI")
    } else {
        ; Create a test INI file
        local testIni := "[Paths]`nReposDir=D:\Dev\repos`n`n[Hotkeys]`nShowHelp=^+h`n"
        FileAppend(testIni, iniFile)
        
        local success := ConfigManager.MigrateFromINI()
        AssertTrue(success, "Should successfully migrate test INI")
        
        ; Clean up
        FileDelete iniFile
    }
}

; =============================================================================
; UTILITY FUNCTION TESTS
; =============================================================================

UtilityFunctionTests() {
    Test("Log Operation Function", TestLogOperation)
    Test("File Path Utilities", TestFilePathUtilities)
    Test("String Utilities", TestStringUtilities)
    Test("Time Utilities", TestTimeUtilities)
}

TestLogOperation() {
    ; Test logging functionality
    local testMessage := "Test log message " . A_TickCount
    ConfigManager.LogOperation(testMessage)
    
    ; Check if log file was created/updated
    local logFile := ConfigManager.GetLoggingSetting("log_file", A_Temp . "\mcp_config.log")
    AssertFileExists(logFile, "Log file should exist")
    
    ; Check if message was written
    FileRead(logContent, logFile)
    AssertTrue(InStr(logContent, testMessage), "Log message should be in file")
}

TestFilePathUtilities() {
    ; Test path utility functions
    local testPath := "C:\Test\Path\File.txt"
    local dirPath := "C:\Test\Path"
    
    ; Test path extraction
    AssertEqual(ExtractDirectory(testPath), dirPath, "Should extract directory from path")
    AssertEqual(ExtractFileName(testPath), "File.txt", "Should extract filename from path")
    
    ; Test path normalization
    local normalizedPath := NormalizePath("C:\Test\..\Test\Path\File.txt")
    AssertEqual(normalizedPath, "C:\Test\Path\File.txt", "Should normalize path")
}

TestStringUtilities() {
    ; Test string utility functions
    local testString := "  Hello World  "
    
    ; Test trimming
    AssertEqual(Trim(testString), "Hello World", "Should trim whitespace")
    
    ; Test case conversion
    AssertEqual(StrUpper("hello"), "HELLO", "Should convert to uppercase")
    AssertEqual(StrLower("HELLO"), "hello", "Should convert to lowercase")
    
    ; Test string replacement
    local replaced := StrReplace("Hello World", "World", "Universe")
    AssertEqual(replaced, "Hello Universe", "Should replace string")
}

TestTimeUtilities() {
    ; Test time utility functions
    local now := A_Now
    local timestamp := FormatTime(now, "yyyy-MM-dd HH:mm:ss")
    
    AssertTrue(StrLen(timestamp) = 19, "Timestamp should be correct length")
    AssertTrue(InStr(timestamp, "-"), "Timestamp should contain date separators")
    AssertTrue(InStr(timestamp, ":"), "Timestamp should contain time separators")
}

; =============================================================================
; FILE OPERATION TESTS
; =============================================================================

FileOperationTests() {
    Test("File Creation and Deletion", TestFileCreation)
    Test("Directory Operations", TestDirectoryOperations)
    Test("File Reading and Writing", TestFileReadWrite)
    Test("File Permissions", TestFilePermissions)
}

TestFileCreation() {
    ; Test file creation and deletion
    local testFile := A_Temp . "\test_file_" . A_TickCount . ".txt"
    local testContent := "Test content for file operations"
    
    ; Create file
    FileAppend(testContent, testFile)
    AssertFileExists(testFile, "Test file should be created")
    
    ; Read file
    FileRead(readContent, testFile)
    AssertEqual(readContent, testContent, "File content should match")
    
    ; Delete file
    FileDelete testFile
    AssertFalse(FileExist(testFile), "Test file should be deleted")
}

TestDirectoryOperations() {
    ; Test directory operations
    local testDir := A_Temp . "\test_dir_" . A_TickCount
    
    ; Create directory
    DirCreate testDir
    AssertDirExists(testDir, "Test directory should be created")
    
    ; Create file in directory
    local testFile := testDir . "\test.txt"
    FileAppend("test", testFile)
    AssertFileExists(testFile, "File should be created in directory")
    
    ; Delete directory
    DirDelete testDir, true
    AssertFalse(DirExist(testDir), "Test directory should be deleted")
}

TestFileReadWrite() {
    ; Test file reading and writing
    local testFile := A_Temp . "\read_write_test_" . A_TickCount . ".txt"
    local originalContent := "Original content`nLine 2`nLine 3"
    
    ; Write file
    FileAppend(originalContent, testFile)
    AssertFileExists(testFile, "File should be created")
    
    ; Read file
    FileRead(readContent, testFile)
    AssertEqual(readContent, originalContent, "Read content should match written content")
    
    ; Append to file
    FileAppend("`nAppended line", testFile)
    FileRead(appendedContent, testFile)
    AssertTrue(InStr(appendedContent, "Appended line"), "Should contain appended content")
    
    ; Clean up
    FileDelete testFile
}

TestFilePermissions() {
    ; Test file permissions
    local testFile := A_Temp . "\permission_test_" . A_TickCount . ".txt"
    
    ; Test write permission
    try {
        FileAppend("test", testFile)
        AssertTrue(true, "Should have write permission to temp directory")
        FileDelete testFile
    } catch {
        AssertTrue(false, "Should have write permission to temp directory")
    }
    
    ; Test read permission
    FileAppend("test", testFile)
    try {
        FileRead(content, testFile)
        AssertTrue(true, "Should have read permission")
    } catch {
        AssertTrue(false, "Should have read permission")
    }
    
    ; Clean up
    FileDelete testFile
}

; =============================================================================
; STRING OPERATION TESTS
; =============================================================================

StringOperationTests() {
    Test("String Manipulation", TestStringManipulation)
    Test("String Validation", TestStringValidation)
    Test("String Formatting", TestStringFormatting)
    Test("Regular Expressions", TestRegularExpressions)
}

TestStringManipulation() {
    ; Test string manipulation functions
    local testString := "Hello World"
    
    ; Test length
    AssertEqual(StrLen(testString), 11, "String length should be correct")
    
    ; Test substring
    AssertEqual(SubStr(testString, 1, 5), "Hello", "Substring should be correct")
    AssertEqual(SubStr(testString, 7), "World", "Substring from position should be correct")
    
    ; Test string replacement
    local replaced := StrReplace(testString, "World", "Universe")
    AssertEqual(replaced, "Hello Universe", "String replacement should work")
    
    ; Test string splitting
    local parts := StrSplit("a,b,c", ",")
    AssertEqual(parts.Length, 3, "Should split into 3 parts")
    AssertEqual(parts[1], "a", "First part should be correct")
    AssertEqual(parts[2], "b", "Second part should be correct")
    AssertEqual(parts[3], "c", "Third part should be correct")
}

TestStringValidation() {
    ; Test string validation
    local validEmail := "test@example.com"
    local invalidEmail := "not-an-email"
    
    ; Test email validation (simplified)
    AssertTrue(InStr(validEmail, "@") && InStr(validEmail, "."), "Valid email should pass basic validation")
    AssertFalse(InStr(invalidEmail, "@") && InStr(invalidEmail, "."), "Invalid email should fail validation")
    
    ; Test empty string validation
    AssertTrue(StrLen("") = 0, "Empty string should have zero length")
    AssertFalse(StrLen("test") = 0, "Non-empty string should have non-zero length")
}

TestStringFormatting() {
    ; Test string formatting
    local number := 123.456
    
    ; Test number formatting
    AssertEqual(Format("{:.2f}", number), "123.46", "Number formatting should work")
    AssertEqual(Format("{:d}", number), "123", "Integer formatting should work")
    
    ; Test string formatting with placeholders
    local formatted := Format("Hello {1}, you are {2} years old", "World", 25)
    AssertEqual(formatted, "Hello World, you are 25 years old", "String formatting with placeholders should work")
}

TestRegularExpressions() {
    ; Test regular expressions
    local testString := "Hello World 123"
    
    ; Test pattern matching
    AssertTrue(RegExMatch(testString, "Hello"), "Should match simple pattern")
    AssertTrue(RegExMatch(testString, "\d+"), "Should match number pattern")
    
    ; Test pattern replacement
    local replaced := RegExReplace(testString, "\d+", "XXX")
    AssertEqual(replaced, "Hello World XXX", "Regex replacement should work")
    
    ; Test capture groups
    local match := RegExMatch(testString, "(\w+) (\w+)", &captured)
    AssertTrue(match > 0, "Should match with capture groups")
    if (match > 0) {
        AssertEqual(captured[1], "Hello", "First capture group should be correct")
        AssertEqual(captured[2], "World", "Second capture group should be correct")
    }
}

; =============================================================================
; HELPER FUNCTIONS
; =============================================================================

ExtractDirectory(filePath) {
    local lastSlash := InStr(filePath, "\",, -1)
    if (lastSlash > 0) {
        return SubStr(filePath, 1, lastSlash - 1)
    }
    return ""
}

ExtractFileName(filePath) {
    local lastSlash := InStr(filePath, "\",, -1)
    if (lastSlash > 0) {
        return SubStr(filePath, lastSlash + 1)
    }
    return filePath
}

NormalizePath(filePath) {
    ; Simple path normalization
    local parts := StrSplit(filePath, "\")
    local normalized := []
    
    for part in parts {
        if (part = ".." && normalized.Length > 0) {
            normalized.Pop()
        } else if (part != "." && part != "") {
            normalized.Push(part)
        }
    }
    
    return StrJoin(normalized, "\")
}

StrJoin(array, delimiter) {
    local result := ""
    for i, item in array {
        if (i > 1) {
            result .= delimiter
        }
        result .= item
    }
    return result
}
