output "kubeconfig" {
  value     = talos_cluster_kubeconfig.this.kubeconfig_raw
  sensitive = true
}

output "talosconfig" {
  sensitive = true
  value = yamlencode({
    context = var.cluster_name
    contexts = {
      (var.cluster_name) = {
        endpoints = values(local.wireguard_addr_only)
        ca        = talos_machine_secrets.this.client_configuration.ca_certificate
        crt       = talos_machine_secrets.this.client_configuration.client_certificate
        key       = talos_machine_secrets.this.client_configuration.client_key
      }
    }
  })
}

output "wireguard_laptop_config" {
  description = "wg0.conf for the laptop. Replace REPLACE_WITH_LAPTOP_PRIVATE_KEY before importing."
  value = format(
    "[Interface]\n# Replace with your laptop's WireGuard private key\nPrivateKey = REPLACE_WITH_LAPTOP_PRIVATE_KEY\nAddress = %s\n\n%s\n",
    var.wireguard_clients.address,
    join("\n\n", [for p in local.laptop_peers : format(
      "[Peer]\n# %s (%s)\nPublicKey = %s\nAllowedIPs = %s\nEndpoint = %s\nPersistentKeepalive = 25",
      p.name, p.role, p.public_key, join(", ", p.allowed_ips), p.endpoint,
    )])
  )
}

output "node_wireguard_public_keys" {
  description = "WireGuard public key per node (echoed back from input vars)"
  value       = var.wireguard_node_public_keys
}
