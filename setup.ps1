#Requires -RunAsAdministrator
<#
.SYNOPSIS
    Dev environment setup script for Declan's Windows laptop.

.DESCRIPTION
    Installs and configures everything needed for React/Node/AWS/Python development.
    Run this once on a fresh machine. Re-running is safe — tools already installed are skipped.

.NOTES
    Must be run as Administrator.
    After this script completes, follow the manual steps in:
    - 03-git-github.md  (SSH keys)
    - 04-aws.md         (AWS CLI profiles)
#>

$ErrorActionPreference = "Stop"

# ─── Helper Functions ─────────────────────────────────────────────────────────

function Write-Step($msg) {
    Write-Host "`n==> $msg" -ForegroundColor Cyan
}

function Write-OK($msg) {
    Write-Host "    [OK] $msg" -ForegroundColor Green
}

function Write-Skip($msg) {
    Write-Host "    [SKIP] $msg (already installed)" -ForegroundColor Yellow
}

function Test-Command($cmd) {
    return [bool](Get-Command $cmd -ErrorAction SilentlyContinue)
}

# ─── Step 1: Chocolatey ───────────────────────────────────────────────────────

Write-Step "Chocolatey (package manager)"

if (Test-Command "choco") {
    Write-Skip "choco"
} else {
    Set-ExecutionPolicy Bypass -Scope Process -Force
    [System.Net.ServicePointManager]::SecurityProtocol = `
        [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
    Invoke-Expression ((New-Object System.Net.WebClient).DownloadString(
        'https://community.chocolatey.org/install.ps1'
    ))
    # Reload PATH so choco is available
    $env:PATH = [System.Environment]::GetEnvironmentVariable("PATH", "Machine") + ";" +
                [System.Environment]::GetEnvironmentVariable("PATH", "User")
    Write-OK "Chocolatey installed"
}

# ─── Step 2: Git ──────────────────────────────────────────────────────────────

Write-Step "Git"

if (Test-Command "git") {
    $v = git --version
    Write-Skip "git ($v)"
} else {
    choco install git -y
    Write-OK "Git installed"
}

# ─── Step 3: Node.js LTS (22.x) ───────────────────────────────────────────────

Write-Step "Node.js LTS (22.x)"

if (Test-Command "node") {
    $v = node --version
    Write-Skip "node ($v)"
} else {
    choco install nodejs-lts -y
    Write-OK "Node.js installed"
}

# ─── Step 4: Python ───────────────────────────────────────────────────────────

Write-Step "Python 3"

if (Test-Command "python") {
    $v = python --version
    Write-Skip "python ($v)"
} else {
    choco install python -y
    Write-OK "Python installed"
}

# ─── Step 5: AWS CLI v2 ───────────────────────────────────────────────────────

Write-Step "AWS CLI v2"

if (Test-Command "aws") {
    $v = aws --version
    Write-Skip "aws ($v)"
} else {
    choco install awscli -y
    Write-OK "AWS CLI installed"
}

# ─── Step 6: Visual Studio Code ───────────────────────────────────────────────

Write-Step "Visual Studio Code"

if (Test-Command "code") {
    $v = code --version | Select-Object -First 1
    Write-Skip "vscode ($v)"
} else {
    choco install vscode -y
    # Reload PATH
    $env:PATH = [System.Environment]::GetEnvironmentVariable("PATH", "Machine") + ";" +
                [System.Environment]::GetEnvironmentVariable("PATH", "User")
    Write-OK "VS Code installed"
}

# ─── Step 7: VS Code Extensions ───────────────────────────────────────────────

Write-Step "VS Code Extensions"

$extensions = @(
    "esbenp.prettier-vscode",
    "dbaeumer.vscode-eslint",
    "dsznajder.es7-react-js-snippets",
    "bradlc.vscode-tailwindcss",
    "amazonwebservices.aws-toolkit-vscode",
    "redhat.vscode-yaml",
    "eamodio.gitlens",
    "mhutchie.git-graph",
    "anthropic.claude-code",
    "christian-kohler.path-intellisense",
    "formulahendry.auto-rename-tag",
    "PKief.material-icon-theme"
)

foreach ($ext in $extensions) {
    code --install-extension $ext --force 2>&1 | Out-Null
    Write-OK $ext
}

# ─── Step 8: Claude Code ──────────────────────────────────────────────────────

Write-Step "Claude Code (npm global)"

# Reload PATH to pick up npm from Node install
$env:PATH = [System.Environment]::GetEnvironmentVariable("PATH", "Machine") + ";" +
            [System.Environment]::GetEnvironmentVariable("PATH", "User")

if (Test-Command "claude") {
    Write-Skip "claude"
} else {
    npm install -g @anthropic-ai/claude-code
    Write-OK "Claude Code installed"
}

# ─── Step 9: VS Code Settings ─────────────────────────────────────────────────

Write-Step "VS Code user settings"

$vsCodeSettingsDir = "$env:APPDATA\Code\User"
$vsCodeSettingsFile = "$vsCodeSettingsDir\settings.json"

if (-not (Test-Path $vsCodeSettingsDir)) {
    New-Item -ItemType Directory -Path $vsCodeSettingsDir -Force | Out-Null
}

$settings = @{
    "editor.fontSize" = 14
    "editor.tabSize" = 2
    "editor.formatOnSave" = $true
    "editor.defaultFormatter" = "esbenp.prettier-vscode"
    "editor.wordWrap" = "on"
    "editor.minimap.enabled" = $false
    "terminal.integrated.defaultProfile.windows" = "Git Bash"
    "terminal.integrated.fontSize" = 13
    "files.eol" = "`n"
    "files.trimTrailingWhitespace" = $true
    "workbench.iconTheme" = "material-icon-theme"
    "git.confirmSync" = $false
    "git.autofetch" = $true
    "explorer.confirmDelete" = $false
    "explorer.confirmDragAndDrop" = $false
    "[javascript]" = @{ "editor.defaultFormatter" = "esbenp.prettier-vscode" }
    "[javascriptreact]" = @{ "editor.defaultFormatter" = "esbenp.prettier-vscode" }
    "[json]" = @{ "editor.defaultFormatter" = "esbenp.prettier-vscode" }
    "[yaml]" = @{ "editor.defaultFormatter" = "redhat.vscode-yaml" }
}

