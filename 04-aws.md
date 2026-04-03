# AWS Setup

All projects use AWS with isolated IAM users and named profiles. Never use a single shared `default` profile for everything — each project has its own.

---

## 1. Install AWS CLI

```powershell
choco install awscli -y
```

Verify:
```bash
aws --version   # aws-cli/2.x.x Python/3.x.x
```

---

## 2. AWS Profile Structure

Each project has a dedicated IAM user and a named CLI profile:

| Project | AWS Profile | Region |
|---------|-------------|--------|
| stocktracker | `stocktracker` | eu-west-1 |
| task-tracker | `task-tracker` | eu-west-1 |
| stjosephs-gfc | `stjosephs-gfc` | eu-west-1 |
| whattodo | `whattodo` | eu-west-1 |

> All primary resources are in **eu-west-1** (Ireland).
> WAF stacks are always in **us-east-1** (required by CloudFront).

---

## 3. Configuring AWS Profiles

For each project, run:

```bash
aws configure --profile stocktracker
```

You'll be prompted for:
```
AWS Access Key ID:     <from IAM user in AWS console>
AWS Secret Access Key: <from IAM user in AWS console>
Default region name:   eu-west-1
Default output format: json
```

Repeat for each project profile (`task-tracker`, `stjosephs-gfc`, `whattodo`).

The credentials are stored in `~/.aws/credentials` and `~/.aws/config`.

---

## 4. Creating IAM Users (on the AWS side)

Each project has a deployer IAM user named `{project}-deployer`. When setting up a new account or new project:

1. Log into AWS Console
2. Go to **IAM → Users → Create User**
3. Name: `stocktracker-deployer` (etc.)
4. **Do not enable console access** — CLI only
5. After creation, go to **Security Credentials → Create Access Key**
6. Select "CLI" use case
7. Copy the Access Key ID and Secret Access Key

### IAM Policy

Each project has a `iam/deploy-policy.json` file in the repo. Attach this as an inline policy to the deployer user:

1. IAM → Users → `stocktracker-deployer`
2. Permissions → Add permissions → Create inline policy
3. Paste the JSON from `iam/deploy-policy.json`

The policy is scoped to only the resources that project needs (Lambda, DynamoDB, S3, CloudFront, etc.).

---

## 5. Verify a Profile

```bash
aws sts get-caller-identity --profile stocktracker
```

Expected output:
```json
{
    "UserId": "AIDA...",
    "Account": "123456789012",
    "Arn": "arn:aws:iam::123456789012:user/stocktracker-deployer"
}
```

---

## 6. AWS Credentials File Structure

After configuring all profiles, `~/.aws/credentials` should look like:

```ini
[default]
aws_access_key_id = ...
aws_secret_access_key = ...

[stocktracker]
aws_access_key_id = AKIATCTURF2N...
aws_secret_access_key = ...

[task-tracker]
aws_access_key_id = AKIATCTURF2N...
aws_secret_access_key = ...

[stjosephs-gfc]
aws_access_key_id = AKIATCTURF2N...
aws_secret_access_key = ...

[whattodo]
aws_access_key_id = AKIATCTURF2N...
aws_secret_access_key = ...
```

And `~/.aws/config`:

```ini
[profile stocktracker]
region = eu-west-1
output = json

[profile task-tracker]
region = eu-west-1
output = json

[profile stjosephs-gfc]
region = eu-west-1
output = json

[profile whattodo]
region = eu-west-1
output = json
```

---

## 7. Cloudflare API Token (for custom domains)

Some deploy scripts use the Cloudflare API to create DNS records for ACM certificate validation and custom domain CNAMEs.

You need:
- `CLOUDFLARE_API_TOKEN` — an API token with **DNS Edit** permission for the `costello.ie` zone
- `CLOUDFLARE_ZONE_ID` — the Zone ID for `costello.ie` (found in Cloudflare dashboard → Overview)

These go in a `.env.local` file in each project root (this file is gitignored). Example:

```bash
CLOUDFLARE_API_TOKEN=your_token_here
CLOUDFLARE_ZONE_ID=your_zone_id_here
CUSTOM_DOMAIN=stocktracker.costello.ie
```

### Getting a Cloudflare API Token

1. Log into Cloudflare → **My Profile → API Tokens → Create Token**
2. Use template: **Edit zone DNS**
3. Scope it to `Zone: costello.ie`
4. Copy the token (only shown once)

---

## 8. Services Used Per Project

| Service | stocktracker | task-tracker | stjosephs-gfc | whattodo |
|---------|:-----------:|:------------:|:-------------:|:--------:|
| Lambda | ✓ | ✓ | ✓ | ✓ |
| DynamoDB | ✓ | ✓ | | ✓ |
| S3 (frontend) | ✓ | ✓ | ✓ | ✓ |
| S3 (images) | | | | ✓ |
| CloudFront | ✓ | ✓ | ✓ | ✓ |
| API Gateway | ✓ | ✓ | ✓ | ✓ |
| WAF | ✓ | ✓ | ✓ | ✓ |
| Secrets Manager | ✓ | ✓ | | ✓ |
| SSM Parameter Store | | | ✓ | |
| ACM | ✓ | ✓ | ✓ | ✓ |
| EventBridge | ✓ | | | |
