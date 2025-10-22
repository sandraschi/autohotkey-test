# Contributing to AutoHotkey Scriptlets Collection

Thank you for your interest in contributing! This project provides a comprehensive collection of AutoHotkey v2 scriptlets, development tools, and automation utilities.

## 🚨 **SECURITY FIRST** 🚨

**Before contributing, please read our security guidelines:**
- Review `SECURITY_WARNING.md` for critical safety information
- Understand that AutoHotkey can do ANYTHING on a computer
- Never submit scripts that could be dangerous or malicious
- Always include appropriate error handling and safety checks

## 🎯 What We're Looking For

### 🛠️ **Scriptlets**
- **Productivity Tools**: Clipboard managers, window management, text processing
- **Development Tools**: Code formatters, Git assistants, debugging utilities
- **Entertainment**: Games, media controllers, fun utilities
- **Security Tools**: Safe automation, monitoring, validation tools

### 🔧 **Core Improvements**
- **Bug fixes** for existing scriptlets
- **Performance optimizations**
- **AutoHotkey v2 compatibility** enhancements
- **Documentation improvements**
- **Testing and validation** tools

### 📚 **Documentation**
- **Help system** improvements
- **Security guides** and best practices
- **Migration guides** for v1→v2
- **API documentation** for the COM bridge

## 🛠️ Development Setup

### Prerequisites
1. **AutoHotkey v2.0+** from [autohotkey.com](https://autohotkey.com)
2. **Windows 10/11** (required for AutoHotkey)
3. **Modern web browser** (for testing web interface)
4. **PowerShell** (for COM bridge server)

### Setup Steps
1. **Fork and clone** the repository
2. **Start the bridge**: Run `ScriptletCOMBridge.ahk`
3. **Test web interface**: Open `launcher_enhanced.html`
4. **Run tests**: Use `scriptlet_tester.ahk` to validate syntax
5. **Check debugging**: Use `autohotkey_debug_helper.ahk` for error tracking

## 📝 Coding Standards

### AutoHotkey v2 Guidelines
- **Use AutoHotkey v2 syntax** (not v1.1) - see migration guide
- **Include `#Requires AutoHotkey v2.0+`** at the top of scripts
- **Use proper error handling** with `try/catch` blocks
- **Follow camelCase** for variables and functions
- **Add descriptive comments** for complex logic
- **Test with scriptlet_tester.ahk** before submitting

### Required Syntax Patterns
```autohotkey
#Requires AutoHotkey v2.0+

; String concatenation (v2)
text := "Hello" . "World"
result := "Value: " . variable

; Function calls (v2)
FileRead(content, filename)
FileAppend(text, filename)
MsgBox("Message")

; Exception handling (v2)
try {
    ; risky code
} catch as e {
    MsgBox("Error: " . e.Message)
}

; Global variables (v2)
myVar := ""
anotherVar := ""
```

### File Organization
- **Main scripts** in root directory
- **Scriptlets** in `scriptlets/` folder
- **Utilities** in `utils/` folder
- **Tests** in `tests/` folder
- **Documentation** in `docs/` folder
- **Legacy v1** scripts in `scriptlets/v1/`

## 🚀 Submitting Changes

### 1. Create Feature Branch
```bash
git checkout -b feature/new-scriptlet
# or
git checkout -b fix/bug-description
```

### 2. Development Process
1. **Make your changes** following coding standards
2. **Test thoroughly** with `scriptlet_tester.ahk`
3. **Check syntax** with debug helpers
4. **Update documentation** if needed
5. **Test via web interface** to ensure compatibility

### 3. Commit Guidelines
```bash
# Use descriptive commit messages
git commit -m "feat(scriptlets): add XML formatter utility

- Added XMLFormatter scriptlet with pretty-printing
- Includes validation and error handling
- Tested with scriptlet_tester.ahk
- Updated metadata.json

Closes #42"
```

### 4. Pull Request Process
1. **Push to your fork**
2. **Create Pull Request** with detailed description
3. **Include testing information**
4. **Reference any related issues**

## 🐛 Reporting Issues

### Bug Reports Should Include:
- **AutoHotkey version** (must be v2.0+)
- **Windows version** (10/11)
- **Steps to reproduce** the issue
- **Expected vs actual behavior**
- **Error messages** from debug helpers
- **Screenshots** if applicable

### Security Issues
- **Report security issues privately** via email
- **Do not create public issues** for security vulnerabilities
- **Include detailed reproduction steps**
- **Describe potential impact**

## 💡 Feature Requests

### For New Scriptlets:
- **Describe the use case** and target audience
- **Explain expected behavior** and features
- **Consider security implications**
- **Provide implementation ideas** if possible
- **Check if similar functionality exists**

### For Core Improvements:
- **Describe the problem** being solved
- **Explain the proposed solution**
- **Consider backward compatibility**
- **Include performance implications**

## 🧪 Testing Requirements

### Before Submitting:
1. **Syntax Check**: Use `scriptlet_tester.ahk`
2. **Error Testing**: Use `autohotkey_debug_helper.ahk`
3. **Web Interface**: Test via `launcher_enhanced.html`
4. **Manual Testing**: Verify all functionality works
5. **Security Review**: Ensure no dangerous operations

### Test Checklist:
- [ ] Script runs without syntax errors
- [ ] All functions work as expected
- [ ] Error handling is robust
- [ ] No security vulnerabilities
- [ ] Documentation is updated
- [ ] Web interface compatibility

## 🏷️ Commit Message Format

```
type(scope): description

[optional body with details]

[optional footer with references]
```

### Types:
- `feat`: New feature or scriptlet
- `fix`: Bug fix
- `docs`: Documentation changes
- `refactor`: Code refactoring
- `test`: Adding tests
- `chore`: Maintenance tasks
- `security`: Security-related changes

### Examples:
```
feat(scriptlets): add XML formatter utility

Added new XMLFormatter scriptlet with pretty-printing
and validation capabilities for XML data processing.

Closes #42
```

```
fix(web-ui): resolve theme toggle issue

Fixed CSS variable application for proper theme switching.
Updated JavaScript to handle theme persistence correctly.

Fixes #38
```

## 🔒 Security Guidelines

### Safe Practices:
- **Never access sensitive files** without user consent
- **Always validate user input** before processing
- **Use appropriate error handling** to prevent crashes
- **Include confirmation dialogs** for destructive operations
- **Document security implications** in code comments

### Dangerous Operations to Avoid:
- **File system access** without user permission
- **Network operations** without user consent
- **System registry modifications** without warnings
- **Process termination** without confirmation
- **Administrative operations** without proper checks

## 📄 License

By contributing, you agree that your contributions will be licensed under the MIT License. See `LICENSE` file for details.

## 🤝 Community Guidelines

- **Be respectful** and constructive in discussions
- **Help others** learn AutoHotkey v2 syntax
- **Share knowledge** about security best practices
- **Follow the project's vision** of safe, useful automation
- **Report issues** promptly and clearly

## 📞 Getting Help

- **Check documentation** in `docs/` folder
- **Use help system**: Run `scriptlets/help_system_pro.ahk`
- **Review examples** in existing scriptlets
- **Ask questions** in GitHub discussions
- **Reference migration guide** for v2 syntax help
