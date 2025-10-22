#Requires AutoHotkey v2.0+
; =============================================================================
; ConfigManager.ahk - Advanced Configuration Management System
; Version: 1.0
; Author: Sandra (with Claude assistance)
; Purpose: Dynamic configuration management with environment detection
; =============================================================================

class ConfigManager {
    static config := Map()
    static configFile := ""
    static defaultConfig := Map()
    static environment := Map()
    
    ; =============================================================================
    ; INITIALIZATION
    ; =============================================================================
    
    static Init() {
        ; Set default configuration file
        this.configFile := A_ScriptDir . "\config.json"
        
        ; Initialize default configuration
        this.InitializeDefaults()
        
        ; Detect environment
        this.DetectEnvironment()
        
        ; Load or create configuration
        this.LoadConfig()
        
        ; Validate configuration
        this.ValidateConfig()
    }
    
    ; =============================================================================
    ; DEFAULT CONFIGURATION
    ; =============================================================================
    
    static InitializeDefaults() {
        this.defaultConfig := Map(
            "paths", Map(
                "repos_dir", A_ScriptDir,
                "claude_config", A_AppData . "\Claude\claude_desktop_config.json",
                "claude_logs", A_AppData . "\Claude\logs\",
                "claude_exe", "",
                "python_exe", "",
                "temp_dir", A_Temp . "\"
            ),
            "hotkeys", Map(
                "show_help", "^+h",
                "show_status", "^+s",
                "restart_claude", "^!r",
                "emergency_restart", "^!x",
                "reload_config", "^+r"
            ),
            "ui", Map(
                "font", "Segoe UI",
                "font_size", 9,
                "theme", "Light",
                "show_welcome_screen", true
            ),
            "logging", Map(
                "enabled", true,
                "max_log_size_mb", 10,
                "log_level", "INFO",
                "log_file", A_Temp . "\mcp_script.log"
            ),
            "development", Map(
                "auto_backup", true,
                "backup_dir", A_UserProfile . "\backups\mcp_scripts",
                "max_backups", 5
            )
        )
    }
    
    ; =============================================================================
    ; ENVIRONMENT DETECTION
    ; =============================================================================
    
    static DetectEnvironment() {
        this.environment := Map()
        
        ; Detect Claude Desktop installation
        this.DetectClaudeInstallation()
        
        ; Detect Python installation
        this.DetectPythonInstallation()
        
        ; Detect development directories
        this.DetectDevelopmentDirectories()
        
        ; Validate permissions
        this.ValidatePermissions()
    }
    
    static DetectClaudeInstallation() {
        ; Common Claude Desktop installation paths
        claudePaths := [
            A_LocalAppData . "\AnthropicClaude\claude.exe",
            A_ProgramFiles . "\AnthropicClaude\claude.exe",
            A_ProgramFiles . "\Claude\claude.exe"
        ]
        
        ; Check for existing config to get version-specific path
        configPath := A_AppData . "\Claude\claude_desktop_config.json"
        if (FileExist(configPath)) {
            try {
                FileRead(configContent, configPath)
                if (InStr(configContent, "app-")) {
                    ; Extract version from config
                    RegExMatch(configContent, "app-([0-9.]+)", &match)
                    if (match) {
                        versionPath := A_LocalAppData . "\AnthropicClaude\app-" . match[1] . "\claude.exe"
                        if (FileExist(versionPath)) {
                            this.environment["claude_exe"] := versionPath
                            return
                        }
                    }
                }
            } catch {
                ; Continue with fallback detection
            }
        }
        
        ; Fallback: check common paths
        for path in claudePaths {
            if (FileExist(path)) {
                this.environment["claude_exe"] := path
                return
            }
        }
        
        ; If not found, set empty string for manual configuration
        this.environment["claude_exe"] := ""
    }
    
