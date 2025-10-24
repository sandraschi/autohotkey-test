# AutoHotkey Scriptlet Error Documentation

## Summary
This document contains all errors found in the AutoHotkey scriptlets during static analysis.

## Fixed Errors

### 1. linter.ahk
**File:** `utils/linter.ahk`
**Errors Fixed:**
- **Line 9:** `FileDelete(logFile)` → `try FileDelete(logFile)` (AutoHotkey v2 syntax)
- **Line 24:** `FileRead(fileContent, fileToCheck)` → `fileContent := FileRead(fileToCheck)` (AutoHotkey v2 syntax)
- **Line 129:** `FormatTime timestamp,, "yyyy-MM-dd HH:mm:ss"` → `FormatTime(timestamp, , "yyyy-MM-dd HH:mm:ss")` (AutoHotkey v2 syntax)
- **Line 248:** `FormatTime(timestamp, , "yyyy-MM-dd HH:mm:ss")` → `timestamp := FormatTime(A_Now, "yyyy-MM-dd HH:mm:ss")` (AutoHotkey v2 syntax)

### 2. quick_notes.ahk
**File:** `scriptlets/quick_notes.ahk`
**Errors Fixed:**
- **Line 139:** `FormatTime(currentDate, , "yyyy-MM-dd")` (Fixed AutoHotkey v2 syntax)
- **Line 167:** `FormatTime(currentDate, , "yyyy-MM-dd")` (Fixed AutoHotkey v2 syntax)
- **Line 179:** `FormatTime(currentDate, , "yyyy-MM-dd")` (Fixed AutoHotkey v2 syntax)
- **Line 199:** `FormatTime(currentDate, , "yyyy-MM-dd")` (Fixed AutoHotkey v2 syntax)
- **Line 220:** `FormatTime(currentDate, , "yyyy-MM-dd")` (Fixed AutoHotkey v2 syntax)
- **Line 221:** `FormatTime(currentDate, , "yyyy-MM-dd")` (Fixed AutoHotkey v2 syntax)
- **Line 275:** `FormatTime(currentDate, , "yyyy-MM-dd")` (Fixed AutoHotkey v2 syntax)

### 3. classic_pranks.ahk
**File:** `scriptlets/classic_pranks.ahk`
**Status:** Completely rewritten to AutoHotkey v2 syntax
**Issues:** File was written in AutoHotkey v1 syntax despite having `#Requires AutoHotkey v2.0` directive
**Solution:** Entire file converted to proper AutoHotkey v2 syntax

## Remaining Issues

### 1. dev_context_music.ahk
**File:** `scriptlets/dev_context_music.ahk`
**Status:** AutoHotkey v1 file
**Issues:** Uses AutoHotkey v1 syntax throughout
**Recommendation:** Convert to AutoHotkey v2 or add proper v1 compatibility

### 2. Linter Output Files
**Issue:** The linter runs without errors but does not create output files (`linter.log`, `lint_report.txt`)
**Status:** Under investigation
**Possible Causes:**
- File path issues
- Permission problems
- Silent failures in file operations

## Error Categories

### AutoHotkey v2 Compatibility Issues
1. **FormatTime Function:** Most common error - incorrect syntax between v1 and v2
2. **File Operations:** `FileDelete`, `FileRead`, `FileAppend` syntax differences
3. **Function Calls:** Parentheses and parameter passing differences
4. **String Operations:** `StringReplace`, `StringSplit` function changes

### Syntax Errors
1. **Missing Parentheses:** Function calls without proper parentheses
2. **Incorrect Parameter Passing:** Comma placement and parameter order
3. **Variable Assignment:** Missing assignment operators

## Recommendations

1. **Standardize on AutoHotkey v2:** All scriptlets should use v2 syntax
2. **Add Error Handling:** Implement proper try/catch blocks
3. **Create Test Suite:** Develop automated tests for scriptlet validation
4. **Documentation:** Maintain this error log for future reference

## Tools Created

1. **linter.ahk:** Main linting tool (fixed for v2 compatibility)
2. **batch_linter.ahk:** GUI tool for batch analysis
3. **scriptlet_validator.ahk:** Comprehensive validation tool
4. **test_linter.ahk:** Simplified test version

## Next Steps

1. Fix remaining linter output file creation issue
2. Convert remaining v1 scriptlets to v2
3. Implement comprehensive error reporting
4. Create automated testing pipeline
