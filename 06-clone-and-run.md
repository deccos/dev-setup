# Cloning a Project on a New Laptop

A complete walkthrough from zero to running code locally.

> **Prerequisites:** You've completed the steps in [01-core-tools.md](./01-core-tools.md) and [03-git-github.md](./03-git-github.md) — Git is installed and your SSH key is set up and added to GitHub.

---

## 1. Open Git Bash

All the commands below are run in **Git Bash** (not PowerShell or CMD).

- Open VS Code
- Press `` Ctrl+` `` to open the terminal
- It should say `bash` in the top-right of the terminal panel
- If not: click the `+` dropdown arrow → select **Git Bash**

---

## 2. Navigate to the Code Folder

```bash
cd ~/OneDrive\ -\ Ryanair\ Ltd/Documents/code
```

> The backslash before the space is required in bash. Tab-completion works here — type `cd ~/On` and press Tab.

Verify you're in the right place:
```bash
pwd
# /c/Users/costellod/OneDrive - Ryanair Ltd/Documents/code
```

---

## 3. Clone the Repository

```bash
git clone git@github.com:deccos/<project-name>.git
```

Replace `<project-name>` with the repo name. For example:

```bash
git clone git@github.com:deccos/stocktracker.git
```

This creates a new folder called `stocktracker` inside your code folder.

**If you get a "Permission denied (publickey)" error**, your SSH key isn't set up yet. Go to [03-git-github.md](./03-git-github.md) and complete the SSH setup first.

**If you get a "Host key verification failed" prompt**, type `yes` and press Enter — this adds GitHub to your known hosts.

---

## 4. Open the Project in VS Code

```bash
cd stocktracker
code .
```

The `.` means "open the current folder". VS Code will open with the project loaded in the Explorer panel.

---

## 5. Install Frontend Dependencies

In the VS Code terminal (Git Bash):

```bash
npm install
```

This reads `package.json` and downloads all frontend packages into a `node_modules` folder. It may take 30–60 seconds the first time.

You should see output like:
```
added 312 packages in 45s
```

---

## 6. Install Lambda Dependencies

Each Lambda function has its own `package.json` and `node_modules`. Install them separately:

```bash
# Check what Lambda functions exist
ls lambda/

# Install each one (adjust names to match what ls shows)
cd lambda/api && npm install && cd ../..
cd lambda/scraper && npm install && cd ../..
```

> **Why separate?** Lambda functions are zipped and deployed independently. Their dependencies can't be mixed with the frontend's.

---

## 7. Create Your Environment File

Projects have a `.env.example` file with a template of required variables. Copy it:

```bash
cp .env.example .env.local
```

Then open `.env.local` in VS Code and fill in the real values:

```bash
code .env.local
```

For most projects you need:
```bash
CLOUDFLARE_API_TOKEN=<your Cloudflare API token>
CLOUDFLARE_ZONE_ID=<your costello.ie zone ID>
CUSTOM_DOMAIN=stocktracker.costello.ie
```

> `.env.local` is gitignored — it never gets committed. It holds your secrets.
> See [04-aws.md](./04-aws.md) for where to find the Cloudflare values.

---

## 8. Run the Frontend Locally

```bash
npm run dev
```

Output:
```
  VITE v5.x.x  ready in 300 ms

  ➜  Local:   http://localhost:5173/
  ➜  Network: http://192.168.x.x:5173/
```

Open `http://localhost:5173` in your browser. The app will hot-reload as you edit files.

Press `Ctrl+C` to stop the dev server.

> **API calls:** The frontend calls `VITE_API_URL` for data. In dev mode, set this in `.env.local` to point at your deployed CloudFront URL so API calls work. The deploy script sets this automatically when you do a full deploy.

---

## 9. Make a Change and Test It

1. Edit a file in `src/` (e.g. `src/App.jsx`)
2. The browser should automatically refresh and show your change
3. When happy, bump the version in `src/version.js` (see [versioning](#versioning) below)

---

## 10. Pulling Changes Later

When returning to a project after changes have been made (by you on another machine, or by a collaborator):

```bash
git pull
```

If `package.json` changed (new packages were added), re-run:
```bash
npm install
```

If any Lambda `package.json` files changed:
```bash
cd lambda/api && npm install && cd ../..
# etc.
```

---

## Versioning

Before deploying any change, bump the version in `src/version.js`:

```js
// Before
export const VERSION = '2026.3.5'

// After
export const VERSION = '2026.3.6'
```

Format: `YYYY.M.N` — increment N each time within the same month.

---

## Quick Reference: Full Setup in One Go

Here's the complete sequence for a brand new project clone:

```bash
# 1. Navigate to code folder
cd ~/OneDrive\ -\ Ryanair\ Ltd/Documents/code

# 2. Clone
git clone git@github.com:deccos/stocktracker.git
cd stocktracker

# 3. Install all dependencies
npm install
cd lambda/api && npm install && cd ../..
cd lambda/scraper && npm install && cd ../..

# 4. Set up environment
cp .env.example .env.local
code .env.local   # fill in your values

# 5. Open in VS Code
code .

# 6. Run locally
npm run dev
```

---

## All Project Repos

| Project | Clone command |
|---------|--------------|
| stocktracker | `git clone git@github.com:deccos/stocktracker.git` |
| task-tracker | `git clone git@github.com:deccos/task-tracker.git` |
| stjosephs-gfc | `git clone git@github.com:deccos/stjosephs-gfc.git` |
| whattodo | `git clone git@github.com:deccos/whattodo.git` |

---

## Troubleshooting

**`npm install` fails with ERESOLVE or peer dependency errors**
```bash
npm install --legacy-peer-deps
```

**`git clone` says "Permission denied (publickey)"**
- Your SSH key isn't added to GitHub. See [03-git-github.md](./03-git-github.md).
- Or the SSH agent isn't running: `eval "$(ssh-agent -s)" && ssh-add ~/.ssh/id_ed25519`

**`npm run dev` says "VITE_API_URL is not defined"**
- You haven't created `.env.local` yet, or it's missing the variable. Copy from `.env.example`.

**Port 5173 already in use**
```bash
# Run on a different port
npm run dev -- --port 3000
```

**`./deploy.sh` says "Permission denied"**
```bash
chmod +x deploy.sh
./deploy.sh
```
