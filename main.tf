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

# Your domain (zone) name (no Zone ID needed)
variable "zone_name" {
  type    = string
  default = "zemingzhang.com"
}

# Where your GitHub Pages CNAMEs point
variable "github_pages_target" {
  type    = string
  default = "zemingzhang1.github.io"
}

# Add apps here; Terraform will create prod/stg/dev records for each
variable "apps" {
  type    = list(string)
  default = ["hello-world"]
}

# Look up the zone by name
data "cloudflare_zone" "this" {
  name = var.zone_name
}

locals {
  records = flatten([
    for app in var.apps : [
      app,
      "stg-${app}",
      "dev-${app}"
    ]
  ])
}

resource "cloudflare_record" "cname" {
  for_each = toset(local.records)

  zone_id = data.cloudflare_zone.this.id
  name    = each.value
  type    = "CNAME"
  content = var.github_pages_target

  # IMPORTANT for GitHub Pages
  proxied = false
  ttl     = 1 # auto
}

output "created_records" {
  value = sort(tolist(local.records))
}