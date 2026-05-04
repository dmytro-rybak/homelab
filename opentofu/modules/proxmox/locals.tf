locals {
  talos_schematic_id = jsondecode(data.http.talos_schematic.response_body).id
  talos_iso_url      = "https://factory.talos.dev/image/${local.talos_schematic_id}/v${var.talos_version}/metal-amd64.iso"

  talos_nodes = {
    "talos-cp-1" = {
      vm_id  = 110
      cores  = 2
      memory = 8192
    }
    "talos-worker-1" = {
      vm_id  = 111
      cores  = 4
      memory = 24576
    }
    "talos-worker-2" = {
      vm_id  = 112
      cores  = 4
      memory = 24576
    }
  }
}
