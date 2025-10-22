#Requires AutoHotkey v2.0+
; =============================================================================
; PluginManager.ahk - Dynamic Plugin Discovery and Management System
; Version: 1.0
; Author: Sandra (with Claude assistance)
; Purpose: Dynamic scriptlet discovery, loading, and management
; =============================================================================

class PluginManager {
    static plugins := Map()
    static metadata := Map()
    static categories := Map()
    static loadedPlugins := Map()
    static pluginDir := ""
    static metadataFile := ""
    
    ; =============================================================================
    ; INITIALIZATION
    ; =============================================================================
    
    static Init() {
        ; Set plugin directory
        this.pluginDir := A_ScriptDir . "\scriptlets"
        this.metadataFile := this.pluginDir . "\metadata.json"
        
        ; Ensure plugin directory exists
        if (!DirExist(this.pluginDir)) {
            DirCreate(this.pluginDir)
            this.LogOperation("Created plugin directory: " . this.pluginDir)
        }
        
        ; Discover and load plugins
        this.DiscoverPlugins()
        this.LoadMetadata()
        this.CategorizePlugins()
        
        this.LogOperation("PluginManager initialized with " . this.plugins.Length . " plugins")
    }
    
    ; =============================================================================
    ; PLUGIN DISCOVERY
    ; =============================================================================
    
    static DiscoverPlugins() {
        this.plugins := Map()
        
        ; Scan scriptlets directory for .ahk files
        this.ScanDirectory(this.pluginDir)
        
        ; Scan subdirectories
        this.ScanSubdirectories(this.pluginDir)
        
        this.LogOperation("Discovered " . this.plugins.Length . " plugins")
    }
    
    static ScanDirectory(dirPath) {
        try {
            ; Get all .ahk files in directory
            loop files, dirPath . "\*.ahk" {
                local pluginName := this.ExtractPluginName(A_LoopFileName)
                local pluginPath := A_LoopFileFullPath
                
                ; Extract metadata from file
                local metadata := this.ExtractMetadataFromFile(pluginPath)
                
                ; Add to plugins map
                this.plugins[pluginName] := Map(
                    "name", pluginName,
                    "path", pluginPath,
                    "filename", A_LoopFileName,
                    "metadata", metadata,
                    "category", metadata["category"] || "uncategorized",
                    "enabled", metadata["enabled"] !== false
                )
            }
        } catch as e {
            this.LogOperation("Error scanning directory " . dirPath . ": " . e.Message)
        }
    }
    
    static ScanSubdirectories(dirPath) {
        try {
            ; Scan subdirectories recursively
            Loop Files, dirPath . "\*", "D" {
                local subDir := A_LoopFileFullPath
                this.ScanDirectory(subDir)
                this.ScanSubdirectories(subDir)
            }
        } catch as e {
            this.LogOperation("Error scanning subdirectories: " . e.Message)
        }
    }
    
    static ExtractPluginName(filename) {
        ; Remove .ahk extension and convert to lowercase
        local name := RegExReplace(filename, "\.ahk$", "")
        return StrLower(name)
    }
    
    static ExtractMetadataFromFile(filePath) {
        local metadata := Map()
        
        try {
            FileRead(fileContent, filePath)
            
            ; Extract metadata from comments at the top of file
            local lines := StrSplit(fileContent, "`n")
            local inMetadata := false
            
            for line in lines {
                line := Trim(line)
                
                ; Check for metadata start
                if (RegExMatch(line, "^;.*@(\w+):\s*(.*)", &match)) {
                    inMetadata := true
                    local key := match[1]
                    local value := match[2]
                    
                    ; Parse different metadata types
                    switch key {
                        case "name":
                            metadata["name"] := value
                        case "version":
                            metadata["version"] := value
                        case "description":
                            metadata["description"] := value
                        case "category":
                            metadata["category"] := value
                        case "author":
                            metadata["author"] := value
                        case "dependencies":
                            metadata["dependencies"] := StrSplit(value, ",")
                        case "hotkeys":
                            metadata["hotkeys"] := StrSplit(value, ",")
                        case "enabled":
                            metadata["enabled"] := (value = "true")
                        case "priority":
                            metadata["priority"] := Integer(value)
                    }
                } else if (inMetadata && line = "") {
                    ; Empty line ends metadata section
                    break
                } else if (inMetadata && !RegExMatch(line, "^;")) {
                    ; Non-comment line ends metadata section
                    break
                }
            }
            
            ; Set defaults if not specified
            if (!metadata.Has("name")) {
                metadata["name"] := this.ExtractPluginName(FileGetName(filePath))
            }
            if (!metadata.Has("version")) {
                metadata["version"] := "1.0.0"
            }
            if (!metadata.Has("description")) {
                metadata["description"] := "No description available"
            }
            if (!metadata.Has("category")) {
                metadata["category"] := "uncategorized"
            }
            if (!metadata.Has("enabled")) {
                metadata["enabled"] := true
            }
            if (!metadata.Has("priority")) {
                metadata["priority"] := 100
            }
            
        } catch as e {
            this.LogOperation("Error extracting metadata from " . filePath . ": " . e.Message)
            ; Return default metadata
            metadata := Map(
                "name", this.ExtractPluginName(FileGetName(filePath)),
                "version", "1.0.0",
                "description", "No description available",
                "category", "uncategorized",
                "enabled", true,
                "priority", 100
            )
        }
        
        return metadata
    }
    
