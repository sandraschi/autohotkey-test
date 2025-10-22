; =============================================================================
; ENHANCED FILESYSTEM & PROJECT MONITORING
; =============================================================================

; 8. Advanced File Watcher with AI Analysis (Ctrl+Shift+W)
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
    prompt .= "• Performance Issues → Resource analysis`n"
    prompt .= "• Dependency Updates → Compatibility check`n`n"
    prompt .= "AI Features:`n"
    prompt .= "- Pattern recognition for common issues`n"
    prompt .= "- Predictive problem detection`n"
    prompt .= "- Auto-fix suggestions for simple issues`n"
    prompt .= "- Performance optimization recommendations`n`n"
    prompt .= "Start comprehensive monitoring with AI analysis?"
    
    SendText prompt
}

; 9. Enhanced DXT Package Management (Ctrl+Shift+P)
^+p::
{
    LogOperation("DXT Package Validation")
    
    ; Get current project
    InputBox &projectDir, "Project Directory", "Enter project directory name:", , 350, 130
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
    prompt .= "Package Generation:`n"
    prompt .= "- Create optimized DXT package`n"
    prompt .= "- Generate installation instructions`n"
    prompt .= "- Create GitHub release with assets`n"
    prompt .= "- Update package registry metadata`n`n"
    prompt .= "Post-packaging:`n"
    prompt .= "- Automated testing in Claude Desktop`n"
    prompt .= "- Documentation deployment`n"
    prompt .= "- Version tagging and changelog`n`n"
    prompt .= "Execute complete packaging pipeline?"
    
    SendText prompt
}

; =============================================================================
; CREATIVE & PRODUCTIVITY ENHANCEMENTS
; =============================================================================

; 10. AI-Powered MCP Idea Generator (Ctrl+Shift+I)
^+i::
{
    LogOperation("MCP Idea Generation")
    
    ; Get context for better ideas
    InputBox &context, "Development Context", "Enter current focus area (optional):", , 400, 130
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
    prompt .= "Innovation Vectors:`n"
    prompt .= "1. Daily Workflow Automation`n"
    prompt .= "2. Local Service Integration`n"
    prompt .= "3. Development Tool Enhancement`n"
    prompt .= "4. Data Analysis & Visualization`n"
    prompt .= "5. Creative Content Generation`n`n"
    prompt .= "Generate 5 innovative MCP server concepts with:`n"
    prompt .= "- Unique value proposition`n"
    prompt .= "- Technical architecture overview`n"
    prompt .= "- Implementation complexity (1-10)`n"
    prompt .= "- Expected development time`n"
    prompt .= "- Integration opportunities`n"
    prompt .= "- Market differentiation`n"
    prompt .= "- Risk assessment`n`n"
    prompt .= "Prioritize by: Impact × Feasibility ÷ Time Investment"
    
    SendText prompt
}

; 11. Comprehensive Documentation Generator (Ctrl+Shift+G)
^+g::
{
    LogOperation("Documentation Generation")
    
    InputBox &docType, "Documentation Type", "Enter doc type (api|user|dev|troubleshooting|all):", , 400, 130
    if (docType == "")
        docType := "all"
    
    prompt := "📚 AI Documentation Generation Suite`n"
    prompt .= "==================================`n`n"
    prompt .= "Documentation Type: " . docType . "`n`n"
    prompt .= "Generation Pipeline:`n`n"
    prompt .= "📖 README.md (Enhanced)`n"
    prompt .= "- Project overview with compelling description`n"
    prompt .= "- Feature highlights with screenshots`n"
    prompt .= "- Installation guide (multiple methods)`n"
    prompt .= "- Quick start tutorial`n"
    prompt .= "- Configuration examples`n"
    prompt .= "- Troubleshooting FAQ`n`n"
    prompt .= "🔧 API Documentation`n"
    prompt .= "- Auto-generated from docstrings`n"
    prompt .= "- Interactive examples`n"
    prompt .= "- Error codes and handling`n"
    prompt .= "- Performance characteristics`n`n"
    prompt .= "👥 User Guide`n"
    prompt .= "- Step-by-step workflows`n"
    prompt .= "- Best practices`n"
    prompt .= "- Common use cases`n"
    prompt .= "- Integration patterns`n`n"
    prompt .= "🛠️ Developer Guide`n"
    prompt .= "- Architecture overview`n"
    prompt .= "- Code contribution guidelines`n"
    prompt .= "- Testing procedures`n"
    prompt .= "- Release process`n`n"
    prompt .= "🚨 Troubleshooting Guide`n"
    prompt .= "- Common issues and solutions`n"
    prompt .= "- Debug procedures`n"
    prompt .= "- Log analysis tips`n"
    prompt .= "- Performance optimization`n`n"
    prompt .= "Generate comprehensive documentation suite with consistent styling and navigation."
    
    SendText prompt
}