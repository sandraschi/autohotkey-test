# AutoHotkey Scriptlets Collection & Development Tools

A comprehensive collection of AutoHotkey v2 scriptlets, development tools, and automation utilities featuring a modern web-based GUI, COM bridge system, and extensive debugging capabilities.

## 🚨 **SECURITY WARNING** 🚨

**AutoHotkey can do ANYTHING on your computer!** This includes:
- Accessing all files and folders
- Controlling other applications  
- Sending keystrokes and mouse clicks
- Running commands as administrator
- **Starting banking apps and transferring money**

**⚠️ CRITICAL SAFETY RULES:**
- Never run untrusted AutoHotkey scripts
- Review all scripts before running
- Be especially careful with AI-generated scripts
- AutoHotkey CANNOT read browser DOM content
- Keep backups of important data

See `SECURITY_WARNING.md` and `scriptlets/security_guide_pro.ahk` for complete safety information.

## 🚀 Features

### Core Components

- **ScriptletCOMBridge**: Advanced HTTP bridge for web-based scriptlet management
- **Enhanced Web GUI**: Modern HTML5 interface with theme switching and real-time updates
- **Comprehensive Scriptlets**: 54+ professional-grade utilities and tools
- **Advanced Linting System**: Complete AutoHotkey v2 static analysis and error fixing
- **Debugging Tools**: Built-in error tracking and syntax checking
- **Security System**: Comprehensive warnings and safety guides
- **AutoHotkey v2 Migration**: Complete v1→v2 syntax conversion with migration guide

### Key Scripts

- `ScriptletCOMBridge.ahk` - Core HTTP bridge for web interface
- `launcher_enhanced.html` - Modern web-based scriptlet launcher
- `scriptlet_launcher_v2.ahk` - Native GUI launcher
- `claude-mcp-scripts-extended.ahk` - Claude Desktop MCP integration
- `scriptlets/help_system_pro.ahk` - Interactive help system
- `scriptlets/security_guide_pro.ahk` - Security education tool

### Linting & Development Tools

- `utils/linter.ahk` - Complete AutoHotkey v2 static analyzer
- `utils/run_linter_clean.ps1` - Clean linter runner with process management
- `utils/batch_analyze_all.ps1` - Comprehensive batch analysis tool
- `utils/fix_autohotkey_errors.ps1` - Automated error fixing script
- `utils/scriptlet_validator.ahk` - Advanced validation framework

## 🌐 Enhanced Web Interface

The `launcher_enhanced.html` provides a modern web interface with:

- **🎨 Theme System**: Light/dark mode with CSS variables
- **🔍 Search & Filter**: Find scriptlets quickly
- **⌨️ Command Palette**: Power user keyboard shortcuts
- **📊 Live Statistics**: Real-time system monitoring
- **🚀 One-Click Execution**: Run/stop scriptlets from web interface
- **❓ Help System**: Built-in help button and guides
- **📱 Responsive Design**: Works on all screen sizes

### Web Interface Features

- Dynamic scriptlet loading from `/scriptlets` endpoint
- Real-time run/stop status indicators
- Help modal with quick access to guides
- Theme toggle with persistent preferences
- Error handling and user feedback

## 🔧 ScriptletCOMBridge

The `ScriptletCOMBridge` enables web-based scriptlet management:

- **HTTP Server**: PowerShell-based server on port 8765
- **REST API**: `/run/`, `/stop/`, `/status`, `/scriptlets` endpoints
- **Dynamic Discovery**: Automatically finds all `.ahk` files in scriptlets directory
- **Error Handling**: Robust error reporting and recovery
- **Batch Integration**: Uses `RunScriptlet.bat` and `StopScriptlet.bat`

### API Endpoints

- `GET /scriptlets` - List all available scriptlets
- `GET /run/{scriptlet}` - Start a scriptlet
- `GET /stop/{scriptlet}` - Stop a scriptlet  
- `GET /status` - Server status

