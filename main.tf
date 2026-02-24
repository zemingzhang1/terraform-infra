terraform {
  required_version = ">= 1.5.0"

  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 5.0"
    }
  }
}

provider "cloudflare" {
  api_token = var.cloudflare_token
}

variable "cloudflare_token" {
  type      = string
  sensitive = true
}

variable "zone_name" {
  type    = string
  default = "zemingzhang.com"
}

variable "github_pages_target" {
  type    = string
  default = "zemingzhang1.github.io"
}

variable "apps" {
  type    = list(string)
  default = ["hello-world"]

  validation {
    condition = alltrue([
      for app in var.apps : !contains([
        "@",
        "www",
        "me",
        "_domainconnect",
        "_dmarc",
        "google._domainkey",
        "zemingzhang.com"
      ], app)
    ])
    error_message = "apps contains a protected hostname (@, www, me, _domainconnect, _dmarc, google._domainkey, zemingzhang.com). These default records must not be managed by this Terraform config."
  }
}

# Look up the zone by name
data "cloudflare_zone" "this" {
  filter = {
    name = var.zone_name
  }
}

locals {
  zone_id = data.cloudflare_zone.this.id

  records = flatten([
    for app in var.apps : [
      app,
      "stg-${app}",
      "dev-${app}"
    ]
  ])
}

# ✅ v5: DNS record resource is cloudflare_dns_record (not cloudflare_record)
resource "cloudflare_dns_record" "cname" {
  for_each = toset(local.records)

  zone_id = local.zone_id
  name    = each.value
  type    = "CNAME"
  content = var.github_pages_target

  proxied = false # IMPORTANT for GitHub Pages
  ttl     = 1     # Auto
}
