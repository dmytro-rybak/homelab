data "cloudflare_zone" "this" {
  name = var.zone
}

# Round-robin A records for the kube-apiserver hostname. kubelet (via KubePrism)
# and the laptop both resolve this hostname and retry across CPs on failure.
# Not proxied — these IPs must resolve to the real Hetzner public IPs so the
# Talos API + kube-apiserver can be reached directly.
resource "cloudflare_record" "api" {
  for_each = var.controlplane_public_ips

  zone_id = data.cloudflare_zone.this.id
  name    = var.api_hostname
  content = each.value
  type    = "A"
  ttl     = 60 # short — CP IPs can change if a node is rebuilt
  proxied = false
  comment = "homelab kube-apiserver — ${each.key}"
}
