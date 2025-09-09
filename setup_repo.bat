@echo off
cd /d "D:\Dev\repos\autohotkey-test"
echo Initializing Git repository...
git init
echo.
echo Setting up Git configuration...
git config user.name "Sandra Schipal"
git config user.email "sandra@example.com"
echo.
echo Adding files to Git...
git add .
echo.
echo Creating initial commit...
git commit -m "Initial commit: AutoHotkey Development Tools

- Complete ScriptletCOMBridge v2 implementation
- 25+ development tools in scriptlet_launcher_v2.ahk  
- Web-based launcher interface
- Claude MCP integration scripts
- Proper repository structure with docs and examples"
echo.
echo Repository setup complete!
git status
echo.
echo Repository is now ready for GitHub!
echo Next steps:
echo 1. Create new repository on GitHub
echo 2. Run: git remote add origin https://github.com/sandraschi/autohotkey-dev-tools.git
echo 3. Run: git push -u origin main
pause
