variable "cilium_version" {
  type    = string
  default = "1.19.3"
}

variable "cert_manager_version" {
  type    = string
  default = "v1.20.2"
}

variable "external_dns_version" {
  type    = string
  default = "1.21.1"
}

variable "mtu" {
  type        = number
  default     = 1400
  description = "MTU advertised to Cilium — should match the underlying private network MTU"
}

variable "pod_cidr" {
  type    = string
  default = "10.244.0.0/16"
}

variable "service_cidr" {
  type    = string
  default = "10.96.0.0/12"
}

variable "lb_pool_cidr" {
  type        = string
  default     = "10.20.0.240/29"
  description = "Placeholder LoadBalancer IP pool CIDR. Pool is created with disabled=true."
}

variable "cloudflare_api_token" {
  type        = string
  sensitive   = true
  description = "Cloudflare API token with Zone:DNS:Edit on the homelab zone — shared by cert-manager (DNS-01) and external-dns"
}

variable "cloudflare_zone" {
  type        = string
  description = "Cloudflare zone (apex), e.g. homelab0.xyz"
}

variable "internal_subdomain" {
  type        = string
  description = "Internal subdomain managed by external-dns and covered by the wildcard cert, e.g. internal.homelab0.xyz"
}

variable "acme_email" {
  type        = string
  description = "Email used for Let's Encrypt account registration"
}
