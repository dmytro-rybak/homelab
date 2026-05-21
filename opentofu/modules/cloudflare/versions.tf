terraform {
  required_version = ">= 1.11.0" # OpenTofu

  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 4.0"
    }
  }
}
