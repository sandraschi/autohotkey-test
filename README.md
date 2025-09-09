# AutoHotkey Development Tools & Scripts

A comprehensive collection of AutoHotkey v2 scripts and development tools for system automation, COM bridging, and scriptlet management.

## 🚀 Features

### Core Components
- **ScriptletCOMBridge**: Advanced COM bridge for AutoHotkey v2 with JSON utilities
- **Scriptlet Launcher**: Dynamic script launcher with web-based GUI
- **Development Tools**: Collection of utilities for AutoHotkey development
- **Claude MCP Integration**: Scripts designed to work with Claude MCP tools

### Key Scripts
- `scriptlet_launcher_v2.ahk` - Main launcher with 25+ development tools
- `ScriptletCOMBridge_v2*.ahk` - COM bridge implementation (modular parts)
- `claude-mcp-scripts.ahk` - Claude Desktop integration utilities
- `launcher.html` - Web-based interface for script management

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

1. Install AutoHotkey v2.0+ from [autohotkey.com](https://autohotkey.com)
2. Clone or download this repository
3. Run `scriptlet_launcher_v2.ahk` for the main toolset
4. Use `launcher.html` for web-based management

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
