# Git & GitHub Setup

---

## 1. Global Git Config

Set your identity. These values appear in every commit you make:

```bash
git config --global user.name "Declan Costello"
git config --global user.email "declan@costello.ie"
git config --global core.editor "code --wait"
git config --global init.defaultBranch main
git config --global core.autocrlf false
```

> `core.autocrlf false` is important on Windows — the deploy scripts use Unix line endings (LF) and Windows can corrupt them if this is set to `true`.

Verify:
```bash
git config --list
```

---

## 2. SSH Key for GitHub

SSH keys let you push/pull from GitHub without entering a password every time. All projects use SSH remotes (`git@github.com:deccos/...`).

### Generate a new SSH key

```bash
ssh-keygen -t ed25519 -C "declan@costello.ie"
```

- When prompted for a file location, press **Enter** to accept the default (`~/.ssh/id_ed25519`)
- Set a passphrase (recommended) or press Enter for no passphrase

### Add SSH key to the agent

```bash
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519
```

### Add the public key to GitHub

1. Copy the public key:
   ```bash
   cat ~/.ssh/id_ed25519.pub
   ```
2. Go to **GitHub → Settings → SSH and GPG keys → New SSH key**
3. Paste the key and give it a name (e.g. "Laptop 2025")

### Verify GitHub connection

```bash
ssh -T git@github.com
# Hi deccos! You've successfully authenticated...
```

---

## 3. Persistent SSH Agent (Git Bash on Windows)

The SSH agent doesn't persist between terminal sessions by default. Add this to `~/.bashrc` or `~/.bash_profile`:

```bash
# Start SSH agent if not running
env=~/.ssh/agent.env

agent_load_env () { test -f "$env" && . "$env" >| /dev/null ; }

agent_start () {
    (umask 077; ssh-agent >| "$env")
    . "$env" >| /dev/null ;
}

agent_load_env

# agent_run_state: 0=agent running w/ key; 1=agent w/o key; 2=agent not running
agent_run_state=$(ssh-add -l >| /dev/null 2>&1; echo $?)

if [ ! "$SSH_AUTH_SOCK" ] || [ $agent_run_state = 2 ]; then
    agent_start
    ssh-add
elif [ "$SSH_AUTH_SOCK" ] && [ $agent_run_state = 1 ]; then
    ssh-add
fi

unset env
```

---

## 4. Cloning Repositories

All projects are under the `deccos` GitHub organisation. Clone them into your code folder:

```bash
cd ~/OneDrive\ -\ Ryanair\ Ltd/Documents/code

git clone git@github.com:deccos/stocktracker.git
git clone git@github.com:deccos/task-tracker.git
git clone git@github.com:deccos/stjosephs-gfc.git
git clone git@github.com:deccos/whattodo.git
```

---

## 5. Useful Git Aliases (optional)

Add to `~/.gitconfig`:

```ini
[alias]
  st = status
  co = checkout
  br = branch
  lg = log --oneline --graph --decorate --all
  aa = add -A
  cm = commit -m
```

Usage: `git lg`, `git st`, etc.
