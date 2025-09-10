#Requires AutoHotkey v2.0+
; Enhanced AutoHotkey v2 Scripts for Claude Desktop MCP Development
; Version 2.0 - Complete Enhanced Edition - SYNTAX FIXED
; Compatible with AutoHotkey v2.0+
; 
; Author: Sandra (sandraschi)
; Date: 2025-09-09
; Purpose: Advanced MCP development automation with AI integration

; =============================================================================
; CONFIGURATION & GLOBALS
; =============================================================================

REPOS_DIR := "D:\Dev\repos"
CLAUDE_CONFIG := "C:\Users\sandr\AppData\Roaming\Claude\claude_desktop_config.json"
CLAUDE_LOGS := "C:\Users\sandr\AppData\Roaming\Claude\logs\"
CLAUDE_EXE := "C:\Users\sandr\AppData\Local\AnthropicClaude\app-0.12.129\claude.exe"
PYTHON_EXE := "C:\Users\sandr\AppData\Local\Programs\Python\Python313\python.exe"
TEMP_DIR := "C:\temp\"

global LastOperation := ""
global OperationTime := ""

; =============================================================================
; UTILITY FUNCTIONS
; =============================================================================

LogOperation(operation) {
    global LastOperation, OperationTime
    LastOperation := operation
    OperationTime := A_Now
    try {
        FileAppend A_Now . " - " . operation . "`n", TEMP_DIR . "ahk_operations.log"
    } catch {
        ; Ignore logging errors
    }
}

SendClaudeMessage(message) {
    try {
        WinActivate "Claude"
        Sleep 500
        SendText message
        Send "{Enter}"
    } catch {
        ; Ignore if Claude not active
    }
}

ShowStatus() {
    global LastOperation, OperationTime
    status := "Last Operation: " . LastOperation
    if (OperationTime != "")
        status .= "`nTime: " . OperationTime
    TrayTip "MCP Development Status", status, 3
}

ShowStartupNotification() {
    TrayTip "MCP Development Scripts", "AutoHotkey MCP Scripts loaded! Press Ctrl+Shift+H for help", 3
}

; =============================================================================
; CORE MCP DEVELOPMENT SCRIPTS
; =============================================================================

; Advanced MCP Server Scaffolding (Ctrl+Shift+M)
^+m::
{
    LogOperation("MCP Server Scaffolding")
    projectName := InputBox("New MCP Server", "Enter MCP server name (without -mcp suffix):", "w350 h130").value
    if (projectName == "") 
        return
    
    description := InputBox("MCP Server Description", "Brief description:", "w400 h130").value
    if (description == "") 
        description := "A Claude MCP server for " . projectName
    
    prompt := "Create new MCP server: " . projectName . "-mcp`n"
    prompt .= "Description: " . description . "`n`n"
    prompt .= "Requirements:`n"
    prompt .= "- Use fastmcp 2.12.1+ (latest stable)`n"
    prompt .= "- Create in: D:\Dev\repos\" . projectName . "-mcp`n"
    prompt .= "- Include comprehensive error handling`n"
    prompt .= "- Implement proper logging with timestamps`n"
    prompt .= "- Add config validation with schemas`n"
    prompt .= "- Create README with installation guide`n"
    prompt .= "- Include pyproject.toml for DXT packaging`n"
    prompt .= "- Add proper type hints throughout`n"
    prompt .= "- Include example usage and troubleshooting`n"
    prompt .= "- Create GitHub Actions workflow`n"
    prompt .= "- Add comprehensive test suite`n`n"
    prompt .= "Generate complete project structure with all files."
    
    SendText prompt
    Sleep 2000
    Send "{Enter}"
    Sleep 1000
    SendText "Write to basic memory: Created " . projectName . "-mcp scaffolding at " . A_Now . " [" . projectName . "-mcp, scaffold, created, high]"
}

; Standards Conformance Checker (Ctrl+Shift+C)
^+c::
{
    LogOperation("Standards Conformance Check")
    projectPath := InputBox("Project Path", "Enter project path (relative to D:\Dev\repos\):", "w400 h130").value
    if (projectPath == "") 
        projectPath := "current directory"
    
    prompt := "Run comprehensive MCP standards conformance check`n"
    prompt .= "Project: " . projectPath . "`n`n"
    prompt .= "Validation Checklist:`n"
    prompt .= "✅ FastMCP 2.12+ compatibility`n"
    prompt .= "✅ Proper tool registration patterns`n"
    prompt .= "✅ Comprehensive error handling`n"
    prompt .= "✅ Config schema validation`n"
    prompt .= "✅ Structured logging implementation`n"
    prompt .= "✅ Startup sequence validation`n"
    prompt .= "✅ Claude Desktop integration test`n"
    prompt .= "✅ Memory leak prevention`n"
    prompt .= "✅ Resource cleanup on shutdown`n"
    prompt .= "✅ Type safety and hints`n"
    prompt .= "✅ Documentation completeness`n"
    prompt .= "✅ DXT packaging compatibility`n`n"
    prompt .= "Generate detailed compliance report with specific fixes and optimizations."
    
    SendText prompt
}