    ; =============================================================================
    ; METADATA MANAGEMENT
    ; =============================================================================
    
    static LoadMetadata() {
        if (FileExist(this.metadataFile)) {
            try {
                FileRead(metadataContent, this.metadataFile)
                this.metadata := PluginJSON.parse(metadataContent)
                this.LogOperation("Loaded metadata from " . this.metadataFile)
            } catch as e {
                this.LogOperation("Error loading metadata: " . e.Message)
                this.metadata := Map()
            }
        } else {
            this.metadata := Map()
            this.SaveMetadata()
        }
    }
    
    static SaveMetadata() {
        try {
            local jsonContent := JSON.stringify(this.metadata, 4)
            FileDelete this.metadataFile
            FileAppend(jsonContent, this.metadataFile)
            this.LogOperation("Saved metadata to " . this.metadataFile)
        } catch as e {
            this.LogOperation("Error saving metadata: " . e.Message)
        }
    }
    
    static UpdatePluginMetadata(pluginName, newMetadata) {
        if (!this.metadata.Has(pluginName)) {
            this.metadata[pluginName] := Map()
        }
        
        ; Merge new metadata with existing
        for key, value in newMetadata {
            this.metadata[pluginName][key] := value
        }
        
        this.SaveMetadata()
        this.LogOperation("Updated metadata for plugin: " . pluginName)
    }
    
    ; =============================================================================
    ; PLUGIN CATEGORIZATION
    ; =============================================================================
    
    static CategorizePlugins() {
        this.categories := Map()
        
        for pluginName, plugin in this.plugins {
            local category := plugin["category"]
            
            if (!this.categories.Has(category)) {
                this.categories[category] := []
            }
            
            this.categories[category].Push(plugin)
        }
        
        ; Sort plugins within each category by priority
        for category, plugins in this.categories {
            this.SortPluginsByPriority(plugins)
        }
        
        this.LogOperation("Categorized " . this.plugins.Length . " plugins into " . this.categories.Length . " categories")
    }
    
    static SortPluginsByPriority(plugins) {
        ; Simple bubble sort by priority
        local n := plugins.Length
        loop n - 1 {
            loop n - A_Index {
                if (plugins[A_Index]["priority"] > plugins[A_Index + 1]["priority"]) {
                    local temp := plugins[A_Index]
                    plugins[A_Index] := plugins[A_Index + 1]
                    plugins[A_Index + 1] := temp
                }
            }
        }
    }
    
    ; =============================================================================
    ; PLUGIN LOADING
    ; =============================================================================
    
    static LoadPlugin(pluginName) {
        if (!this.plugins.Has(pluginName)) {
            this.LogOperation("Plugin not found: " . pluginName)
            return false
        }
        
        local plugin := this.plugins[pluginName]
        
        if (!plugin["enabled"]) {
            this.LogOperation("Plugin disabled: " . pluginName)
            return false
        }
        
        try {
            ; Check dependencies
            if (!this.CheckDependencies(plugin)) {
                this.LogOperation("Dependencies not met for plugin: " . pluginName)
                return false
            }
            
            ; Load the plugin file dynamically
            try {
                RunWait('"' . A_AhkPath . '" "' . plugin["path"] . '"', , "Hide")
                this.LogOperation("Executed plugin: " . plugin["name"])
            } catch as e {
                this.LogOperation("Error executing plugin " . plugin["name"] . ": " . e.Message)
                return false
            }
            
            ; Register hotkeys if specified
            this.RegisterPluginHotkeys(plugin)
            
            ; Mark as loaded
            this.loadedPlugins[pluginName] := plugin
            
            this.LogOperation("Successfully loaded plugin: " . pluginName)
            return true
            
        } catch as e {
            this.LogOperation("Error loading plugin " . pluginName . ": " . e.Message)
            return false
        }
    }
    
