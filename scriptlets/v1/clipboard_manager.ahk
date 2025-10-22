#NoEnv
#SingleInstance Force
#Persistent
#MaxHotkeysPerInterval 200
SetWorkingDir %A_ScriptDir%

; Initialize clipboard history array
ClipboardHistory := []
MaxHistory := 10

; Monitor clipboard changes
OnClipboardChange("ClipChanged")

; Toggle clipboard history menu with Win+V
#v::ShowClipboardMenu()

ClipChanged(Type) {
    global ClipboardHistory
    if (A_EventInfo = 1) {  ; Text was put on clipboard
        ; Add to history if not empty and not same as last item
        if (Clipboard != "" && (ClipboardHistory.Count() = 0 || Clipboard != ClipboardHistory[1])) {
            ClipboardHistory.InsertAt(1, Clipboard)
            
            ; Limit history size
            if (ClipboardHistory.Count() > MaxHistory) {
                ClipboardHistory.Pop()
            }
        }
    }
}

ShowClipboardMenu() {
    global ClipboardHistory
    
    if (ClipboardHistory.Count() = 0) {
        MsgBox, Clipboard history is empty
        return
    }
    
    Menu, ClipboardMenu, Add
    Menu, ClipboardMenu, DeleteAll
    
    ; Add items to menu
    for index, item in ClipboardHistory {
        ; Trim item for display
        displayText := StrReplace(SubStr(item, 1, 50), "`r`n", " ")
        if (StrLen(item) > 50) {
            displayText .= "..."
        }
        Menu, ClipboardMenu, Add, %index%. %displayText%, HandleClipboardSelection
    }
    
    Menu, ClipboardMenu, Show
}

HandleClipboardSelection() {
    global ClipboardHistory
    itemIndex := SubStr(A_ThisMenuItem, 1, InStr(A_ThisMenuItem, ".") - 1)
    if (itemIndex is "integer" && itemIndex >= 1 && itemIndex <= ClipboardHistory.Count()) {
        ; Move selected item to top of history
        selectedText := ClipboardHistory[itemIndex]
        ClipboardHistory.RemoveAt(itemIndex)
        ClipboardHistory.InsertAt(1, selectedText)
        
        ; Put selected text in clipboard
        Clipboard := selectedText
        SendInput ^v
    }
}
