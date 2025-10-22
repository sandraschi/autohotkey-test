; ==============================================================================
; Smart Clipboard Manager
; @name: Smart Clipboard Manager
; @version: 2.0.0
; @description: Advanced clipboard management with history, formatting, and smart paste
; @category: utilities
; @author: Sandra
; @hotkeys: #v, ^!c, ^!v
; @enabled: true
; ==============================================================================

#Requires AutoHotkey v2.0+
#SingleInstance Force

class SmartClipboardManager {
    static history := []
    static maxHistory := 50
    static currentIndex := 0
    
    static Init() {
        ; Monitor clipboard changes
        OnClipboardChange(this.ClipboardChanged.Bind(this))
        
        ; Create GUI
        this.CreateGUI()
        
        ; Load history from file
        this.LoadHistory()
    }
    
    static ClipboardChanged(type) {
        if (type = 1) { ; Text
            text := ClipboardAll()
            if (StrLen(text) > 0 && text != this.history[this.history.Length]) {
                this.history.Push(text)
                if (this.history.Length > this.maxHistory) {
                    this.history.RemoveAt(1)
                }
                this.SaveHistory()
            }
        }
    }
    
    static CreateGUI() {
        this.gui := Gui("+Resize +MinSize400x300", "Smart Clipboard Manager")
        
        ; Menu bar
        this.gui.MenuBar := MenuBar()
        this.gui.MenuBar.Add("&File", Menu())
        this.gui.MenuBar.Add("&Edit", Menu())
        this.gui.MenuBar.Add("&View", Menu())
        
        ; Toolbar
        toolbar := this.gui.Add("Text", "w400 h30 Background0xE0E0E0", "📋 Smart Clipboard Manager")
        
        ; Search box
        searchBox := this.gui.Add("Edit", "w300 h25", "")
        searchBox.OnEvent("Change", this.SearchHistory.Bind(this))
        
        ; History list
        this.historyList := this.gui.Add("ListView", "w400 h200 Checked", ["#", "Content", "Time", "Size"])
        this.historyList.OnEvent("DoubleClick", this.PasteSelected.Bind(this))
        this.historyList.OnEvent("ItemSelect", this.ShowPreview.Bind(this))
        
        ; Preview area
        this.previewArea := this.gui.Add("Edit", "w400 h100 ReadOnly", "")
        
        ; Buttons
        buttonPanel := this.gui.Add("Text", "w400 h40")
        pasteBtn := this.gui.Add("Button", "x10 y10 w80 h25", "Paste")
        copyBtn := this.gui.Add("Button", "x100 y10 w80 h25", "Copy")
        clearBtn := this.gui.Add("Button", "x190 y10 w80 h25", "Clear")
        formatBtn := this.gui.Add("Button", "x280 y10 w80 h25", "Format")
        
        pasteBtn.OnEvent("Click", this.PasteSelected.Bind(this))
        copyBtn.OnEvent("Click", this.CopySelected.Bind(this))
        clearBtn.OnEvent("Click", this.ClearHistory.Bind(this))
        formatBtn.OnEvent("Click", this.FormatText.Bind(this))
        
        this.gui.Show("w420 h400")
    }
    
    static SearchHistory(*) {
        searchText := this.gui.Control["Edit1"].Text
        this.historyList.Delete()
        
        for i, item in this.history {
            if (InStr(item, searchText)) {
                preview := StrLen(item) > 50 ? SubStr(item, 1, 50) . "..." : item
                time := FormatTime(, "HH:mm:ss")
                this.historyList.Add("", i, preview, time, StrLen(item))
            }
        }
    }
    
    static ShowPreview(*) {
        selected := this.historyList.GetNext()
        if (selected > 0) {
            index := this.historyList.GetText(selected, 2)
            this.previewArea.Text := this.history[index]
        }
    }
    
    static PasteSelected(*) {
        selected := this.historyList.GetNext()
        if (selected > 0) {
            index := this.historyList.GetText(selected, 2)
            text := this.history[index]
            SendText(text)
        }
    }
    
    static CopySelected(*) {
        selected := this.historyList.GetNext()
        if (selected > 0) {
            index := this.historyList.GetText(selected, 2)
            Clipboard := this.history[index]
        }
    }
    
    static ClearHistory(*) {
        this.history := []
        this.historyList.Delete()
        this.SaveHistory()
    }
    
    static FormatText(*) {
        text := this.previewArea.Text
        if (text) {
            ; Remove extra whitespace
            text := RegExReplace(text, "\s+", " ")
            text := Trim(text)
            
            ; Capitalize first letter of sentences
            text := RegExReplace(text, "([.!?]\s+)([a-z])", "$1" . Chr(Asc("$2") - 32))
            
            this.previewArea.Text := text
            Clipboard := text
        }
    }
    
    static LoadHistory() {
        try {
            if (FileExist("clipboard_history.json")) {
                fileContent := FileRead("clipboard_history.json")
                this.history := JSON.parse(fileContent)
            }
        } catch {
            this.history := []
        }
    }
    
    static SaveHistory() {
        try {
            jsonContent := JSON.stringify(this.history)
            FileAppend(jsonContent, "clipboard_history.json")
        } catch {
            ; Silent fail
        }
    }
}

; Hotkeys
#v::SmartClipboardManager.Init()
^!c::SmartClipboardManager.Init()
^!v::SmartClipboardManager.PasteSelected()

; Initialize
SmartClipboardManager.Init()
