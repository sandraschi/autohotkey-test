#Requires AutoHotkey v2.0+
; =============================================================================
; TestFramework.ahk - Simple Testing Framework for AutoHotkey
; Version: 1.0
; Author: Sandra (with Claude assistance)
; Purpose: Unit and integration testing for AutoHotkey scripts
; =============================================================================

class TestFramework {
    static tests := []
    static results := Map()
    static currentSuite := ""
    static currentTest := ""
    static assertions := 0
    static failures := 0
    
    ; =============================================================================
    ; TEST SUITE MANAGEMENT
    ; =============================================================================
    
    static StartSuite(suiteName) {
        this.currentSuite := suiteName
        this.tests.Push(Map("suite", suiteName, "tests", []))
        this.Log("Starting test suite: " . suiteName)
    }
    
    static EndSuite() {
        this.Log("Completed test suite: " . this.currentSuite)
        this.currentSuite := ""
    }
    
    static StartTest(testName) {
        this.currentTest := testName
        this.assertions := 0
        this.failures := 0
        this.Log("  Starting test: " . testName)
    }
    
    static EndTest() {
        local result := Map(
            "name", this.currentTest,
            "assertions", this.assertions,
            "failures", this.failures,
            "passed", this.failures = 0
        )
        
        ; Add to current suite
        for suite in this.tests {
            if (suite["suite"] = this.currentSuite) {
                suite["tests"].Push(result)
                break
            }
        }
        
        if (result["passed"]) {
            this.Log("  ✓ PASSED: " . this.currentTest . " (" . this.assertions . " assertions)")
        } else {
            this.Log("  ✗ FAILED: " . this.currentTest . " (" . this.failures . " failures)")
        }
        
        this.currentTest := ""
    }
    
    ; =============================================================================
    ; ASSERTION METHODS
    ; =============================================================================
    
    static Assert(condition, message := "") {
        this.assertions++
        
        if (!condition) {
            this.failures++
            local errorMsg := "Assertion failed"
            if (message) {
                errorMsg .= ": " . message
            }
            this.Log("    ✗ " . errorMsg)
            return false
        }
        
        return true
    }
    
    static AssertEqual(actual, expected, message := "") {
        local passed := actual = expected
        if (!passed) {
            local errorMsg := "Expected '" . expected . "', got '" . actual . "'"
            if (message) {
                errorMsg := message . " - " . errorMsg
            }
            this.Assert(false, errorMsg)
        } else {
            this.Assert(true, message)
        }
        return passed
    }
    
    static AssertNotEqual(actual, expected, message := "") {
        local passed := actual != expected
        if (!passed) {
            local errorMsg := "Expected not equal to '" . expected . "', got '" . actual . "'"
            if (message) {
                errorMsg := message . " - " . errorMsg
            }
            this.Assert(false, errorMsg)
        } else {
            this.Assert(true, message)
        }
        return passed
    }
    
    static AssertTrue(condition, message := "") {
        return this.Assert(condition, message ? message : "Expected true")
    }
    
    static AssertFalse(condition, message := "") {
        return this.Assert(!condition, message ? message : "Expected false")
    }
    
    static AssertFileExists(filePath, message := "") {
        local exists := FileExist(filePath)
        if (!exists) {
            local errorMsg := "File does not exist: " . filePath
            if (message) {
                errorMsg := message . " - " . errorMsg
            }
            this.Assert(false, errorMsg)
        } else {
            this.Assert(true, message)
        }
        return exists
    }
    
    static AssertDirExists(dirPath, message := "") {
        local exists := DirExist(dirPath)
        if (!exists) {
            local errorMsg := "Directory does not exist: " . dirPath
            if (message) {
                errorMsg := message . " - " . errorMsg
            }
            this.Assert(false, errorMsg)
        } else {
            this.Assert(true, message)
        }
        return exists
    }
    
    static AssertThrows(function, message := "") {
        local threw := false
        try {
            function()
        } catch {
            threw := true
        }
        
        if (!threw) {
            local errorMsg := "Expected function to throw an exception"
            if (message) {
                errorMsg := message . " - " . errorMsg
            }
            this.Assert(false, errorMsg)
        } else {
            this.Assert(true, message)
        }
        return threw
    }
    
    ; =============================================================================
    ; TEST EXECUTION
    ; =============================================================================
    
    static RunAllTests() {
        this.Log("=" . StrRept("=", 50))
        this.Log("Running All Tests")
        this.Log("=" . StrRepeat("=", 50))
        
        local totalTests := 0
        local totalAssertions := 0
        local totalFailures := 0
        local passedSuites := 0
        
        for suite in this.tests {
            this.Log("")
            this.Log("Suite: " . suite["suite"])
            this.Log("-" . StrRepeat("-", 30))
            
            local suitePassed := true
            
            for test in suite["tests"] {
                totalTests++
                totalAssertions += test["assertions"]
                totalFailures += test["failures"]
                
                if (!test["passed"]) {
                    suitePassed := false
                }
            }
            
            if (suitePassed) {
                passedSuites++
            }
        }
        
        this.Log("")
        this.Log("=" . StrRepeat("=", 50))
        this.Log("Test Results Summary")
        this.Log("=" . StrRepeat("=", 50))
        this.Log("Suites: " . this.tests.Length . " (" . passedSuites . " passed)")
        this.Log("Tests: " . totalTests)
        this.Log("Assertions: " . totalAssertions)
        this.Log("Failures: " . totalFailures)
        
        if (totalFailures = 0) {
            this.Log("Status: ALL TESTS PASSED ✓")
        } else {
            this.Log("Status: " . totalFailures . " TESTS FAILED ✗")
        }
        
        return totalFailures = 0
    }
    