; Advanced Log Analyzer (Ctrl+Shift+L)
^+l::
{
    LogOperation("Log Analysis")
    mcpServer := InputBox("MCP Server", "Enter MCP server name (leave empty for all):", "w350 h130").value
    
    logPattern := mcpServer != "" ? "mcp-server-" . mcpServer . "-mcp.log" : "mcp-server-*.log"
    
    prompt := "Advanced Claude Desktop MCP log analysis`n"
    prompt .= "Log location: " . CLAUDE_LOGS . "`n"
    prompt .= "Pattern: " . logPattern . "`n`n"
    prompt .= "Analysis Tasks:`n"
    prompt .= "1. Read and parse latest log files`n"
    prompt .= "2. Identify error patterns and frequency`n"
    prompt .= "3. Track connection stability metrics`n"
    prompt .= "4. Detect performance bottlenecks`n"
    prompt .= "5. Find resource usage anomalies`n"
    prompt .= "6. Check tool execution success rates`n`n"
    prompt .= "Error Categories:`n"
    prompt .= "🔴 Critical: Connection failures, crashes`n"
    prompt .= "🟡 Warning: Timeouts, retries, deprecations`n"
    prompt .= "🔵 Info: Performance metrics, usage stats`n`n"
    prompt .= "Provide root cause analysis and specific fix recommendations."
    
    SendText prompt
}

; =============================================================================
; ADVANCED WORKFLOW SCRIPTS
; =============================================================================

; AI Smart Troubleshooter (Ctrl+Shift+T)
^+t::
{
    LogOperation("Smart Troubleshooting")
    
    SendText "🔧 AI-Powered MCP Troubleshooting Sequence`n"
    SendText "=====================================`n`n"
    SendText "Phase 1: System State Analysis - Checking MCP server statuses`n"
    Sleep 1500
    Send "{Enter}"
    Sleep 2000
    SendText "Phase 2: Configuration Validation - Analyzing Claude Desktop config`n"
    Sleep 1500
    Send "{Enter}"
    Sleep 2000
    SendText "Phase 3: Log Pattern Analysis - Processing recent error patterns`n"
    Sleep 1500
    Send "{Enter}"
    Sleep 2000
    SendText "`n🎯 Generate comprehensive diagnostic report with:`n"
    SendText "- Priority-ranked issues`n"
    SendText "- Step-by-step fix instructions`n"
    SendText "- Code patches where needed`n"
    SendText "- Preventive measures`n"
    SendText "- Monitoring recommendations"
}

; Enhanced Development Cycle (Ctrl+Shift+D)
^+d::
{
    LogOperation("Development Cycle")
    
    prompt := "🚀 Enhanced MCP Development Lifecycle`n"
    prompt .= "======================================`n`n"
    prompt .= "Phase 1: Code Quality Analysis`n"
    prompt .= "- Static analysis with ruff and mypy`n"
    prompt .= "- Security scan with bandit`n"
    prompt .= "- FastMCP 2.12+ compatibility check`n"
    prompt .= "- Performance profiling`n`n"
    prompt .= "Phase 2: Automated Testing`n"
    prompt .= "- Unit test execution with pytest`n"
    prompt .= "- Integration testing with Claude Desktop`n"
    prompt .= "- Error handling validation`n"
    prompt .= "- Load testing for tool performance`n`n"
    prompt .= "Phase 3: Documentation Generation`n"
    prompt .= "- Auto-generate API docs from docstrings`n"
    prompt .= "- Update README with latest features`n"
    prompt .= "- Create troubleshooting guides`n`n"
    prompt .= "Phase 4: Packaging & Distribution`n"
    prompt .= "- DXT package validation`n"
    prompt .= "- Version bump and changelog`n"
    prompt .= "- GitHub release creation`n`n"
    prompt .= "Execute full pipeline and report results."
    
    SendText prompt
}

; =============================================================================
; SYSTEM MANAGEMENT
; =============================================================================