    static LoadAllPlugins() {
        local loadedCount := 0
        
        for pluginName, plugin in this.plugins {
            if (plugin["enabled"]) {
                if (this.LoadPlugin(pluginName)) {
                    loadedCount++
                }
            }
        }
        
        this.LogOperation("Loaded " . loadedCount . " plugins out of " . this.plugins.Length . " available")
        return loadedCount
    }
    
    static LoadPluginsByCategory(category) {
        local loadedCount := 0
        
        if (this.categories.Has(category)) {
            for plugin in this.categories[category] {
                if (plugin["enabled"]) {
                    if (this.LoadPlugin(plugin["name"])) {
                        loadedCount++
                    }
                }
            }
        }
        
        this.LogOperation("Loaded " . loadedCount . " plugins from category: " . category)
        return loadedCount
    }
    
    static UnloadPlugin(pluginName) {
        if (!this.loadedPlugins.Has(pluginName)) {
            this.LogOperation("Plugin not loaded: " . pluginName)
            return false
        }
        
        try {
            local plugin := this.loadedPlugins[pluginName]
            
            ; Unregister hotkeys
            this.UnregisterPluginHotkeys(plugin)
            
            ; Remove from loaded plugins
            this.loadedPlugins.Delete(pluginName)
            
            this.LogOperation("Successfully unloaded plugin: " . pluginName)
            return true
            
        } catch as e {
            this.LogOperation("Error unloading plugin " . pluginName . ": " . e.Message)
            return false
        }
    }
    
    ; =============================================================================
    ; DEPENDENCY MANAGEMENT
    ; =============================================================================
    
    static CheckDependencies(plugin) {
        if (!plugin["metadata"].Has("dependencies")) {
            return true
        }
        
        local dependencies := plugin["metadata"]["dependencies"]
        
        for dependency in dependencies {
            dependency := Trim(dependency)
            
            ; Check if dependency is loaded
            if (!this.loadedPlugins.Has(dependency)) {
                ; Try to load dependency
                if (!this.LoadPlugin(dependency)) {
                    this.LogOperation("Dependency not available: " . dependency)
                    return false
                }
            }
        }
        
        return true
    }
    
    ; =============================================================================
    ; HOTKEY MANAGEMENT
    ; =============================================================================
    
    static RegisterPluginHotkeys(plugin) {
        if (!plugin["metadata"].Has("hotkeys")) {
            return
        }
        
        local hotkeys := plugin["metadata"]["hotkeys"]
        
        for hotkey in hotkeys {
            hotkey := Trim(hotkey)
            if (hotkey != "") {
                try {
                    ; Register hotkey (this would need to be implemented per plugin)
                    this.LogOperation("Registered hotkey " . hotkey . " for plugin " . plugin["name"])
                } catch as e {
                    this.LogOperation("Error registering hotkey " . hotkey . ": " . e.Message)
                }
            }
        }
    }
    
    static UnregisterPluginHotkeys(plugin) {
        if (!plugin["metadata"].Has("hotkeys")) {
            return
        }
        
        local hotkeys := plugin["metadata"]["hotkeys"]
        
        for hotkey in hotkeys {
            hotkey := Trim(hotkey)
            if (hotkey != "") {
                try {
                    ; Unregister hotkey (this would need to be implemented per plugin)
                    this.LogOperation("Unregistered hotkey " . hotkey . " for plugin " . plugin["name"])
                } catch as e {
                    this.LogOperation("Error unregistering hotkey " . hotkey . ": " . e.Message)
                }
            }
        }
    }
    
    ; =============================================================================
    ; PLUGIN QUERY METHODS
    ; =============================================================================
    
    static GetPlugin(pluginName) {
        return this.plugins.Has(pluginName) ? this.plugins[pluginName] : ""
    }
    
    static GetPluginsByCategory(category) {
        return this.categories.Has(category) ? this.categories[category] : []
    }
    
    static GetEnabledPlugins() {
        local enabled := []
        
        for pluginName, plugin in this.plugins {
            if (plugin["enabled"]) {
                enabled.Push(plugin)
            }
        }
        
        return enabled
    }
    
    static GetLoadedPlugins() {
        local loaded := []
        
        for pluginName, plugin in this.loadedPlugins {
            loaded.Push(plugin)
        }
        
        return loaded
    }
    
    static GetAllCategories() {
        local categories := []
        
        for category in this.categories {
            categories.Push(category)
        }
        
        return categories
    }
    
