resource "proxmox_sdn_zone_simple" "internal" {
  id    = var.sdn_zone
  nodes = [var.node_name]
  dhcp  = "dnsmasq"
  ipam  = "pve"
}

resource "proxmox_sdn_vnet" "internal" {
  id   = var.sdn_vnet
  zone = proxmox_sdn_zone_simple.internal.id
}

resource "proxmox_sdn_subnet" "internal" {
  vnet    = proxmox_sdn_vnet.internal.id
  cidr    = var.subnet_cidr
  gateway = var.gateway
  snat    = true

  dhcp_range = {
    start_address = var.dhcp_range_start
    end_address   = var.dhcp_range_end
  }

  dhcp_dns_server = var.dhcp_dns_server
}

resource "proxmox_sdn_applier" "this" {
  depends_on = [
    proxmox_sdn_zone_simple.internal,
    proxmox_sdn_vnet.internal,
    proxmox_sdn_subnet.internal,
  ]

  lifecycle {
    replace_triggered_by = [
      proxmox_sdn_zone_simple.internal,
      proxmox_sdn_vnet.internal,
      proxmox_sdn_subnet.internal,
    ]
  }
}