; Intelligent Claude Desktop Restart (Ctrl+Alt+R)
^!r::
{
    LogOperation("Claude Desktop Restart")
    TrayTip "Restarting Claude Desktop", "Gracefully closing and restarting...", 2
    
    try {
        WinActivate "Claude"
        Sleep 500
        Send "!{F4}"
        Sleep 3000
        WinWaitClose "Claude",, 10
    } catch {
        Run "taskkill /f /im Claude.exe",, "Hide"
        Sleep 2000
    }
    
    try {
        FileDelete TEMP_DIR . "claude_restart.lock"
    } catch {
    }
    
    Run CLAUDE_EXE
    Sleep 3000
    TrayTip "Claude Desktop Restarted", "Ready for MCP development!", 2
    SendClaudeMessage("Claude Desktop restarted at " . A_Now . " - MCP servers should reconnect automatically")
}

; Emergency Restart (Ctrl+Alt+X)
^!x::
{
    LogOperation("Emergency Restart")
    TrayTip "Emergency Restart", "Force killing and restarting...", 2
    
    Run "taskkill /f /im Claude.exe /t",, "Hide"
    Run "taskkill /f /im python.exe /f",, "Hide"
    
    Sleep 3000
    
    try {
        FileDelete TEMP_DIR . "claude_*.lock"
        FileDelete TEMP_DIR . "mcp_*.tmp"
    } catch {
    }
    
    Run CLAUDE_EXE
    TrayTip "Emergency Restart Complete", "Claude Desktop restarted fresh!", 3
}

; Hot Config Reload (Ctrl+Shift+R)
^+r::
{
    LogOperation("Config Hot Reload")
    
    prompt := "🔄 Claude Desktop Config Hot Reload`n"
    prompt .= "================================`n`n"
    prompt .= "Operations:`n"
    prompt .= "1. Backup current config: " . CLAUDE_CONFIG . "`n"
    prompt .= "2. Validate JSON syntax and MCP server configs`n"
    prompt .= "3. Check Python executable paths`n"
    prompt .= "4. Verify MCP server availability`n"
    prompt .= "5. Test configuration compatibility`n"
    prompt .= "6. Apply changes and restart Claude Desktop`n`n"
    prompt .= "Safety features:`n"
    prompt .= "- Config rollback on failure`n"
    prompt .= "- Syntax validation before apply`n"
    prompt .= "- MCP server health checks`n`n"
    prompt .= "Proceed with hot reload sequence?"
    
    SendText prompt
    Sleep 5000
    SendText "`n`nConfig validated - triggering restart...`n"
    Sleep 2000
    Send "^!r"
}

; =============================================================================
; FILE & PROJECT MONITORING
; =============================================================================

; Advanced File Watcher (Ctrl+Shift+W)
^+w::
{
    LogOperation("File Watcher Setup")
    
    prompt := "🔍 Advanced MCP File Monitoring System`n"
    prompt .= "=====================================`n`n"
    prompt .= "Monitoring Targets:`n"
    prompt .= "📁 MCP Projects: " . REPOS_DIR . "\\*-mcp\\`n"
    prompt .= "⚙️  Claude Config: " . CLAUDE_CONFIG . "`n"
    prompt .= "📋 Log Directory: " . CLAUDE_LOGS . "`n"
    prompt .= "🐍 Python Environment: " . PYTHON_EXE . "`n`n"
    prompt .= "Smart Triggers:`n"
    prompt .= "• Code Changes → Auto-validation & testing`n"
    prompt .= "• Config Changes → Syntax check & restart prompt`n"
    prompt .= "• New Errors → AI troubleshooting activation`n"
    prompt .= "• Performance Issues → Resource analysis`n`n"
    prompt .= "AI Features:`n"
    prompt .= "- Pattern recognition for common issues`n"
    prompt .= "- Predictive problem detection`n"
    prompt .= "- Auto-fix suggestions for simple issues`n"
    prompt .= "- Performance optimization recommendations`n`n"
    prompt .= "Start comprehensive monitoring with AI analysis?"
    
    SendText prompt
}