    static SearchPlugins(query) {
        local results := []
        query := StrLower(query)
        
        for pluginName, plugin in this.plugins {
            local searchText := StrLower(plugin["name"] . " " . plugin["metadata"]["description"])
            
            if (InStr(searchText, query)) {
                results.Push(plugin)
            }
        }
        
        return results
    }
    
    ; =============================================================================
    ; PLUGIN MANAGEMENT
    ; =============================================================================
    
    static EnablePlugin(pluginName) {
        if (this.plugins.Has(pluginName)) {
            this.plugins[pluginName]["enabled"] := true
            this.UpdatePluginMetadata(pluginName, Map("enabled", true))
            this.LogOperation("Enabled plugin: " . pluginName)
            return true
        }
        return false
    }
    
    static DisablePlugin(pluginName) {
        if (this.plugins.Has(pluginName)) {
            this.plugins[pluginName]["enabled"] := false
            this.UpdatePluginMetadata(pluginName, Map("enabled", false))
            
            ; Unload if currently loaded
            if (this.loadedPlugins.Has(pluginName)) {
                this.UnloadPlugin(pluginName)
            }
            
            this.LogOperation("Disabled plugin: " . pluginName)
            return true
        }
        return false
    }
    
    static SetPluginPriority(pluginName, priority) {
        if (this.plugins.Has(pluginName)) {
            this.plugins[pluginName]["priority"] := priority
            this.UpdatePluginMetadata(pluginName, Map("priority", priority))
            this.CategorizePlugins() ; Re-categorize to update sorting
            this.LogOperation("Set priority for plugin " . pluginName . " to " . priority)
            return true
        }
        return false
    }
    
    ; =============================================================================
    ; PLUGIN VALIDATION
    ; =============================================================================
    
    static ValidatePlugin(pluginName) {
        if (!this.plugins.Has(pluginName)) {
            return Map("valid", false, "errors", ["Plugin not found"])
        }
        
        local plugin := this.plugins[pluginName]
        local errors := []
        
        ; Check if file exists
        if (!FileExist(plugin["path"])) {
            errors.Push("Plugin file not found: " . plugin["path"])
        }
        
        ; Check metadata
        local metadata := plugin["metadata"]
        if (!metadata.Has("name") || metadata["name"] = "") {
            errors.Push("Plugin name is required")
        }
        if (!metadata.Has("version") || metadata["version"] = "") {
            errors.Push("Plugin version is required")
        }
        if (!metadata.Has("description") || metadata["description"] = "") {
            errors.Push("Plugin description is required")
        }
        
        ; Check dependencies
        if (metadata.Has("dependencies")) {
            for dependency in metadata["dependencies"] {
                if (!this.plugins.Has(Trim(dependency))) {
                    errors.Push("Dependency not found: " . dependency)
                }
            }
        }
        
        return Map("valid", errors.Length = 0, "errors", errors)
    }
    
    static ValidateAllPlugins() {
        local results := Map()
        
        for pluginName, plugin in this.plugins {
            results[pluginName] := this.ValidatePlugin(pluginName)
        }
        
        return results
    }
    
    ; =============================================================================
    ; UTILITY METHODS
    ; =============================================================================
    
    static LogOperation(message) {
        try {
            local logFile := A_Temp . "\plugin_manager.log"
            local timestamp := FormatTime(A_Now, "yyyy-MM-dd HH:mm:ss")
            FileAppend(timestamp . " - " . message . "`n", logFile)
        } catch {
            ; Ignore logging errors
        }
    }
    
    static GetPluginStats() {
        local stats := Map()
        
        stats["total"] := this.plugins.Length
        stats["enabled"] := 0
        stats["loaded"] := this.loadedPlugins.Length
        stats["categories"] := this.categories.Length
        
        for pluginName, plugin in this.plugins {
            if (plugin["enabled"]) {
                stats["enabled"]++
            }
        }
        
        return stats
    }
    
    static ExportPluginList(format := "json") {
        switch format {
            case "json":
                return this.ExportJSON()
            case "csv":
                return this.ExportCSV()
            default:
                return this.ExportText()
        }
    }
    
    static ExportJSON() {
        local json := "{`n"
        json .= "  `"plugins`": [`n"
        
        local first := true
        for pluginName, plugin in this.plugins {
            if (!first) {
                json .= ",`n"
            }
            first := false
            
            json .= "    {`n"
            json .= "      `"name`": `"" . plugin["name"] . "`,`n"
            json .= "      `"version`": `"" . plugin["metadata"]["version"] . "`,`n"
            json .= "      `"description`": `"" . plugin["metadata"]["description"] . "`,`n"
            json .= "      `"category`": `"" . plugin["category"] . "`,`n"
            json .= "      `"enabled`": " . (plugin["enabled"] ? "true" : "false") . ",`n"
            json .= "      `"loaded`": " . (this.loadedPlugins.Has(pluginName) ? "true" : "false") . "`n"
            json .= "    }"
        }
        
        json .= "`n  ]`n"
        json .= "}`n"
        
        return json
    }
    