## 📁 Repository Structure

```
autohotkey-test/
├── docs/                           # Documentation
│   ├── AutoHotkey_v2_Syntax_Migration_Guide.md
│   ├── Repository_Status_Report.md
│   └── Improvement_Plan.md
├── scriptlets/                     # AutoHotkey v2 scriptlets
│   ├── help_system_pro.ahk         # Interactive help
│   ├── security_guide_pro.ahk     # Security education
│   ├── autohotkey_debug_helper.ahk # Debugging tools
│   ├── scriptlet_tester.ahk       # Syntax testing
│   ├── mini_games_collection.ahk  # Games (Snake, Tetris, etc.)
│   ├── smart_clipboard_manager.ahk # Advanced clipboard
│   ├── window_manager_pro.ahk     # Window management
│   ├── code_formatter_pro.ahk     # Code formatting
│   ├── git_assistant_pro.ahk      # Git automation
│   ├── music_controller_pro.ahk   # Media control
│   ├── smart_assistant_pro.ahk    # AI assistant
│   ├── workflow_automator_pro.ahk # Workflow automation
│   └── v1/                        # Legacy v1 scriptlets
├── utils/                          # Utility classes
│   ├── ConfigManager.ahk          # Configuration management
│   ├── PluginManager.ahk          # Plugin system
│   └── TestFramework.ahk          # Testing framework
├── tests/                          # Unit tests
├── launcher_enhanced.html         # Enhanced web interface
├── ScriptletCOMBridge.ahk         # Core bridge
├── RunScriptlet.bat               # Script execution helper
├── StopScriptlet.bat              # Script termination helper
└── README_COMPREHENSIVE.md        # Detailed documentation
```

## 🛠️ Requirements

- **AutoHotkey v2.0+** (Required)
- **Windows 10/11** (Required)
- **Modern Web Browser** (For web interface)
- **PowerShell** (For COM bridge server)

## 🎯 Quick Start

### 1. Web Interface (Recommended)

1. **Start the Bridge**: Run `ScriptletCOMBridge.ahk`
2. **Open Web Interface**: Open `launcher_enhanced.html` in your browser
3. **Run Scriptlets**: Click any scriptlet card to run it
4. **Get Help**: Press `F1` or click the Help button

### 2. Native GUI

1. **Run Launcher**: Execute `scriptlet_launcher_v2.ahk`
2. **Browse Categories**: Use Utilities, Development, Fun, Games tabs
3. **Launch Scriptlets**: Click any scriptlet to run it

### 3. Command Line

```powershell
# Start the bridge
AutoHotkey64.exe ScriptletCOMBridge.ahk

# Test a scriptlet
curl http://localhost:8765/run/system_monitor.ahk

# List all scriptlets
curl http://localhost:8765/scriptlets
```

## 🔧 Development Tools

### Advanced Linting System
- **Static Analyzer**: Complete AutoHotkey v2 syntax checking
- **Error Detection**: Identifies compatibility issues and syntax errors
- **Automated Fixing**: Batch fixes for common v1→v2 migration issues
- **Process Management**: Clean execution with automatic process cleanup
- **Comprehensive Reports**: Detailed analysis with line-by-line error reporting

### Debugging & Testing
- **Debug Helper**: `Ctrl+Alt+D` - View error logs
- **Scriptlet Tester**: `Ctrl+Alt+T` - Test all scriptlets
- **Syntax Checker**: `Ctrl+Alt+F` - Quick fix guide
- **Batch Analysis**: Comprehensive analysis of all scriptlets
- **Validation Framework**: Advanced testing and validation

### Configuration Management
- **ConfigManager**: JSON-based configuration with INI migration
- **PluginManager**: Dynamic scriptlet discovery and loading
- **TestFramework**: Professional testing framework

