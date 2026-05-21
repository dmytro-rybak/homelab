terraform {
  required_version = ">= 1.11.0" # OpenTofu

  required_providers {
    hcloud = {
      source  = "hetznercloud/hcloud"
      version = "~> 1.62"
    }
  }
}