if (Test-Path $vsCodeSettingsFile) {
    Write-Skip "VS Code settings (file already exists — not overwriting)"
    Write-Host "    Review manually: $vsCodeSettingsFile" -ForegroundColor DarkYellow
} else {
    $settings | ConvertTo-Json -Depth 5 | Set-Content -Path $vsCodeSettingsFile -Encoding UTF8
    Write-OK "VS Code settings written to $vsCodeSettingsFile"
}

# ─── Step 10: Git Global Config ───────────────────────────────────────────────

Write-Step "Git global configuration"

# Use Git Bash for running git config
$gitBash = "C:\Program Files\Git\bin\bash.exe"

if (Test-Path $gitBash) {
    & $gitBash -c "git config --global core.autocrlf false"
    & $gitBash -c "git config --global init.defaultBranch main"
    & $gitBash -c "git config --global core.editor 'code --wait'"
    Write-OK "core.autocrlf = false"
    Write-OK "init.defaultBranch = main"
    Write-OK "core.editor = code --wait"
    Write-Host ""
    Write-Host "    Still needed (run manually in Git Bash):" -ForegroundColor Yellow
    Write-Host '    git config --global user.name "Your Name"' -ForegroundColor DarkYellow
    Write-Host '    git config --global user.email "you@example.com"' -ForegroundColor DarkYellow
} else {
    Write-Host "    Git Bash not found at expected path — skipping git config" -ForegroundColor Yellow
    Write-Host "    Run manually after restarting terminal." -ForegroundColor DarkYellow
}

# ─── Step 11: Create code folder ──────────────────────────────────────────────

Write-Step "Code folder"

$codeDir = "$env:USERPROFILE\OneDrive - Ryanair Ltd\Documents\code"

if (Test-Path $codeDir) {
    Write-Skip "Code folder ($codeDir)"
} else {
    New-Item -ItemType Directory -Path $codeDir -Force | Out-Null
    Write-OK "Created $codeDir"
}

# ─── Done ─────────────────────────────────────────────────────────────────────

Write-Host ""
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Green
Write-Host " Setup complete!" -ForegroundColor Green
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Green
Write-Host ""
Write-Host " Installed:" -ForegroundColor White
Write-Host "   - Chocolatey"
Write-Host "   - Git"
Write-Host "   - Node.js LTS (22.x) + npm"
Write-Host "   - Python 3"
Write-Host "   - AWS CLI v2"
Write-Host "   - Visual Studio Code + extensions"
Write-Host "   - Claude Code"
Write-Host ""
Write-Host " Next steps (manual):" -ForegroundColor Yellow
Write-Host "   1. Restart your terminal"
Write-Host "   2. Set git user.name and user.email (see 03-git-github.md)"
Write-Host "   3. Generate SSH key and add to GitHub (see 03-git-github.md)"
Write-Host "   4. Configure AWS profiles (see 04-aws.md)"
Write-Host "   5. Clone your repos (see 05-projects.md)"
Write-Host "   6. Run 'claude' to authenticate Claude Code"
Write-Host ""
