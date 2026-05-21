output "kubeconfig" {
  value     = module.talos.kubeconfig
  sensitive = true
}

output "talosconfig" {
  value     = module.talos.talosconfig
  sensitive = true
}

output "wireguard_laptop_config" {
  value = module.talos.wireguard_laptop_config
}

output "controlplane_public_ips" {
  value = module.hetzner.controlplane_public_ips
}

output "controlplane_private_ips" {
  value = module.hetzner.controlplane_private_ips
}

output "node_wireguard_public_keys" {
  value = module.talos.node_wireguard_public_keys
}
