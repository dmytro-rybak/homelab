resource "hcloud_network" "this" {
  name     = var.network_name
  ip_range = var.network_cidr

  delete_protection        = true
  expose_routes_to_vswitch = true

  labels = var.tags
}

resource "hcloud_network_subnet" "cloud" {
  type         = "cloud"
  network_id   = hcloud_network.this.id
  network_zone = var.network_zone
  ip_range     = var.cloud_subnet_cidr
}

resource "hcloud_network_subnet" "vswitch" {
  type         = "vswitch"
  network_id   = hcloud_network.this.id
  network_zone = var.network_zone
  ip_range     = var.vswitch_subnet_cidr
  vswitch_id   = var.vswitch_id
}

resource "hcloud_firewall" "this" {
  name = "${var.network_name}-controlplane"

  # WireGuard — always open. Sole peer is the laptop.
  rule {
    direction  = "in"
    protocol   = "udp"
    port       = "51820"
    source_ips = ["0.0.0.0/0", "::/0"]
  }

  # Talos API + kube-apiserver — only exposed publicly while bootstrap_complete
  # is false. After WG is verified, flip the var to true and re-apply: these
  # rules disappear and both endpoints become reachable only over WG.
  dynamic "rule" {
    for_each = var.bootstrap_complete ? [] : [50000, 6443]
    content {
      direction  = "in"
      protocol   = "tcp"
      port       = tostring(rule.value)
      source_ips = ["0.0.0.0/0", "::/0"]
    }
  }

  labels = var.tags
}