    static DetectPythonInstallation() {
        ; Check common Python installation paths
        pythonPaths := [
            A_LocalAppData . "\Programs\Python\Python313\python.exe",
            A_LocalAppData . "\Programs\Python\Python312\python.exe",
            A_LocalAppData . "\Programs\Python\Python311\python.exe",
            A_ProgramFiles . "\Python\python.exe",
            A_ProgramFiles . "\Python313\python.exe",
            A_ProgramFiles . "\Python312\python.exe",
            A_ProgramFiles . "\Python311\python.exe"
        ]
        
        ; Try to find Python in PATH first
        try {
            RunWait "python --version", &output, "Hide"
            if (output) {
                ; Python found in PATH, get full path
                RunWait "where python", &pythonPath, "Hide"
                if (pythonPath) {
                    this.environment["python_exe"] := Trim(pythonPath)
                    return
                }
            }
        } catch {
            ; Continue with path checking
        }
        
        ; Check specific installation paths
        for path in pythonPaths {
            if (FileExist(path)) {
                this.environment["python_exe"] := path
                return
            }
        }
        
        ; If not found, set empty string for manual configuration
        this.environment["python_exe"] := ""
    }
    
    static DetectDevelopmentDirectories() {
        ; Detect common development directories
        devPaths := [
            A_UserProfile . "\Dev",
            A_UserProfile . "\Development",
            A_UserProfile . "\Projects",
            A_UserProfile . "\Code",
            "D:\Dev",
            "C:\Dev",
            "C:\Development"
        ]
        
        for path in devPaths {
            if (DirExist(path)) {
                this.environment["repos_dir"] := path
                return
            }
        }
        
        ; Fallback to script directory
        this.environment["repos_dir"] := A_ScriptDir
    }
    
    static ValidatePermissions() {
        ; Check write permissions for temp directory
        tempFile := A_Temp . "\mcp_config_test.tmp"
        try {
            FileAppend("test", tempFile)
            FileDelete tempFile
            this.environment["temp_writable"] := true
        } catch {
            this.environment["temp_writable"] := false
        }
        
        ; Check write permissions for script directory
        scriptFile := A_ScriptDir . "\mcp_config_test.tmp"
        try {
            FileAppend("test", scriptFile)
            FileDelete scriptFile
            this.environment["script_dir_writable"] := true
        } catch {
            this.environment["script_dir_writable"] := false
        }
    }
    
    ; =============================================================================
    ; CONFIGURATION LOADING AND SAVING
    ; =============================================================================
    
    static LoadConfig() {
        if (FileExist(this.configFile)) {
            try {
                FileRead(configContent, this.configFile)
                this.config := JSON.parse(configContent)
                
                ; Merge with defaults for any missing keys
                this.MergeWithDefaults()
                
                ; Update with detected environment values
                this.UpdateWithEnvironment()
                
            } catch as e {
                ; If JSON parsing fails, create new config
                this.CreateNewConfig()
            }
        } else {
            ; Create new configuration file
            this.CreateNewConfig()
        }
    }
    
    static CreateNewConfig() {
        ; Start with defaults
        this.config := this.DeepCopy(this.defaultConfig)
        
        ; Update with detected environment
        this.UpdateWithEnvironment()
        
        ; Save the new configuration
        this.SaveConfig()
        
        ; Show notification
        TrayTip("Created new configuration file", "ConfigManager", "1")
    }
    
    static UpdateWithEnvironment() {
        ; Update paths with detected values
        if (this.environment.Has("claude_exe") && this.environment["claude_exe"]) {
            this.config["paths"]["claude_exe"] := this.environment["claude_exe"]
        }
        
        if (this.environment.Has("python_exe") && this.environment["python_exe"]) {
            this.config["paths"]["python_exe"] := this.environment["python_exe"]
        }
        
        if (this.environment.Has("repos_dir") && this.environment["repos_dir"]) {
            this.config["paths"]["repos_dir"] := this.environment["repos_dir"]
        }
    }
    
    static MergeWithDefaults() {
        ; Recursively merge config with defaults
        this.config := this.MergeMaps(this.defaultConfig, this.config)
    }
    
