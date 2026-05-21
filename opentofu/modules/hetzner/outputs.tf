output "controlplane_public_ips" {
  description = "Map of CP node name to public IPv4 address"
  value       = { for name, server in hcloud_server.controlplane : name => server.ipv4_address }
}

output "controlplane_private_ips" {
  description = "Map of CP node name to static private IP in the cloud subnet"
  value       = { for name, node in var.controlplane_nodes : name => node.private_ip }
}

output "network_id" {
  description = "Hetzner private network ID"
  value       = hcloud_network.this.id
}

output "cloud_subnet_cidr" {
  value = var.cloud_subnet_cidr
}

output "vswitch_subnet_cidr" {
  value = var.vswitch_subnet_cidr
}

output "vswitch_subnet_id" {
  description = "Subnet resource ID for the vSwitch coupling"
  value       = hcloud_network_subnet.vswitch.id
}

output "network_cidr" {
  value = var.network_cidr
}

# vSwitch path MTU — must be honored by Talos network config and Cilium.
output "vswitch_mtu" {
  value = 1400
}
