# AWS Setup

All projects deploy through a single shared IAM user: `deccos-deployer`. One profile, one set of credentials, all projects.

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

All projects share a single IAM user and a single named CLI profile:

| User | AWS Profile | Region |
|------|-------------|--------|
| `deccos-deployer` | `deccos-deployer` | eu-west-1 |

> All primary resources are in **eu-west-1** (Ireland).
> WAF stacks are always in **us-east-1** (required by CloudFront).

---

## 3. Configuring the AWS Profile

Run once:

```bash
aws configure --profile deccos-deployer
```

You'll be prompted for:
```
AWS Access Key ID:     <from IAM user in AWS console>
AWS Secret Access Key: <from IAM user in AWS console>
Default region name:   eu-west-1
Default output format: json
```

The credentials are stored in `~/.aws/credentials` and `~/.aws/config`.

---

## 4. Creating the IAM User (on the AWS side)

One-time setup for a new AWS account:

1. Log into AWS Console
2. Go to **IAM → Users → Create User**
3. Name: `deccos-deployer`
4. **Do not enable console access** — CLI only
5. After creation, go to **Security Credentials → Create Access Key**
6. Select "CLI" use case
7. Copy the Access Key ID and Secret Access Key

### IAM Policy

The shared policy is in `iam/deccos-deployer-policy.json` (this repo). Attach it as an inline policy:

1. IAM → Users → `deccos-deployer`
2. Permissions → Add permissions → Create inline policy
3. Paste the JSON from `iam/deccos-deployer-policy.json`

The policy covers all services used across all projects (Lambda, DynamoDB, S3, CloudFront, WAF, ACM, Secrets Manager, SSM, EventBridge, CloudWatch Logs).

---

## 5. Verify the Profile

```bash
aws sts get-caller-identity --profile deccos-deployer
```

Expected output:
```json
{
    "UserId": "AIDA...",
    "Account": "123456789012",
    "Arn": "arn:aws:iam::123456789012:user/deccos-deployer"
}
```

---

## 6. AWS Credentials File Structure

After configuring the profile, `~/.aws/credentials` should look like:

```ini
[default]
aws_access_key_id = ...
aws_secret_access_key = ...

[deccos-deployer]
aws_access_key_id = AKIATCTURF2N...
aws_secret_access_key = ...
```

And `~/.aws/config`:

```ini
[profile deccos-deployer]
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
