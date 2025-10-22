# AutoHotkey v2 Syntax Migration Guide

## Overview
This document provides a comprehensive guide for migrating from AutoHotkey v1 to v2 syntax and fixing common errors that occur during the transition.

## Critical Syntax Changes

### 1. String Concatenation
**v1 (WRONG):**
```autohotkey
text := "Hello" "World"
result := "Value: " variable
```

**v2 (CORRECT):**
```autohotkey
text := "Hello" . "World"
result := "Value: " . variable
```

### 2. Function Calls
**v1 (WRONG):**
```autohotkey
FileRead content, filename
FileAppend text, filename
MsgBox "Hello World"
```

**v2 (CORRECT):**
```autohotkey
FileRead(content, filename)
FileAppend(text, filename)
MsgBox("Hello World")
```

### 3. Global Variables
**v1 (WRONG):**
```autohotkey
global var1, var2, var3
```

**v2 (CORRECT):**
```autohotkey
var1 := ""
var2 := ""
var3 := ""
```

### 4. Loop Syntax
**v1 (WRONG):**
```autohotkey
Loop Files, "*.txt" {
    ; code
}
```

**v2 (CORRECT):**
```autohotkey
Loop Files, "*.txt" {
    ; code
}
```

### 5. Hotkeys in Classes
**v1 (WRONG):**
```autohotkey
class MyClass {
    static SetupHotkeys() {
        F1::this.DoSomething()
    }
}
```

**v2 (CORRECT):**
```autohotkey
class MyClass {
    static SetupHotkeys() {
        ; Hotkeys must be defined globally, not in static methods
    }
}

; Define hotkeys globally
F1::MyClass.DoSomething()
```

### 6. Reserved Words
**v1 (WRONG):**
```autohotkey
if (condition) {
    continue  ; This is a reserved word in v2
}
```

**v2 (CORRECT):**
```autohotkey
if (condition) {
    ; Use different logic instead of 'continue'
    if (skipCondition) {
        ; Skip this iteration
    }
}
```

### 7. Exception Handling
**v1 (WRONG):**
```autohotkey
try {
    ; code
} catch Error as e {
    ; handle error
}
```

**v2 (CORRECT):**
```autohotkey
try {
    ; code
} catch as e {
    ; handle error
}
```

## Common Error Patterns to Fix

### Pattern 1: Missing Concatenation Operators
Search for: `"[A-Za-z0-9_]+"\s+[A-Za-z0-9_]+`
Replace with proper `.` concatenation

### Pattern 2: Function Calls Without Parentheses
Search for: `(FileRead|FileAppend|MsgBox|OutputDebug)\s+[^(]`
Add parentheses around parameters

### Pattern 3: Global Declarations
Search for: `global\s+[A-Za-z0-9_,\s]+`
Replace with individual variable declarations

### Pattern 4: Hotkeys in Static Methods
Search for: `[A-Za-z0-9_]+::.*this\.`
Move hotkeys to global scope

## Systematic Fix Process

### Step 1: String Concatenation
```bash
# Find all string concatenation issues
grep -n '"[A-Za-z0-9_]*"\s\+[A-Za-z0-9_]' *.ahk
grep -n '[A-Za-z0-9_]\s\+"[A-Za-z0-9_]*"' *.ahk
```

### Step 2: Function Calls
```bash
# Find function calls without parentheses
grep -n '\(FileRead\|FileAppend\|MsgBox\|OutputDebug\)\s\+[^(]' *.ahk
```

### Step 3: Global Variables
```bash
# Find global declarations
grep -n 'global\s\+' *.ahk
```

### Step 4: Reserved Words
```bash
# Find reserved word usage
grep -n '\bcontinue\b' *.ahk
grep -n '\bbreak\b' *.ahk
```

## Testing Checklist

- [ ] All string concatenation uses `.` operator
- [ ] All function calls have parentheses
- [ ] No `global` declarations
- [ ] No hotkeys in static methods
- [ ] No reserved words as variables
- [ ] Script runs without syntax errors
- [ ] All functionality works as expected

## Prevention Tips

1. **Use an IDE with v2 syntax highlighting**
2. **Enable strict mode**: `#Requires AutoHotkey v2.0+`
3. **Test frequently during development**
4. **Use this guide as a reference**
5. **Create templates with correct v2 syntax**

## Quick Reference Card

| v1 Syntax | v2 Syntax |
|-----------|-----------|
| `"text" variable` | `"text" . variable` |
| `FileRead var, file` | `FileRead(var, file)` |
| `global var1, var2` | `var1 := ""`<br>`var2 := ""` |
| `continue` | Restructure logic |
| `Hotkey::code` in class | `Hotkey::Class.Method()` |

## Common Gotchas

1. **String concatenation is the most common error**
2. **Function calls must have parentheses**
3. **Global variables work differently**
4. **Hotkeys can't be defined in static methods**
5. **Some reserved words changed**

## Tools for Migration

1. **AutoHotkey v2 Documentation**: https://www.autohotkey.com/docs/v2/
2. **Migration Guide**: https://www.autohotkey.com/docs/v2/v2-changes.htm
3. **Syntax Checker**: Use `AutoHotkey64.exe /ErrorStdOut script.ahk`

---

**Remember**: AutoHotkey v2 is stricter about syntax, but this prevents many runtime errors and makes code more maintainable.
