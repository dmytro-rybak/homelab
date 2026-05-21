variable "zone" {
  type        = string
  description = "Cloudflare zone (apex domain), e.g. homelab0.xyz"
}

variable "api_hostname" {
  type        = string
  description = "FQDN for the Kubernetes API, e.g. api.internal.homelab0.xyz. Must be inside var.zone."
}

variable "controlplane_public_ips" {
  type        = map(string)
  description = "Map of CP node name to public IPv4. One A record is created per entry, all pointing at var.api_hostname (round-robin)."
}