    static ExportCSV() {
        local csv := "Name,Version,Description,Category,Enabled,Loaded`n"
        
        for pluginName, plugin in this.plugins {
            csv .= plugin["name"] . ","
            csv .= plugin["metadata"]["version"] . ","
            csv .= plugin["metadata"]["description"] . ","
            csv .= plugin["category"] . ","
            csv .= (plugin["enabled"] ? "true" : "false") . ","
            csv .= (this.loadedPlugins.Has(pluginName) ? "true" : "false") . "`n"
        }
        
        return csv
    }
    
    static ExportText() {
        local text := "Plugin List`n"
        text .= StrRepeat("=", 50) . "`n"
        
        for category, plugins in this.categories {
            text .= "`nCategory: " . category . "`n"
            text .= StrRepeat("-", 20) . "`n"
            
            for plugin in plugins {
                text .= "  " . plugin["name"] . " v" . plugin["metadata"]["version"] . "`n"
                text .= "    " . plugin["metadata"]["description"] . "`n"
                text .= "    Status: " . (plugin["enabled"] ? "Enabled" : "Disabled")
                if (this.loadedPlugins.Has(plugin["name"])) {
                    text .= " (Loaded)"
                }
                text .= "`n`n"
            }
        }
        
        return text
    }
}

; =============================================================================
; JSON UTILITY CLASS (Enhanced version)
; =============================================================================

class PluginJSON {
    static parse(jsonString) {
        ; Enhanced JSON parser for more complex objects
        local result := Map()
        
        ; Remove whitespace
        jsonString := RegExReplace(jsonString, "\s+", " ")
        
        ; Parse objects
        if (RegExMatch(jsonString, '\{([^}]*)\}', &match)) {
            local content := match[1]
            local pairs := StrSplit(content, ",")
            
            for pair in pairs {
                if (RegExMatch(pair, '"([^"]+)":\s*"([^"]*)"', &pairMatch)) {
                    result[pairMatch[1]] := pairMatch[2]
                } else if (RegExMatch(pair, '"([^"]+)":\s*(true|false)', &pairMatch)) {
                    result[pairMatch[1]] := (pairMatch[2] = "true")
                } else if (RegExMatch(pair, '"([^"]+)":\s*(\d+)', &pairMatch)) {
                    result[pairMatch[1]] := Integer(pairMatch[2])
                }
            }
        }
        
        return result
    }
    
    static stringify(obj, indent := 0) {
        ; Enhanced JSON stringifier
        local result := "{`n"
        local spaces := ""
        
        loop indent {
            spaces .= " "
        }
        
        local first := true
        for key, value in obj {
            if (!first) {
                result .= ",`n"
            }
            first := false
            
            result .= spaces . "  `"" . key . "`: "
            
            if (Type(value) = "Map") {
                result .= this.stringify(value, indent + 2)
            } else if (Type(value) = "Array") {
                result .= this.stringifyArray(value, indent + 2)
            } else if (Type(value) = "String") {
                result .= "`"" . value . "`""
            } else if (Type(value) = "Integer" || Type(value) = "Float") {
                result .= value
            } else if (Type(value) = "Boolean") {
                result .= (value ? "true" : "false")
            } else {
                result .= "`"" . value . "`""
            }
        }
        
        result .= "`n" . spaces . "}"
        return result
    }
    
    static stringifyArray(arr, indent := 0) {
        local result := "[`n"
        local spaces := ""
        
        loop indent {
            spaces .= " "
        }
        
        local first := true
        for value in arr {
            if (!first) {
                result .= ",`n"
            }
            first := false
            
            result .= spaces . "  "
            
            if (Type(value) = "Map") {
                result .= this.stringify(value, indent + 2)
            } else if (Type(value) = "Array") {
                result .= this.stringifyArray(value, indent + 2)
            } else if (Type(value) = "String") {
                result .= "`"" . value . "`""
            } else if (Type(value) = "Integer" || Type(value) = "Float") {
                result .= value
            } else if (Type(value) = "Boolean") {
                result .= (value ? "true" : "false")
            } else {
                result .= "`"" . value . "`""
            }
        }
        
        result .= "`n" . spaces . "]"
        return result
    }
}
