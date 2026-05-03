terraform {
  backend "s3" {
    bucket   = "homelab-tfstate"
    key      = "infrastructure/terraform.tfstate"
    endpoint = "https://<HETZNER_OBJECT_STORAGE_HOSTNAME>"
    region   = "fsn1"
    profile  = "homelab"

    skip_credentials_validation = true
    skip_metadata_api_check     = true
    skip_region_validation      = true
    force_path_style            = true
  }
}
