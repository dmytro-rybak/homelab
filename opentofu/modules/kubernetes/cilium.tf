resource "helm_release" "cilium" {
  name             = "cilium"
  repository       = "https://helm.cilium.io"
  chart            = "cilium"
  version          = var.cilium_version
  namespace        = "kube-system"
  create_namespace = false

  values = [yamlencode({
    ipam = {
      mode = "kubernetes"
    }

    # Cilium replaces kube-proxy entirely. Talos config disabled the kube-proxy
    # static pod; Cilium picks up Service routing.
    kubeProxyReplacement = true
    k8sServiceHost       = "localhost"
    k8sServicePort       = 7445 # KubePrism

    # Tunnel mode (vxlan) — works regardless of underlay routability across
    # the Hetzner private network + vSwitch boundary. WireGuard layered on top.
    routingMode    = "tunnel"
    tunnelProtocol = "vxlan"
    MTU            = var.mtu

    # Transparent node-to-node encryption.
    encryption = {
      enabled        = true
      type           = "wireguard"
      nodeEncryption = true
    }

    # Talos requires explicit cgroup config — autoMount expects /sys/fs/cgroup
    # writable, which Talos doesn't allow.
    cgroup = {
      autoMount = { enabled = false }
      hostRoot  = "/sys/fs/cgroup"
    }

    securityContext = {
      capabilities = {
        ciliumAgent      = ["CHOWN", "KILL", "NET_ADMIN", "NET_RAW", "IPC_LOCK", "SYS_ADMIN", "SYS_RESOURCE", "DAC_OVERRIDE", "FOWNER", "SETGID", "SETUID"]
        cleanCiliumState = ["NET_ADMIN", "SYS_ADMIN", "SYS_RESOURCE"]
      }
    }

    operator = {
      replicas = 2
    }

    hubble = {
      enabled = true
      relay   = { enabled = true }
      ui      = { enabled = true }
    }

    # Gateway API CRDs installed; feature enabled. No Gateway resource here —
    # that's reserved for future use.
    gatewayAPI = {
      enabled = true
    }
  })]
}

# LoadBalancer IP pool — defined but inactive (disabled=true). When future
# services need LB IPs, flip disabled to false and adjust the CIDR.
resource "kubectl_manifest" "lb_ip_pool" {
  depends_on = [helm_release.cilium]
  yaml_body = yamlencode({
    apiVersion = "cilium.io/v2"
    kind       = "CiliumLoadBalancerIPPool"
    metadata = {
      name = "homelab-default"
    }
    spec = {
      disabled = true
      blocks = [{
        cidr = var.lb_pool_cidr
      }]
    }
  })
}
