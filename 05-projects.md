# Project Setup Guide

After completing [01-core-tools.md](./01-core-tools.md), [03-git-github.md](./03-git-github.md), and [04-aws.md](./04-aws.md), you're ready to set up each project.

---

## Code Folder Location

All projects live under:
```
C:\Users\<you>\OneDrive - Ryanair Ltd\Documents\code\
```

> The OneDrive path matters — it's in a synced folder. If you prefer local-only, adjust accordingly, but the deploy scripts expect bash paths like `~/OneDrive - Ryanair Ltd/Documents/code/`.

---

## Common Setup Steps (All Projects)

Every project follows the same pattern:

```bash
cd ~/OneDrive\ -\ Ryanair\ Ltd/Documents/code/<project>

# 1. Install frontend dependencies
npm install

# 2. Install Lambda dependencies (each function has its own node_modules)
cd lambda/<function-name>
npm install
cd ../..

# 3. Create .env.local with your environment variables
cp .env.example .env.local
# Edit .env.local with your actual values

# 4. Run locally (optional, for frontend dev)
npm run dev
```

---

## Project: stocktracker

**Repo:** `git@github.com:deccos/stocktracker.git`

```bash
git clone git@github.com:deccos/stocktracker.git
cd stocktracker

# Frontend deps
npm install

# Lambda deps
cd lambda/api && npm install && cd ../..
cd lambda/scraper && npm install && cd ../..

# Environment
cp .env.example .env.local
```

Edit `.env.local`:
```bash
CLOUDFLARE_API_TOKEN=your_token
CLOUDFLARE_ZONE_ID=your_zone_id
CUSTOM_DOMAIN=stocktracker.costello.ie
# VITE_API_URL is set automatically by deploy.sh
```

### What it does
- Tracks Ryanair (RYA.L) stock price via Yahoo Finance
- Scraper Lambda runs on EventBridge schedule every minute during trading hours
- Frontend displays current price + historical chart
- Lambda runtime: Node.js 22.x

### Local dev
```bash
npm run dev   # Starts Vite dev server at http://localhost:5173
```

### Deploy
```bash
./deploy.sh
```

---

## Project: task-tracker

**Repo:** `git@github.com:deccos/task-tracker.git`

```bash
git clone git@github.com:deccos/task-tracker.git
cd task-tracker

npm install

cd lambda/auth && npm install && cd ../..
cd lambda/tasks && npm install && cd ../..

cp .env.example .env.local
```

Edit `.env.local`:
```bash
CLOUDFLARE_API_TOKEN=your_token
CLOUDFLARE_ZONE_ID=your_zone_id
CUSTOM_DOMAIN=tasks.costello.ie
```

### What it does
- Task management app with user authentication
- JWT-based auth (tokens stored in Secrets Manager)
- Users stored in DynamoDB with bcrypt-hashed passwords
- Lambda runtime: Node.js 20.x

### Deploy
```bash
./deploy.sh
```

---

## Project: stjosephs-gfc

**Repo:** `git@github.com:deccos/stjosephs-gfc.git`

```bash
git clone git@github.com:deccos/stjosephs-gfc.git
cd stjosephs-gfc

npm install

cd lambda/proxy && npm install && cd ../..

cp .env.example .env.local
```

Edit `.env.local`:
```bash
FOIREANN_API_KEY=your_api_key
CLOUDFLARE_API_TOKEN=your_token
CLOUDFLARE_ZONE_ID=your_zone_id
CUSTOM_DOMAIN=joes.costello.ie
```

### What it does
- GAA club fixtures and results for St. Joseph's GFC
- Scrapes Louth GAA website using Puppeteer (headless Chromium in Lambda)
- Also calls the Foireann API for club data
- Lambda uses `@sparticuz/chromium` layer — requires 1024 MB memory + 60s timeout
- Lambda runtime: Node.js 22.x

### Special notes
- The Foireann API key is stored in SSM Parameter Store (not Secrets Manager) under `/stjosephs-gfc/foireann-api-key`
- The deploy script creates the SSM parameter automatically from `.env.local`
- Lambda needs 1024 MB memory and ephemeral storage for Chromium

### Deploy
```bash
./deploy.sh
```

---

## Project: whattodo

**Repo:** `git@github.com:deccos/whattodo.git`

```bash
git clone git@github.com:deccos/whattodo.git
cd whattodo

npm install

cd lambda/auth && npm install && cd ../..
cd lambda/items && npm install && cd ../..

cp .env.example .env.local
```

Edit `.env.local`:
```bash
CLOUDFLARE_API_TOKEN=your_token
CLOUDFLARE_ZONE_ID=your_zone_id
CUSTOM_DOMAIN=whattodo.costello.ie
# Optional:
TMDB_API_KEY=your_tmdb_key  # for movie/TV metadata
```

### What it does
- Personal todo/wishlist app with image uploads
- Items can have images stored in S3 (via presigned URLs)
- Optional TMDB integration for movie/TV show metadata
- JWT authentication
- Lambda runtime: Node.js 20.x

### Deploy
```bash
./deploy.sh
```

---

## Running Locally (All Projects)

All frontends use Vite and start the same way:

```bash
npm run dev
```

This starts a local dev server at `http://localhost:5173`.

**Note:** The frontend in dev mode will try to call `VITE_API_URL`. In development, you either:
1. Set `VITE_API_URL` in `.env.local` to point at your deployed CloudFront URL, or
2. Run the Lambda functions locally (not configured out of the box)

For most dev work, pointing at the production API is fine for non-destructive changes.

---

## Deploy Script Pattern

All projects use `./deploy.sh` which handles everything end-to-end:

1. Checks for orphaned CloudFormation stacks and cleans up
2. Deploys WAF stack to `us-east-1`
3. Requests/validates ACM certificate via Cloudflare DNS
4. Deploys main stack to `eu-west-1`
5. Redeploys API Gateway stage
6. Packages and deploys each Lambda function
7. Runs `npm run build` for the frontend
8. Syncs built files to S3
9. Invalidates CloudFront cache

```bash
# Make script executable (first time only)
chmod +x deploy.sh

# Deploy
./deploy.sh
```

---

## Versioning

Every project has `src/version.js`:

```js
export const VERSION = '2026.3.5'
```

Format: `YYYY.M.N` — year, month, and an incrementing build number within that month.

**Always bump the version number** in `src/version.js` after making any code change before deploying.
