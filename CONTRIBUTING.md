# Contributing to AutoHotkey Development Tools

Thank you for your interest in contributing! This project aims to provide useful AutoHotkey v2 development tools and utilities.

## 🎯 What We're Looking For

- **Bug fixes** for existing scripts
- **New scriptlets** and development tools
- **Documentation improvements**
- **Performance optimizations**
- **AutoHotkey v2 compatibility** enhancements

## 🛠️ Development Setup

1. Install AutoHotkey v2.0+ from [autohotkey.com](https://autohotkey.com)
2. Fork and clone the repository
3. Test your changes with `scriptlet_launcher_v2.ahk`
4. Ensure compatibility with Windows 10/11

## 📝 Coding Standards

### AutoHotkey v2 Guidelines
- Use AutoHotkey v2 syntax (not v1.1)
- Include `#Requires AutoHotkey v2.0` at the top of scripts
- Use proper error handling with `try/catch`
- Follow camelCase for variables and functions
- Add descriptive comments for complex logic

### File Organization
- Main scripts in root directory
- Utilities in `utils/` folder
- Individual scriptlets in `scriptlets/`
- Documentation in `docs/`

## 🚀 Submitting Changes

1. Create a feature branch: `git checkout -b feature/new-scriptlet`
2. Make your changes and test thoroughly
3. Update documentation if needed
4. Commit with clear, descriptive messages
5. Push to your fork and create a Pull Request

## 🐛 Reporting Issues

When reporting bugs, please include:
- AutoHotkey version
- Windows version
- Steps to reproduce
- Expected vs actual behavior
- Relevant error messages or logs

## 💡 Feature Requests

For new features:
- Describe the use case
- Explain the expected behavior
- Consider if it fits the project's scope
- Provide implementation ideas if possible

## 🏷️ Commit Message Format

```
type(scope): description

[optional body]

[optional footer]
```

Types:
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `refactor`: Code refactoring
- `test`: Adding tests
- `chore`: Maintenance tasks

Example:
```
feat(scriptlets): add XML formatter utility

Added new XMLFormatter scriptlet with pretty-printing
and validation capabilities for XML data processing.

Closes #42
```

## 📄 License

By contributing, you agree that your contributions will be licensed under the MIT License.