; Enhanced DXT Package Management (Ctrl+Shift+P)
^+p::
{
    LogOperation("DXT Package Validation")
    
    projectDir := InputBox("Project Directory", "Enter project directory name:", "w350 h130").value
    if (projectDir == "") 
        projectDir := "[current project]"
    
    prompt := "📦 Enhanced DXT Package Management`n"
    prompt .= "================================`n"
    prompt .= "Project: " . projectDir . "`n`n"
    prompt .= "Validation Pipeline:`n"
    prompt .= "1. 🔍 Run 'dxt validate' with detailed reporting`n"
    prompt .= "2. 📋 Analyze package.json structure and metadata`n"
    prompt .= "3. 🔗 Verify all dependencies and versions`n"
    prompt .= "4. 🧪 Test installation in clean environment`n"
    prompt .= "5. ⚡ Validate tool exports and functionality`n"
    prompt .= "6. 📖 Check documentation completeness`n"
    prompt .= "7. 🔒 Security scan for vulnerabilities`n"
    prompt .= "8. 📊 Performance benchmarking`n`n"
    prompt .= "Execute complete packaging pipeline?"
    
    SendText prompt
}

; =============================================================================
; CREATIVE & PRODUCTIVITY TOOLS
; =============================================================================

; AI MCP Idea Generator (Ctrl+Shift+I)
^+i::
{
    LogOperation("MCP Idea Generation")
    
    context := InputBox("Development Context", "Enter current focus area (optional):", "w400 h130").value
    if (context == "") 
        context := "general MCP development"
    
    prompt := "💡 AI-Powered MCP Server Innovation Engine`n"
    prompt .= "========================================`n`n"
    prompt .= "Context: " . context . "`n`n"
    prompt .= "Analysis Framework:`n"
    prompt .= "🎯 Current Projects: Ednaficator, local-llm-mcp, fastsearch MCP, virtualbox MCP`n"
    prompt .= "🌍 Austrian/Vienna Context: Local services, ÖBB, city data, German language`n"
    prompt .= "🔧 Tech Stack: FastMCP 2.12+, Python 3.13, Claude Desktop, DXT packaging`n"
    prompt .= "👤 User Profile: Advanced dev, weeb, academic, budget-conscious, efficiency-focused`n`n"
    prompt .= "Generate 5 innovative MCP server concepts with:`n"
    prompt .= "- Unique value proposition`n"
    prompt .= "- Technical architecture overview`n"
    prompt .= "- Implementation complexity (1-10)`n"
    prompt .= "- Expected development time`n"
    prompt .= "- Integration opportunities`n"
    prompt .= "- Risk assessment`n`n"
    prompt .= "Prioritize by: Impact × Feasibility ÷ Time Investment"
    
    SendText prompt
}

; Documentation Generator (Ctrl+Shift+G)
^+g::
{
    LogOperation("Documentation Generation")
    
    docType := InputBox("Documentation Type", "Enter doc type (api|user|dev|troubleshooting|all):", "w400 h130").value
    if (docType == "") 
        docType := "all"
    
    prompt := "📚 AI Documentation Generation Suite`n"
    prompt .= "==================================`n`n"
    prompt .= "Documentation Type: " . docType . "`n`n"
    prompt .= "Generation Pipeline:`n`n"
    prompt .= "📖 README.md (Enhanced)`n"
    prompt .= "- Project overview with compelling description`n"
    prompt .= "- Feature highlights with examples`n"
    prompt .= "- Installation guide (multiple methods)`n"
    prompt .= "- Quick start tutorial`n"
    prompt .= "- Configuration examples`n"
    prompt .= "- Troubleshooting FAQ`n`n"
    prompt .= "🔧 API Documentation`n"
    prompt .= "- Auto-generated from docstrings`n"
    prompt .= "- Interactive examples`n"
    prompt .= "- Error codes and handling`n"
    prompt .= "- Type definitions`n`n"
    prompt .= "👥 User Guide`n"
    prompt .= "- Step-by-step tutorials`n"
    prompt .= "- Use case scenarios`n"
    prompt .= "- Best practices`n"
    prompt .= "- Performance tips`n`n"
    prompt .= "🛠️ Developer Documentation`n"
    prompt .= "- Architecture overview`n"
    prompt .= "- Extension guidelines`n"
    prompt .= "- Testing procedures`n"
    prompt .= "- Contribution guide`n`n"
    prompt .= "🔧 Troubleshooting Guide`n"
    prompt .= "- Common issues and solutions`n"
    prompt .= "- Log analysis instructions`n"
    prompt .= "- Performance debugging`n"
    prompt .= "- Recovery procedures`n`n"
    prompt .= "Generate comprehensive documentation suite with Austrian/Vienna context where relevant."
    
    SendText prompt
}

