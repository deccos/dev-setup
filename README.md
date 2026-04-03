# Developer Environment Setup Guide

Complete step-by-step guide to setting up a new Windows laptop for development.

## What This Covers

This is a full recreation of Declan's dev environment, used across projects like:
- **stocktracker** – React/Vite frontend + Node.js Lambda + DynamoDB
- **task-tracker** – React/Vite + Lambda auth + task management
- **stjosephs-gfc** – React/Vite + Puppeteer Lambda scraper
- **whattodo** – React/Vite + Lambda + S3 image uploads

## Setup Order

Work through these in order — each step builds on the last.

| Step | Guide | What it covers |
|------|-------|----------------|
| 1 | [PowerShell Setup Script](./setup.ps1) | Most tools automatically |
| 2 | [Core Tools](./01-core-tools.md) | Git, Node.js, Python, VS Code, AWS CLI, Claude Code |
| 3 | [VS Code Configuration](./02-vscode.md) | Extensions, settings, themes |
| 4 | [Git & GitHub](./03-git-github.md) | SSH keys, global config, GitHub access |
| 5 | [AWS Setup](./04-aws.md) | CLI profiles, IAM users, per-project credentials |
| 6 | [Clone & Run a Project](./06-clone-and-run.md) | Step-by-step: clone, npm install, .env, run locally |
| 7 | [Project Reference](./05-projects.md) | Per-project details, Lambda deps, deploy instructions |

## Quick Start (Automated)

Open PowerShell **as Administrator** and run:

```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force
irm https://raw.githubusercontent.com/deccos/setup/main/setup.ps1 | iex
```

Or if you have this repo cloned locally:

```powershell
cd "C:\Users\<you>\Documents\code\dev-setup"
.\setup.ps1
```

> The script installs Chocolatey, Git, Node.js, Python, AWS CLI, and VS Code.
> Claude Code and SSH keys require manual steps — see the guides above.
