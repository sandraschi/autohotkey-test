#Requires AutoHotkey v2.0
#SingleInstance Force
#Warn

; IDE Shortcuts - Provides enhanced keyboard shortcuts for various IDEs
; Supports: VS Code, IntelliJ, Visual Studio, and more

; =============================================================================
; CONFIGURATION
; =============================================================================
; Add or modify IDEs and their specific shortcuts here
IDE_SHORTCUTS := Map(
    "code.exe", Map(  ; VS Code
        "format_document", "^!l",
        "comment_line", "^/",
        "uncomment_line", "^+/",
        "duplicate_line", "^d",
        "move_line_up", "!Up",
        "move_line_down", "!Down",
        "find_in_files", "^+f",
        "toggle_terminal", "^`",
        "toggle_sidebar", "^b",
        "command_palette", "^+p"
    ),
    "idea64.exe", Map(  ; IntelliJ
        "reformat_code", "^!l",
        "comment_line", "^/",
        "duplicate_line", "^d",
        "move_line_up", "^Shift Up",
        "move_line_down", "^Shift Down",
        "find_in_files", "^+f",
        "find_action", "^+a",
        "recent_files", "^e"
    ),
    "devenv.exe", Map(  ; Visual Studio
        "format_document", "^k^d",
        "comment_selection", "^k^c",
        "uncomment_selection", "^k^u",
        "duplicate_line", "^d",
        "move_line_up", "Alt+Up",
        "move_line_down", "Alt+Down",
        "find_in_files", "^+f",
        "quick_launch", "^,",
        "solution_explorer", "Ctrl+Alt+L"
    )
)

; =============================================================================
; HOTKEYS
; =============================================================================
; VS Code specific shortcuts
#HotIf WinActive("ahk_exe code.exe")
    ; Format Document
    ^!l:: Send("^k^f")
    
    ; Comment/Uncomment Line
    ^/:: Send("^k^c")
    ^+/:: Send("^k^u")
    
    ; Duplicate Line
    ^d:: Send("^d")
    
    ; Move Line Up/Down
    !Up:: Send("!{Up}")
    !Down:: Send("!{Down}")
    
    ; Find in Files
    ^+f:: Send("^+f")
    
    ; Toggle Terminal
    ^`:: Send("^`")
    
    ; Toggle Sidebar
    ^b:: Send("^b")
    
    ; Command Palette
    ^+p:: Send("^+p")
#HotIf

; IntelliJ specific shortcuts
#HotIf WinActive("ahk_exe idea64.exe")
    ; Reformat Code
    ^!l:: Send("^!l")
    
    ; Comment Line
    ^/:: Send("^/")
    
    ; Duplicate Line
    ^d:: Send("^d")
    
    ; Move Line Up/Down
    ^+Up:: Send("^+{Up}")
    ^+Down:: Send("^+{Down}")
    
    ; Find in Files
    ^+f:: Send("^+f")
    
    ; Find Action
    ^+a:: Send("^+a")
    
    ; Recent Files
    ^e:: Send("^e")
#HotIf

; Visual Studio specific shortcuts
#HotIf WinActive("ahk_exe devenv.exe")
    ; Format Document
    ^k^d:: Send("^k^d")
    
    ; Comment/Uncomment Selection
    ^k^c:: Send("^k^c")
    ^k^u:: Send("^k^u")
    
    ; Duplicate Line
    ^d:: Send("^d")
    
    ; Move Line Up/Down
    !Up:: Send("!{Up}")
    !Down:: Send("!{Down}")
    
    ; Find in Files
    ^+f:: Send("^+f")
    
    ; Quick Launch
    ^,:: Send("^,")
    
    ; Solution Explorer
    ^!l:: Send("^!l")
#HotIf

; =============================================================================
; FUNCTIONS
; =============================================================================
; Function to get current IDE's shortcuts
GetCurrentIDEShortcuts() {
    for process, shortcuts in IDE_SHORTCUTS {
        if WinActive("ahk_exe " process) {
            return shortcuts
        }
    }
    return ""
}

; Function to show current IDE's shortcuts in a tooltip
ShowCurrentShortcuts() {
    shortcuts := GetCurrentIDEShortcuts()
    if !IsObject(shortcuts) {
        ToolTip("No IDE-specific shortcuts found for this application")
        SetTimer () => ToolTip(), -2000
        return
    }
    
    tooltipText := "Current IDE Shortcuts:`n`n"
    for name, shortcut in shortcuts.OwnProps() {
        tooltipText .= Format("{1:-20} {2}`n", StrReplace(name, "_", " "), shortcut)
    }
    
    ToolTip(tooltipText)
    SetTimer () => ToolTip(), 5000  ; Hide after 5 seconds
}

; Show current IDE's shortcuts with Ctrl+Alt+?
^!?:: ShowCurrentShortcuts()

; =============================================================================
; AUTO-EXECUTE SECTION
; =============================================================================
; Set working directory to script's location
SetWorkingDir A_ScriptDir

; Show a notification when the script loads
TrayTip "IDE Shortcuts", "IDE Shortcuts script loaded", "Iconi"
SetTimer () => TrayTip(), 2000  ; Hide after 2 seconds