; Multi-MCP Orchestrator (Ctrl+Shift+O)
^+o::
{
    LogOperation("Multi-MCP Orchestration")
    
    prompt := "🎭 Multi-MCP Server Orchestration Center`n"
    prompt .= "======================================`n`n"
    prompt .= "Current MCP Ecosystem Analysis:`n"
    prompt .= "- Ednaficator (AI concierge)`n"
    prompt .= "- local-llm-mcp (local LLM integration)`n"
    prompt .= "- fastsearch-mcp (advanced search)`n"
    prompt .= "- virtualbox-mcp (VM management)`n"
    prompt .= "- All other configured MCPs`n`n"
    prompt .= "Orchestration Tasks:`n`n"
    prompt .= "🔍 Health Check All MCPs`n"
    prompt .= "- Connection status verification`n"
    prompt .= "- Resource usage analysis`n"
    prompt .= "- Performance metrics collection`n"
    prompt .= "- Error rate monitoring`n`n"
    prompt .= "⚙️ Configuration Optimization`n"
    prompt .= "- Identify conflicting configurations`n"
    prompt .= "- Optimize memory usage`n"
    prompt .= "- Load balancing recommendations`n"
    prompt .= "- Port conflict resolution`n`n"
    prompt .= "🚀 Standardization Initiative`n"
    prompt .= "- Update all to FastMCP 2.12+`n"
    prompt .= "- Standardize error handling patterns`n"
    prompt .= "- Unify logging formats`n"
    prompt .= "- Consistent configuration schemas`n`n"
    prompt .= "📊 Cross-MCP Analytics`n"
    prompt .= "- Usage pattern analysis`n"
    prompt .= "- Tool interaction mapping`n"
    prompt .= "- Performance bottleneck identification`n"
    prompt .= "- Optimization opportunities`n`n"
    prompt .= "Execute comprehensive MCP ecosystem analysis and optimization?"
    
    SendText prompt
}

; =============================================================================
; UTILITY & HELP FUNCTIONS
; =============================================================================

; Quick Help Display (Ctrl+Shift+H)
^+h::
{
    helpText := "
    (
    🚀 AutoHotkey MCP Development Scripts - Hotkey Reference
    ========================================================

    📁 Core Development:
    Ctrl+Shift+M - New MCP scaffolding with FastMCP 2.12+
    Ctrl+Shift+C - Standards conformance check & validation
    Ctrl+Shift+L - Advanced log analysis with AI insights

    🔧 Advanced Workflows:
    Ctrl+Shift+T - AI-powered smart troubleshooting
    Ctrl+Shift+D - Complete development lifecycle automation

    ⚙️ System Management:
    Ctrl+Alt+R - Intelligent Claude Desktop restart
    Ctrl+Alt+X - Emergency force restart (with cleanup)
    Ctrl+Shift+R - Hot config reload with validation

    📋 File & Project Operations:
    Ctrl+Shift+W - Advanced file monitoring system
    Ctrl+Shift+P - Enhanced DXT package validation

    💡 Creative & Productivity:
    Ctrl+Shift+I - AI MCP idea generator
    Ctrl+Shift+G - Comprehensive documentation generator
    Ctrl+Shift+O - Multi-MCP orchestration center

    ❓ Help & Status:
    Ctrl+Shift+H - Show this help
    Ctrl+Shift+S - Show current status
    Ctrl+F1 - Startup notification

    📝 All operations are logged to: C:\temp\ahk_operations.log
    🎯 Designed for FastMCP 2.12+ and Austrian development context
    )"
    
    MsgBox helpText, "MCP Development Scripts Help", 0
}

; Status Display (Ctrl+Shift+S)
^+s::
{
    ShowStatus()
}

; =============================================================================
; STARTUP & INITIALIZATION
; =============================================================================

; Startup Notification (Ctrl+F1)
^F1::
{
    TrayTip "AutoHotkey MCP Scripts Loaded", "🚀 Ready for Claude Desktop MCP development!`n`nPress Ctrl+Shift+H for hotkey help`nPress Ctrl+Shift+S for current status", 5
}

; =============================================================================
; AUTO-INITIALIZATION
; =============================================================================

; Ensure temp directory exists and log startup
if !DirExist(TEMP_DIR) {
    try {
        DirCreate TEMP_DIR
    } catch {
        ; Continue if can't create temp dir
    }
}

; Log script startup
LogOperation("AutoHotkey MCP Scripts Loaded - v2.0 SYNTAX FIXED")

; Show startup notification after brief delay
SetTimer ShowStartupNotification, -2000

; =============================================================================
; ERROR HANDLING & CLEANUP
; =============================================================================

OnExit ExitFunc

ExitFunc(ExitReason, ExitCode) {
    LogOperation("AutoHotkey MCP Scripts Exiting - Reason: " . ExitReason)
}