    static SaveConfig() {
        try {
            ; Convert config to JSON
            jsonContent := JSON.stringify(this.config, 4)
            
            ; Write to file
            FileDelete this.configFile
            FileAppend(jsonContent, this.configFile)
            
            ; Log operation
            this.LogOperation("Configuration saved successfully")
            
        } catch as e {
            this.LogOperation("Failed to save configuration: " . e.Message)
            throw e
        }
    }
    
    ; =============================================================================
    ; CONFIGURATION VALIDATION
    ; =============================================================================
    
    static ValidateConfig() {
        local errors := []
        
        ; Validate paths
        this.ValidatePaths(errors)
        
        ; Validate hotkeys
        this.ValidateHotkeys(errors)
        
        ; Validate UI settings
        this.ValidateUISettings(errors)
        
        ; Validate logging settings
        this.ValidateLoggingSettings(errors)
        
        ; If errors found, show them
        if (errors.Length > 0) {
            this.ShowValidationErrors(errors)
        }
    }
    
    static ValidatePaths(errors) {
        ; Check if directories exist and are writable
        paths := this.config["paths"]
        
        ; Check repos directory
        if (!DirExist(paths["repos_dir"])) {
            errors.Push("Repos directory does not exist: " . paths["repos_dir"])
        }
        
        ; Check temp directory
        if (!DirExist(paths["temp_dir"])) {
            errors.Push("Temp directory does not exist: " . paths["temp_dir"])
        }
        
        ; Check Claude executable (if specified)
        if (paths["claude_exe"] && !FileExist(paths["claude_exe"])) {
            errors.Push("Claude executable not found: " . paths["claude_exe"])
        }
        
        ; Check Python executable (if specified)
        if (paths["python_exe"] && !FileExist(paths["python_exe"])) {
            errors.Push("Python executable not found: " . paths["python_exe"])
        }
    }
    
    static ValidateHotkeys(errors) {
        ; Basic hotkey validation
        hotkeys := this.config["hotkeys"]
        
        for key, value in hotkeys {
            if (!value || StrLen(value) < 2) {
                errors.Push("Invalid hotkey for " . key . ": " . value)
            }
        }
    }
    
    static ValidateUISettings(errors) {
        ; Validate UI settings
        ui := this.config["ui"]
        
        if (ui["font_size"] < 6 || ui["font_size"] > 24) {
            errors.Push("Font size must be between 6 and 24")
        }
        
        if (!InStr("Light,Dark,Auto", ui["theme"])) {
            errors.Push("Invalid theme: " . ui["theme"])
        }
    }
    
    static ValidateLoggingSettings(errors) {
        ; Validate logging settings
        logging := this.config["logging"]
        
        if (logging["max_log_size_mb"] < 1 || logging["max_log_size_mb"] > 100) {
            errors.Push("Max log size must be between 1 and 100 MB")
        }
        
        if (!InStr("DEBUG,INFO,WARNING,ERROR", logging["log_level"])) {
            errors.Push("Invalid log level: " . logging["log_level"])
        }
    }
    
    static ShowValidationErrors(errors) {
        local errorMsg := "Configuration validation errors:`n`n"
        
        for error in errors {
            errorMsg .= "• " . error . "`n"
        }
        
        errorMsg .= "`nPlease fix these issues in the configuration file."
        
        MsgBox(errorMsg, "Configuration Validation", "Icon!")
    }
    
    ; =============================================================================
    ; CONFIGURATION ACCESS METHODS
    ; =============================================================================
    
    static Get(section, key, defaultValue := "") {
        if (this.config.Has(section) && this.config[section].Has(key)) {
            return this.config[section][key]
        }
        return defaultValue
    }
    
    static Set(section, key, value) {
        if (!this.config.Has(section)) {
            this.config[section] := Map()
        }
        this.config[section][key] := value
    }
    
    static GetPath(key, defaultValue := "") {
        return this.Get("paths", key, defaultValue)
    }
    
    static GetHotkey(key, defaultValue := "") {
        return this.Get("hotkeys", key, defaultValue)
    }
    
    static GetUISetting(key, defaultValue := "") {
        return this.Get("ui", key, defaultValue)
    }
    
