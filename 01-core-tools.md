# Core Tools Installation

Install these tools in order. Most are handled by `setup.ps1` — this guide covers manual steps and verification.

---

## 1. Chocolatey (Package Manager)

Chocolatey is the Windows equivalent of `brew` (macOS) — it installs most dev tools from the command line.

**Open PowerShell as Administrator**, then run:

```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
```

Verify:
```powershell
choco --version
```

---

## 2. Git

```powershell
choco install git -y
```

After install, close and reopen PowerShell, then verify:
```powershell
git --version
```

> See [03-git-github.md](./03-git-github.md) for SSH key setup and GitHub config.

---

## 3. Node.js (LTS)

Projects use Node.js 22.x in Lambda. Install the LTS version locally (which is 22.x):

```powershell
choco install nodejs-lts -y
```

Verify:
```powershell
node --version    # Should be v22.x.x
npm --version     # Should be 10.x.x
```

### Node version management (optional but recommended)

If you ever need multiple Node versions, install `nvm-windows`:

```powershell
choco install nvm -y
nvm install 22
nvm use 22
```

---

## 4. Python

Used for scripting utilities. Install Python 3.x:

```powershell
choco install python -y
```

Verify:
```powershell
python --version   # Python 3.x.x
pip --version
```

> Make sure Python is added to PATH. The Chocolatey installer does this automatically.

---

## 5. Visual Studio Code

```powershell
choco install vscode -y
```

Or download from: https://code.visualstudio.com/

Verify:
```powershell
code --version
```

> See [02-vscode.md](./02-vscode.md) for extensions and settings.

---

## 6. AWS CLI v2

The AWS CLI is used for deployments. All projects deploy to AWS eu-west-1.

```powershell
choco install awscli -y
```

Verify:
```powershell
aws --version   # aws-cli/2.x.x
```

> See [04-aws.md](./04-aws.md) for profile configuration.

---

## 7. Claude Code (AI Coding Assistant)

Claude Code is a CLI tool from Anthropic. It requires Node.js to be installed first.

```powershell
npm install -g @anthropic-ai/claude-code
```

Verify:
```powershell
claude --version
```

### First-time auth

Run `claude` to open the interactive setup. You'll be prompted to log in via browser (claude.ai account required).

```powershell
claude
```

### VS Code Integration

Claude Code also has a VS Code extension. Search for **"Claude Code"** in the VS Code Extensions panel and install it.

---

## 8. bash (for deploy scripts)

All deploy scripts (`deploy.sh`) are bash scripts. Git for Windows ships with Git Bash, which provides bash on Windows.

After installing Git (step 2), you'll have bash available via:
- **Git Bash** application
- Any terminal in VS Code (set as default shell — see [02-vscode.md](./02-vscode.md))

Verify in Git Bash or VS Code terminal:
```bash
bash --version
```

---

## Summary Checklist

```
[ ] Chocolatey
[ ] Git
[ ] Node.js 22 LTS (npm included)
[ ] Python 3.x (pip included)
[ ] Visual Studio Code
[ ] AWS CLI v2
[ ] Claude Code (npm global)
[ ] Git Bash / bash shell
```
