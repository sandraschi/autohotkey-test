# AutoHotkey Development Tools & Scripts

A comprehensive collection of AutoHotkey v2 scripts and development tools for system automation, COM bridging, and scriptlet management, featuring a powerful bridge script and modern HTML-based GUI.

## 🚀 Features

### Core Components

- **ScriptletCOMBridge**: Advanced COM bridge for AutoHotkey v2 with JSON utilities
- **HTML5 GUI**: Modern web-based interface for script management
- **Development Tools**: Collection of utilities for AutoHotkey development
- **Claude MCP Integration**: Scripts designed to work with Claude MCP tools

### Key Scripts

- `scriptlet_launcher_v2.ahk` - Main launcher with 25+ development tools
- `ScriptletCOMBridge_v2.ahk` - Core COM bridge implementation
- `claude-mcp-scripts-extended.ahk` - Enhanced Claude Desktop integration
- `launcher.html` - Web-based interface for script management

## 🔧 ScriptletCOMBridge

The `ScriptletCOMBridge` is a powerful COM bridge that enables:

- **Bidirectional Communication**: Seamless interaction between AutoHotkey and other applications
- **JSON Serialization**: Built-in utilities for JSON data handling
- **Modular Design**: Split into multiple files for better maintainability
- **Error Handling**: Robust error reporting and recovery

### Key Bridge Scripts

- `ScriptletCOMBridge_v2.ahk` - Main bridge implementation
- `ScriptletCOMBridge_v2_part*.ahk` - Modular components (1-5)
- `ScriptletCOMBridge_v2_final.ahk` - Final compiled version

## 🌐 HTML5 GUI

The `launcher.html` provides a modern web interface with:

- **Responsive Design**: Works on desktop and mobile devices
- **Real-time Updates**: Dynamic content updates without page reloads
- **Dark/Light Mode**: Automatic theme switching based on system preferences
- **Keyboard Navigation**: Full keyboard support for power users

### Features

- Script categorization and search
- One-click script execution
- Status monitoring
- Configuration management

## 📁 Structure

```
autohotkey-test/
├── docs/           # Documentation and guides
├── scriptlets/     # Individual script modules
├── utils/          # Utility functions and helpers
├── notes/          # Development notes and planning
├── .snapshots/     # Version snapshots
└── *.ahk          # Main script files
```

## 🛠️ Requirements

- AutoHotkey v2.0+
- Windows 10/11
- Optional: Claude Desktop for MCP integration

## 🎯 Quick Start

### Using the Bridge Script

1. Ensure AutoHotkey v2.0+ is installed
2. Run `ScriptletCOMBridge_v2.ahk` to start the bridge
3. The bridge will be available for other applications to connect

### Using the Web GUI

1. Start the bridge script as above
2. Open `launcher.html` in any modern web browser
3. The interface will automatically connect to the running bridge

### Command Line Usage

```bash
# Start the bridge
AutoHotkey64.exe ScriptletCOMBridge_v2.ahk

# Launch with custom port
AutoHotkey64.exe ScriptletCOMBridge_v2.ahk --port 8080
```

## 🔧 Development Tools Included

### JSON & Data Processing (1-4)
- JsonFormatter: Pretty-print JSON
- JsonValidator: Validate JSON syntax
- JsonMinifier: Compress JSON
- JsonToIni: Convert JSON to INI format

### Development Utilities (5-16)
- RegexTester: Test regex patterns
- Base64Encoder: Encode/decode Base64
- HashCalculator: Calculate file hashes
- ProcessMonitor: Monitor running processes
- NetworkPing: Network connectivity testing
- And more...

### Advanced Tools (17-25)
- HttpStatusChecker: Check URL status codes
- SystemInfoCollector: Gather system information
- FileBackupManager: Automated file backups
- DirectoryTreeGenerator: Generate directory structures
- And more development utilities

## 📝 Usage Examples

### Basic Scriptlet Launch
```autohotkey
; Load and run a scriptlet
launcher := new ScriptletLauncher()
launcher.RunScriptlet("JsonFormatter", inputData)
```

### COM Bridge Usage
```autohotkey
; Initialize COM bridge
bridge := new ScriptletCOMBridge()
result := bridge.ProcessJson(jsonString)
```

## 🤝 Contributing

This is a development repository for AutoHotkey tools and scripts. Feel free to:
- Report issues
- Suggest improvements
- Submit pull requests
- Add new scriptlets

## 📄 License

MIT License - see LICENSE file for details

## 🏷️ Tags

`autohotkey` `automation` `windows` `development-tools` `com-bridge` `json` `utilities` `scriptlets`
