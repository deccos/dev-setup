# VS Code Configuration

---

## Extensions to Install

Open VS Code and install these extensions. You can do it via the Extensions panel (`Ctrl+Shift+X`) or via the terminal:

```powershell
# Core
code --install-extension esbenp.prettier-vscode
code --install-extension dbaeumer.vscode-eslint
code --install-extension dsznajder.es7-react-js-snippets
code --install-extension bradlc.vscode-tailwindcss

# AWS / Cloud
code --install-extension amazonwebservices.aws-toolkit-vscode
code --install-extension redhat.vscode-yaml

# Git
code --install-extension eamodio.gitlens
code --install-extension mhutchie.git-graph

# AI
code --install-extension anthropic.claude-code

# Utilities
code --install-extension christian-kohler.path-intellisense
code --install-extension formulahendry.auto-rename-tag
code --install-extension PKief.material-icon-theme
```

---

## Settings (`settings.json`)

Open with `Ctrl+Shift+P` → "Open User Settings (JSON)" and add:

```json
{
  "editor.fontSize": 14,
  "editor.tabSize": 2,
  "editor.formatOnSave": true,
  "editor.defaultFormatter": "esbenp.prettier-vscode",
  "editor.wordWrap": "on",
  "editor.minimap.enabled": false,
  "terminal.integrated.defaultProfile.windows": "Git Bash",
  "terminal.integrated.fontSize": 13,
  "files.eol": "\n",
  "files.trimTrailingWhitespace": true,
  "workbench.iconTheme": "material-icon-theme",
  "git.confirmSync": false,
  "git.autofetch": true,
  "explorer.confirmDelete": false,
  "explorer.confirmDragAndDrop": false,
  "[javascript]": {
    "editor.defaultFormatter": "esbenp.prettier-vscode"
  },
  "[javascriptreact]": {
    "editor.defaultFormatter": "esbenp.prettier-vscode"
  },
  "[json]": {
    "editor.defaultFormatter": "esbenp.prettier-vscode"
  },
  "[yaml]": {
    "editor.defaultFormatter": "redhat.vscode-yaml"
  }
}
```

> **Important:** Set `"terminal.integrated.defaultProfile.windows": "Git Bash"` so that the integrated terminal uses bash — required for running `./deploy.sh` scripts.

---

## Setting Git Bash as Default Terminal

1. Open VS Code
2. Press `Ctrl+Shift+P`
3. Type "Terminal: Select Default Profile"
4. Choose **Git Bash**

Now `Ctrl+` ` ` opens a bash terminal by default.

---

## Keyboard Shortcuts

Useful shortcuts to know:

| Action | Shortcut |
|--------|----------|
| Open terminal | Ctrl+` |
| Command palette | Ctrl+Shift+P |
| Go to file | Ctrl+P |
| Search in files | Ctrl+Shift+F |
| Format document | Shift+Alt+F |
| Toggle sidebar | Ctrl+B |
| Split editor | Ctrl+\ |
| Open settings JSON | Ctrl+Shift+P → "Open User Settings (JSON)" |

---

## Prettier Config (optional global)

If projects don't have their own `.prettierrc`, create one at `~/.prettierrc`:

```json
{
  "semi": false,
  "singleQuote": true,
  "tabWidth": 2,
  "trailingComma": "es5"
}
```