    static GetLoggingSetting(key, defaultValue := "") {
        return this.Get("logging", key, defaultValue)
    }
    
    ; =============================================================================
    ; UTILITY METHODS
    ; =============================================================================
    
    static DeepCopy(obj) {
        if (Type(obj) = "Map") {
            local copy := Map()
            for key, value in obj {
                copy[key] := this.DeepCopy(value)
            }
            return copy
        } else if (Type(obj) = "Array") {
            local copy := []
            for value in obj {
                copy.Push(this.DeepCopy(value))
            }
            return copy
        } else {
            return obj
        }
    }
    
    static MergeMaps(defaultMap, userMap) {
        local result := this.DeepCopy(defaultMap)
        
        for key, value in userMap {
            if (Type(value) = "Map" && result.Has(key) && Type(result[key]) = "Map") {
                result[key] := this.MergeMaps(result[key], value)
            } else {
                result[key] := this.DeepCopy(value)
            }
        }
        
        return result
    }
    
    static LogOperation(message) {
        try {
            local logFile := this.GetLoggingSetting("log_file", A_Temp . "\mcp_config.log")
            local timestamp := FormatTime(A_Now, "yyyy-MM-dd HH:mm:ss")
            FileAppend(timestamp . " - " . message . "`n", logFile)
        } catch {
            ; Ignore logging errors
        }
    }
    
    ; =============================================================================
    ; MIGRATION FROM OLD CONFIG FORMAT
    ; =============================================================================
    
    static MigrateFromINI() {
        local iniFile := A_ScriptDir . "\config.ini"
        
        if (!FileExist(iniFile)) {
            return false
        }
        
        try {
            ; Read INI sections
            local sections := IniRead(iniFile)
            
            for section in StrSplit(sections, "`n") {
                section := Trim(section)
                if (!section) {
                    ; Skip empty sections
                } else {
                    ; Read keys from section
                    local keys := IniRead(iniFile, section)
                    
                    for key in StrSplit(keys, "`n") {
                        key := Trim(key)
                        if (key) {
                            local value := IniRead(iniFile, section, key)
                            
                            ; Map INI sections to new structure
                            switch section {
                                case "Paths":
                                    this.Set("paths", StrLower(key), value)
                                case "Hotkeys":
                                    this.Set("hotkeys", StrLower(key), value)
                                case "UI":
                                    this.Set("ui", StrLower(key), value)
                                case "Logging":
                                    this.Set("logging", StrLower(key), value)
                                case "Development":
                                    this.Set("development", StrLower(key), value)
                            }
                        }
                    }
                }
            }
            
            ; Save new configuration
            this.SaveConfig()
            
            ; Backup old INI file
            FileCopy iniFile, iniFile . ".backup"
            
            this.LogOperation("Successfully migrated from INI to JSON configuration")
            return true
            
        } catch as e {
            this.LogOperation("Failed to migrate from INI: " . e.Message)
            return false
        }
    }
}

; =============================================================================
; JSON UTILITY CLASS (Simple JSON parser/writer)
; =============================================================================

class JSON {
    static parse(jsonString) {
        ; Simple JSON parser for basic objects
        ; This is a simplified implementation
        ; For production use, consider a more robust JSON library
        
        local result := Map()
        
        ; Remove whitespace
        jsonString := RegExReplace(jsonString, "\s+", " ")
        
        ; Parse simple key-value pairs
        if (RegExMatch(jsonString, '\{"([^"]+)":\s*"([^"]*)"', &match)) {
            result[match[1]] := match[2]
        }
        
        return result
    }
    
    static stringify(obj, indent := 0) {
        ; Simple JSON stringifier
        ; This is a simplified implementation
        
        local result := "{`n"
        local spaces := ""
        
        loop indent {
            spaces .= " "
        }
        
        for key, value in obj {
            result .= spaces . "  `"" . key . "`: `"" . value . "`,`n"
        }
        
        result := SubStr(result, 1, -2) . "`n" . spaces . "}"
        return result
    }
}
