; ==============================================================================
; ScriptletCOMBridge_v2.ahk - COMPLETE VERSION
; HTTP Bridge for HTML Launcher to execute AutoHotkey v2 scriptlets
; Version: 2.0
; Author: Sandra (with Claude assistance)
; Requires: AutoHotkey v2.0+
; ==============================================================================

#SingleInstance Force
#Requires AutoHotkey v2.0+
Persistent

; Include all parts in order
#Include ScriptletCOMBridge_v2_part1.ahk      ; Config & JSON
#Include ScriptletCOMBridge_v2_part2.ahk      ; Logger
#Include ScriptletCOMBridge_v2_part3.ahk      ; ScriptletManager
#Include ScriptletCOMBridge_v2_part4_fixed.ahk ; HTTPServer & Bridge
#Include ScriptletCOMBridge_v2_part5_final.ahk ; CLI & Main