# terraform-infra

Terraform configuration for managing Cloudflare DNS records that point app subdomains to a GitHub Pages origin.

## What this creates

For each app in `var.apps`, this configuration creates three `CNAME` records in the configured Cloudflare zone:

- `<app>`
- `stg-<app>`
- `dev-<app>`

All records point to `var.github_pages_target` (defaults to `zemingzhang1.github.io`) with `proxied = false`, which is required for GitHub Pages custom domains.

## Prerequisites

- Terraform `>= 1.5.0`
- A Cloudflare API token with DNS edit access to your zone
- A zone in Cloudflare matching `var.zone_name`

## Quick deploy

1. Export your Cloudflare token:

   ```bash
   export TF_VAR_cloudflare_token="<your-cloudflare-api-token>"
   ```

2. (Optional) Create a `terraform.tfvars` file to override defaults:

   ```hcl
   zone_name            = "example.com"
   github_pages_target  = "my-user.github.io"
   apps                 = ["hello-world", "docs", "dashboard"]
   ```

3. Initialize Terraform:

   ```bash
   terraform init
   ```

4. Preview changes:

   ```bash
   terraform plan
   ```

5. Apply changes:

   ```bash
   terraform apply
   ```

## Verify records

After apply, verify DNS in Cloudflare dashboard or with `dig`:

```bash
dig +short hello-world.example.com CNAME
dig +short stg-hello-world.example.com CNAME
dig +short dev-hello-world.example.com CNAME
```

## Common issues

- **No zones found**: Ensure `zone_name` exactly matches your Cloudflare zone.
- **Auth errors**: Confirm token permissions include DNS read/write for the target zone.
- **GitHub Pages validation fails**: Keep `proxied = false` on the CNAME records.
- **Protected defaults**: This config is guarded to avoid managing reserved hostnames such as `@`, `www`, `me`, `_domainconnect`, `_dmarc`, and `google._domainkey` via `var.apps`.
- **CNAME cleanup on main**: CI removes unmanaged CNAME records that are not in Terraform-managed app labels and not in protected defaults (`@`, `www`, `me`, `_domainconnect`, `_dmarc`, `google._domainkey`).
