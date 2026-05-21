resource "hcloud_server" "controlplane" {
  for_each = var.controlplane_nodes

  name        = each.key
  image       = var.placeholder_image # Disk is overwritten by the Talos installer
  server_type = each.value.server_type
  location    = each.value.location
  iso         = var.talos_hetzner_iso

  firewall_ids = [hcloud_firewall.this.id]

  network {
    network_id = hcloud_network.this.id
    ip         = each.value.private_ip
  }

  labels = merge(var.tags, { type = "talos-controlplane" })

  depends_on = [hcloud_network_subnet.cloud]

  lifecycle {
    ignore_changes = [image]
  }
}
