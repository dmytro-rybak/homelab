###########################################################################
# Global
###########################################################################

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Tags to apply to the Hetzner network."
}

###########################################################################
# Network
###########################################################################

variable "network_name" {
  type        = string
  description = "The name of the network."
}

variable "network_zone" {
  type        = string
  default     = "eu-central"
  description = "Hetzner network zone (eu-central covers nbg1, fsn1, hel1)."
}

variable "network_cidr" {
  type        = string
  default     = "10.20.0.0/16"
  description = "IP range for the Hetzner private network."
}

variable "cloud_subnet_cidr" {
  type        = string
  default     = "10.20.0.0/24"
  description = "Subnet for cloud servers."
}

variable "vswitch_subnet_cidr" {
  type        = string
  default     = "10.20.1.0/24"
  description = "Subnet for the Hetzner vSwitch. Couples Robot vSwitch to this Cloud Network."
}

variable "vswitch_id" {
  type        = number
  default     = 4000
  description = "Hetzner Robot vSwitch ID. vSwitch must already exist with the dedicated server attached."
}

###########################################################################
# Servers
###########################################################################

variable "talos_hetzner_iso" {
  type        = string
  description = "Public Hetzner ISO name (e.g. hcloud-v1-12-4.amd64.iso)"
}

variable "placeholder_image" {
  type        = string
  default     = "debian-13"
  description = "Hetzner image installed to disk before ISO overwrites it. Any small image is fine."
}

variable "bootstrap_complete" {
  type        = bool
  default     = false
  description = "When false (cluster being brought up): firewall exposes Talos API (50000) and kube-apiserver (6443) so TF can push machine config / bootstrap and the laptop can talk to the API server directly. When true: only WireGuard (51820/udp) is open — Talos and kube-apiserver are reachable only via WG."
}

variable "controlplane_nodes" {
  type = map(object({
    location    = string
    server_type = string
    private_ip  = string
  }))
  description = "Map of control-plane node name to location, server type, and static private IP in the cloud subnet"
}
