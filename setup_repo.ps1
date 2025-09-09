# PowerShell script to initialize Git repository
Set-Location "D:\Dev\repos\autohotkey-test"

Write-Host "Initializing Git repository..." -ForegroundColor Green
git init 2>&1 | Write-Host

Write-Host "`nSetting up Git configuration..." -ForegroundColor Green  
git config user.name "Sandra Schipal" 2>&1 | Write-Host
git config user.email "sandra@example.com" 2>&1 | Write-Host

Write-Host "`nAdding files to Git..." -ForegroundColor Green
git add . 2>&1 | Write-Host

Write-Host "`nCreating initial commit..." -ForegroundColor Green
$commitMessage = @"
Initial commit: AutoHotkey Development Tools

- Complete ScriptletCOMBridge v2 implementation
- 25+ development tools in scriptlet_launcher_v2.ahk  
- Web-based launcher interface
- Claude MCP integration scripts
- Proper repository structure with docs and examples
"@

git commit -m $commitMessage 2>&1 | Write-Host

Write-Host "`nRepository setup complete!" -ForegroundColor Green
git status 2>&1 | Write-Host

Write-Host "`nRepository is now ready for GitHub!" -ForegroundColor Cyan
Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "1. Create new repository on GitHub" -ForegroundColor White
Write-Host "2. Run: git remote add origin https://github.com/sandraschi/autohotkey-dev-tools.git" -ForegroundColor White  
Write-Host "3. Run: git push -u origin main" -ForegroundColor White
