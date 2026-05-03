resource "proxmox_download_file" "debian_13" {
  node_name    = "pve"
  content_type = "vztmpl"
  datastore_id = "local"
  # HTTP is intentional — Proxmox serves templates over HTTP only; integrity is ensured via GPG-signed checksums.
  url = "http://download.proxmox.com/images/system/debian-13-standard_13.1-2_amd64.tar.zst"
}

resource "proxmox_virtual_environment_container" "dns" {
  node_name    = "pve"
  vm_id        = 100
  description  = "PowerDNS"
  unprivileged = true

  features {
    nesting = true
  }

  start_on_boot = true

  operating_system {
    template_file_id = proxmox_download_file.debian_13.id
    type             = "debian"
  }

  initialization {
    hostname = "dns"

    ip_config {
      ipv4 {
        address = "10.50.0.1/24"
        gateway = "10.50.0.254"
      }
    }
  }

  network_interface {
    name   = "eth0"
    bridge = "vmbr1"
  }

  disk {
    datastore_id = "local"
    size         = 4
  }
}