### Security & Help
- **Security Guide**: Interactive security education
- **Help System**: Comprehensive help and documentation
- **Warning System**: On-demand security warnings

## 📝 Scriptlet Categories

### 🛠️ **Productivity Tools**
- Smart Clipboard Manager - Advanced clipboard with history
- Window Manager Pro - Advanced window management
- Text Transformer Pro - Text manipulation utilities
- Workflow Automator Pro - Custom automation workflows

### 💻 **Development Tools**  
- Code Formatter Pro - Multi-language code formatting
- Git Assistant Pro - Git workflow automation
- Debug Helper - Error tracking and logging
- Scriptlet Tester - Syntax validation

### 🎮 **Entertainment**
- Mini Games Collection - Snake, Tetris, Memory, Minesweeper
- Music Controller Pro - Advanced media control
- Smart Assistant Pro - AI-powered assistant

### 🔒 **Security & Help**
- Security Guide Pro - Interactive security education
- Help System Pro - Comprehensive help documentation
- AutoHotkey Warning - Security warnings and alerts

## 🚀 Advanced Features

### AutoHotkey v2 Migration
- **Complete v1→v2 conversion** with syntax fixes
- **Migration guide** with common patterns and fixes
- **Systematic testing** to prevent future syntax errors
- **Debug helpers** for error visibility

### Web Interface Enhancements
- **Dynamic scriptlet loading** from server
- **Real-time status updates** for running scriptlets
- **Theme system** with CSS variables
- **Help integration** with quick access to guides

### Security Implementation
- **Comprehensive warnings** about AutoHotkey capabilities
- **Interactive security guide** with best practices
- **AI safety warnings** for generated scripts
- **Limitation documentation** (e.g., no browser DOM access)

## 🤝 Contributing

### Development Guidelines
- Use AutoHotkey v2.0+ syntax
- Follow the syntax migration guide
- Test with the scriptlet tester
- Include proper error handling
- Add security considerations

### Adding New Scriptlets
1. Create `.ahk` file in `scriptlets/` directory
2. Use proper v2 syntax (see migration guide)
3. Test with `scriptlet_tester.ahk`
4. Update `metadata.json` if needed
5. Test via web interface

## 📄 Documentation

- **README_COMPREHENSIVE.md** - Detailed documentation
- **QUICK_START_GUIDE.md** - Quick start instructions
- **SECURITY_WARNING.md** - Critical security information
- **CHANGELOG.md** - Complete version history
- **docs/DEVELOPMENT_GUIDE.md** - Development practices and tools
- **docs/AutoHotkey_v2_Syntax_Migration_Guide.md** - Migration reference
- **docs/AutoHotkey_Debugging_Guide.md** - Debugging techniques
- **docs/linting_success_report.md** - Linting system documentation
- **scriptlets/help_system_pro.ahk** - Interactive help

## 📊 Recent Updates

### v2.1.0 - Advanced Linting & Error Fixing System
- ✅ **Complete Linting Infrastructure**: Full AutoHotkey v2 static analysis
- ✅ **Automated Error Fixing**: Fixed 31 critical errors across 45 scriptlets
- ✅ **Process Management**: Clean execution with automatic process cleanup
- ✅ **Comprehensive Analysis**: Batch analysis of all 54 scriptlets
- ✅ **Error Documentation**: Complete documentation of all fixes applied
- ✅ **Development Tools**: Professional-grade linting and validation tools

### v2.0.0 - Major Migration & Enhancement
- ✅ Complete AutoHotkey v1→v2 migration
- ✅ Enhanced web interface with theme system
- ✅ Comprehensive debugging tools
- ✅ Security documentation and warnings
- ✅ Dynamic scriptlet loading
- ✅ Professional scriptlet collection
- ✅ Testing framework and validation

## 🏷️ Tags

`autohotkey` `automation` `windows` `development-tools` `web-interface` `scriptlets` `v2-migration` `debugging` `security` `utilities`