    static RunSuite(suiteName) {
        for suite in this.tests {
            if (suite["suite"] = suiteName) {
                this.Log("Running suite: " . suiteName)
                
                for test in suite["tests"] {
                    this.Log("  Running test: " . test["name"])
                    ; Test execution would happen here
                }
                
                return true
            }
        }
        
        this.Log("Suite not found: " . suiteName)
        return false
    }
    
    ; =============================================================================
    ; UTILITY METHODS
    ; =============================================================================
    
    static Log(message) {
        local timestamp := FormatTime(A_Now, "HH:mm:ss")
        local logMessage := "[" . timestamp . "] " . message
        
        ; Output to console
        OutputDebug(logMessage)
        
        ; Also write to log file
        try {
            FileAppend(logMessage . "`n", A_ScriptDir . "\test_results.log")
        } catch {
            ; Ignore logging errors
        }
    }
    
    static ClearResults() {
        this.tests := []
        this.results := Map()
        this.currentSuite := ""
        this.currentTest := ""
        this.assertions := 0
        this.failures := 0
    }
    
    static GetResults() {
        return this.tests
    }
    
    static ExportResults(format := "json") {
        switch format {
            case "json":
                return this.ExportJSON()
            case "html":
                return this.ExportHTML()
            default:
                return this.ExportText()
        }
    }
    
    static ExportJSON() {
        local json := "{`n"
        json .= "  `"suites`": [`n"
        
        for i, suite in this.tests {
            json .= "    {`n"
            json .= "      `"name`": `"" . suite["suite"] . "`,`n"
            json .= "      `"tests`": [`n"
            
            for j, test in suite["tests"] {
                json .= "        {`n"
                json .= "          `"name`": `"" . test["name"] . "`,`n"
                json .= "          `"assertions`": " . test["assertions"] . ",`n"
                json .= "          `"failures`": " . test["failures"] . ",`n"
                json .= "          `"passed`": " . (test["passed"] ? "true" : "false") . "`n"
                json .= "        }"
                if (j < suite["tests"].Length) {
                    json .= ","
                }
                json .= "`n"
            }
            
            json .= "      ]`n"
            json .= "    }"
            if (i < this.tests.Length) {
                json .= ","
            }
            json .= "`n"
        }
        
        json .= "  ]`n"
        json .= "}`n"
        
        return json
    }
    
    static ExportHTML() {
        local html := "<!DOCTYPE html>`n"
        html .= "<html><head><title>Test Results</title></head><body>`n"
        html .= "<h1>Test Results</h1>`n"
        
        for suite in this.tests {
            html .= "<h2>" . suite["suite"] . "</h2>`n"
            html .= "<table border='1'>`n"
            html .= "<tr><th>Test</th><th>Assertions</th><th>Failures</th><th>Status</th></tr>`n"
            
            for test in suite["tests"] {
                local status := test["passed"] ? "✓ PASSED" : "✗ FAILED"
                local statusColor := test["passed"] ? "green" : "red"
                
                html .= "<tr>"
                html .= "<td>" . test["name"] . "</td>"
                html .= "<td>" . test["assertions"] . "</td>"
                html .= "<td>" . test["failures"] . "</td>"
                html .= "<td style='color: " . statusColor . "'>" . status . "</td>"
                html .= "</tr>`n"
            }
            
            html .= "</table>`n"
        }
        
        html .= "</body></html>`n"
        return html
    }
    
    static ExportText() {
        local text := "Test Results`n"
        text .= StrRepeat("=", 50) . "`n"
        
        for suite in this.tests {
            text .= "Suite: " . suite["suite"] . "`n"
            text .= StrRepeat("-", 30) . "`n"
            
            for test in suite["tests"] {
                local status := test["passed"] ? "✓ PASSED" : "✗ FAILED"
                text .= "  " . test["name"] . " - " . status . " (" . test["assertions"] . " assertions)`n"
            }
            
            text .= "`n"
        }
        
        return text
    }
}

; =============================================================================
; TEST DECORATORS (Helper functions for cleaner test syntax)
; =============================================================================

TestSuite(name, testFunction) {
    TestFramework.StartSuite(name)
    try {
        testFunction()
    } catch as e {
        TestFramework.Log("Suite failed: " . e.Message)
    }
    TestFramework.EndSuite()
}

Test(name, testFunction) {
    TestFramework.StartTest(name)
    try {
        testFunction()
    } catch as e {
        TestFramework.Log("Test failed: " . e.Message)
        TestFramework.Assert(false, "Test exception: " . e.Message)
    }
    TestFramework.EndTest()
}

; =============================================================================
; ASSERTION HELPERS
; =============================================================================

Assert(condition, message := "") {
    return TestFramework.Assert(condition, message)
}

AssertEqual(actual, expected, message := "") {
    return TestFramework.AssertEqual(actual, expected, message)
}

AssertNotEqual(actual, expected, message := "") {
    return TestFramework.AssertNotEqual(actual, expected, message)
}

AssertTrue(condition, message := "") {
    return TestFramework.AssertTrue(condition, message)
}

AssertFalse(condition, message := "") {
    return TestFramework.AssertFalse(condition, message)
}

AssertFileExists(filePath, message := "") {
    return TestFramework.AssertFileExists(filePath, message)
}

AssertDirExists(dirPath, message := "") {
    return TestFramework.AssertDirExists(dirPath, message)
}

AssertThrows(function, message := "") {
    return TestFramework.AssertThrows(function, message)
}
