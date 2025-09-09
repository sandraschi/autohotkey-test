; ==============================================================================
; ScriptletCOMBridge_v2.ahk
; HTTP Bridge for HTML Launcher to execute AutoHotkey v2 scriptlets
; Version: 2.0
; Author: Sandra (with Claude assistance)
; Requires: AutoHotkey v2.0+
; ==============================================================================

#SingleInstance Force
#Requires AutoHotkey v2.0+
Persistent

; ==============================================================================
; CONFIGURATION & GLOBALS
; ==============================================================================

class Config {
    static VERSION := "2.0"
    static SERVER_PORT := 8765
    static SERVER_HOST := "localhost"
    static SCRIPTLET_PATH := A_ScriptDir . "\scriptlets\"
    static LOG_PATH := A_ScriptDir . "\logs\"
    static TEMP_PATH := A_Temp . "\scriptlet_bridge\"
    static MAX_LOG_SIZE := 10 * 1024 * 1024  ; 10MB
    static LOG_RETENTION_DAYS := 7
}

; Global variables
g_ServerProcess := ""
g_IsRunning := false
g_Logger := ""
g_ScriptletManager := ""
g_Bridge := ""

; ==============================================================================
; JSON UTILITY CLASS
; ==============================================================================

class JSON {
    static stringify(obj) {
        if (IsObject(obj)) {
            if (obj is Array) {
                items := []
                for item in obj {
                    items.Push(this.stringify(item))
                }
                return "[" . this.Join(items, ",") . "]"
            } else if (obj is Map) {
                items := []
                for key, value in obj {
                    items.Push('"' . this.Escape(key) . '":' . this.stringify(value))
                }
                return "{" . this.Join(items, ",") . "}"
            } else {
                ; Regular object
                items := []
                for prop in obj.OwnProps() {
                    try {
                        items.Push('"' . this.Escape(prop) . '":' . this.stringify(obj.%prop%))
                    } catch {
                        continue
                    }
                }
                return "{" . this.Join(items, ",") . "}"
            }
        } else if (IsNumber(obj)) {
            return String(obj)
        } else if (obj = true || obj = false) {
            return obj ? "true" : "false"
        } else {
            return '"' . this.Escape(String(obj)) . '"'
        }
    }
    
    static Escape(str) {
        str := StrReplace(str, '\', '\\')
        str := StrReplace(str, '"', '\"')
        str := StrReplace(str, '`n', '\n')
        str := StrReplace(str, '`r', '\r')
        str := StrReplace(str, '`t', '\t')
        return str
    }
    
    static Join(arr, delimiter) {
        result := ""
        for i, item in arr {
            result .= (i > 1 ? delimiter : "") . item
        }
        return result
    }
}